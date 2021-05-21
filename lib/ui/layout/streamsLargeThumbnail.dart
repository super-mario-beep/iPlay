import 'package:audio_service/audio_service.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:newpipeextractor_dart/extractors/channels.dart';
import 'package:newpipeextractor_dart/extractors/playlist.dart';
import 'package:newpipeextractor_dart/models/channel.dart';
import 'package:newpipeextractor_dart/models/infoItems/channel.dart';
import 'package:newpipeextractor_dart/models/infoItems/playlist.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/utils/url.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:songtube/downloadMenu/downloadMenu.dart';
import 'package:songtube/internal/languages.dart';
import 'package:songtube/lib.dart';
import 'package:songtube/pages/channel.dart';
import 'package:songtube/provider/managerProvider.dart';
import 'package:songtube/provider/mediaProvider.dart';
import 'package:songtube/provider/preferencesProvider.dart';
import 'package:songtube/provider/videoPageProvider.dart';
import 'package:songtube/ui/animations/blurPageRoute.dart';
import 'package:songtube/ui/animations/fadeIn.dart';
import 'package:songtube/ui/components/addToPlaylist.dart';
import 'package:songtube/ui/components/shimmerContainer.dart';
import 'package:songtube/ui/dialogs/loadingDialog.dart';
import 'package:songtube/ui/internal/popupMenu.dart';
import 'package:songtube/ui/internal/snackbar.dart';
import 'package:transparent_image/transparent_image.dart';

class StreamsLargeThumbnailView extends StatelessWidget {
  final List<dynamic> infoItems;
  final bool shrinkWrap;
  final Function(dynamic) onDelete;
  final bool allowSaveToFavorites;
  final bool allowSaveToWatchLater;
  final Function onReachingListEnd;
  StreamsLargeThumbnailView({
    @required this.infoItems,
    this.shrinkWrap = false,
    this.onDelete,
    this.allowSaveToFavorites = true,
    this.allowSaveToWatchLater = true,
    this.onReachingListEnd
  });
  @override
  Widget build(BuildContext context) {
    if (infoItems.isNotEmpty) {
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          double maxScroll = notification.metrics.maxScrollExtent;
          double currentScroll = notification.metrics.pixels;
          double delta = 200.0;
          if ( maxScroll - currentScroll <= delta)
            onReachingListEnd();
          return false;
        },
        child: ListView.builder(
          itemCount: infoItems.length,
          itemBuilder: (context, index) {
            dynamic infoItem = infoItems[index];
            return FadeInTransition(
              duration: Duration(milliseconds: 300),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 16, top: index == 0 ? 12 : 0,
                  left: 12, right: 12
                ),
                child: Consumer<VideoPageProvider>(
                  builder: (context, provider, child) {
                    return GestureDetector(
                      onTap: () {
                        if (infoItem is StreamInfoItem || infoItem is PlaylistInfoItem) {
                          provider.infoItem = infoItem;
                        } else {
                          Navigator.push(context,
                            BlurPageRoute(
                              blurStrength: Provider.of<PreferencesProvider>
                                (context, listen: false).enableBlurUI ? 20 : 0,
                              builder: (_) => 
                              YoutubeChannelPage(
                                url: infoItem.url,
                                name: infoItem.name,
                          )));
                        }
                      },
                      child: child,
                    );
                  },
                  child: infoItem is ChannelInfoItem
                    ? _channelWidget(context, infoItem)
                    : Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _thumbnailWidget(context, infoItem)
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: _infoItemDetails(context, infoItem),
                          )
                        ],
                      )
                ),
              ),
            );
          }
        ),
      );
    } else {
      return ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              top: index == 0 ? 12 : 0
            ),
            child: _shimmerTile(context),
          );
        },
      );
    }
  }

  Widget _channelWidget(BuildContext context, infoItem) {
    ChannelInfoItem channel = infoItem;
    return Row(
      children: [
        FutureBuilder(
          future: _getChannelLogoUrl(channel.url, highRes: true),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: FadeInImage(
                  fadeInDuration: Duration(milliseconds: 300),
                  placeholder: MemoryImage(kTransparentImage),
                  image: NetworkImage(snapshot.data),
                  height: 80,
                  width: 80,
                ),
              );
            } else {
              return ShimmerContainer(
                height: 80,
                width: 80,
                borderRadius: BorderRadius.circular(100),
              );
            }
          },
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                channel.name,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1.color,
                  fontSize: 18,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2
                ),
              ),
              Text(
                "${NumberFormat().format(channel.subscriberCount)} Subs • ${channel.streamCount} videos",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1.color,
                  fontSize: 12,
                  fontFamily: 'Product Sans',
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _thumbnailWidget(BuildContext context, infoItem) {
    bool isSongDownloaded = _isSongDownloaded(context, infoItem.name);
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(
          aspectRatio: 16/9,
          child: Transform.scale(
            scale: 1.01,
            child: FadeInImage(
              fadeInDuration: Duration(milliseconds: 200),
              placeholder: MemoryImage(kTransparentImage),
              image: NetworkImage(
                infoItem is StreamInfoItem
                  ? infoItem.thumbnails.hqdefault
                  : (infoItem as PlaylistInfoItem).thumbnailUrl
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (infoItem is StreamInfoItem)
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            margin: EdgeInsets.only(right: 10, bottom: isSongDownloaded ? 40 : 10),
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(3)
            ),
            child: Text(
              "${Duration(seconds: infoItem.duration).inMinutes}:" +
              "${Duration(seconds: infoItem.duration).inSeconds.remainder(60).toString().padRight(2, "0")}",
              style: TextStyle(
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 10
              ),
            )
          ),
        ),
        if (infoItem is PlaylistInfoItem)
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)
            )
          ),
          height: 25,
          child: Center(
            child: Icon(EvaIcons.musicOutline,
              color: Colors.white, size: 20),
          ),
        ),
        if(isSongDownloaded)
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
                margin: EdgeInsets.only(right: 10, bottom: 10),
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(3)),
                child: Text(
                  "Downloaded",
                  style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 13),
                )),
          ),
      ],
    );
  }

  bool _isSongDownloaded(BuildContext context, String name){
    if(name == null){
      return false;
    }else if(name == ""){
      return false;
    }else{
      MediaProvider mediaProvider = Provider.of<MediaProvider>(context, listen: false);
      List<MediaItem> list = mediaProvider.databaseSongs;
      for(MediaItem item in list){
        if(item.title == name || item.title == name.replaceAll("|", "")){
          return true;
        }
      }
    }
    return false;
  }

  Widget _infoItemDetails(BuildContext context, infoItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        infoItem is StreamInfoItem
          ? FutureBuilder(
              future: _getChannelLogoUrl(infoItem.uploaderUrl),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                        BlurPageRoute(
                          blurStrength: Provider.of<PreferencesProvider>
                            (context, listen: false).enableBlurUI ? 20 : 0,
                          builder: (_) => 
                          YoutubeChannelPage(
                            url: infoItem.uploaderUrl,
                            name: infoItem.uploaderName,
                            lowResAvatar: snapshot.data,
                            heroTag: infoItem.uploaderUrl + infoItem.id,
                      )));
                    },
                    child: Hero(
                      tag: infoItem.uploaderUrl + infoItem.id,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: FadeInImage(
                          fadeInDuration: Duration(milliseconds: 300),
                          placeholder: MemoryImage(kTransparentImage),
                          image: NetworkImage(snapshot.data),
                          fit: BoxFit.cover,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ),
                  );
                } else {
                  return ShimmerContainer(
                    height: 50,
                    width: 50,
                    borderRadius: BorderRadius.circular(100),
                  );
                }
              },
            )
          : Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(100)
              ),
              child: Icon(
                Icons.playlist_play_outlined,
                color: Theme.of(context).iconTheme.color,
                size: 32,
              ),
            ),
        SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${infoItem.name}",
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${infoItem.uploaderName}" +
                  (infoItem is StreamInfoItem
                    ? "${infoItem.viewCount != -1 ? " • " + NumberFormat.compact().format(infoItem.viewCount) + " views" : ""}"
                      " ${infoItem.uploadDate == null ? "" : " • " + infoItem.uploadDate}"
                    : ""),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyText1.color
                      .withOpacity(0.8)
                  ),
                )
              ],
            ),
          ),
        ),
        _flexiblePopupMenu(context, infoItem)
      ],
    );
  }

  Future<String> _getChannelLogoUrl(url, {bool highRes = false}) async {
    if (highRes) {
      String id = (await YoutubeId.getIdFromChannelUrl(url)).split("/").last;
      return await ChannelExtractor.getAvatarUrl(id);
    } else {
      YoutubeChannel channel = await ChannelExtractor.channelInfo(url);
      return channel.avatarUrl;
    }
  }

  Widget _shimmerTile(context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 12, right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Shimmer.fromColors(
                baseColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
                highlightColor: Theme.of(context).cardColor,
                child: AspectRatio(
                  aspectRatio: 16/9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 4),
            child: Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
                  highlightColor: Theme.of(context).cardColor,
                  child: Container(
                    height: 60,
                    width: 60,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Theme.of(context).scaffoldBackgroundColor
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Shimmer.fromColors(
                        baseColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
                        highlightColor: Theme.of(context).cardColor,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).scaffoldBackgroundColor
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Shimmer.fromColors(
                        baseColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
                        highlightColor: Theme.of(context).cardColor,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).scaffoldBackgroundColor
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _flexiblePopupMenu(BuildContext context, infoItem) {
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    return FlexiblePopupMenu(
      items: [
        FlexiblePopupItem(
          title: Languages.of(context).labelShare,
          value: "Share"
        ),
        FlexiblePopupItem(
          title: Languages.of(context).labelCopyLink,
          value: "CopyLink"
        ),
        if (infoItem is StreamInfoItem && Lib.DOWNLOADING_ENABLED)
        FlexiblePopupItem(
          title: Languages.of(context).labelDownload,
          value: "Download"
        ),
        if (onDelete != null)
        FlexiblePopupItem(
          title: Languages.of(context).labelRemove,
          value: "Remove"
        ),
        FlexiblePopupItem(
          title: Languages.of(context).labelAddToPlaylist,
          value: "AddPlaylist"
        ),
      ],
      onItemTap: (String value) async {
        switch(value) {
          case "Share":
            Share.share(
              infoItem.url
            );
            break;
          case "CopyLink":
            Clipboard.setData(ClipboardData(
              text: infoItem.url
            ));
            final scaffold = Scaffold.of(context);
            AppSnack.showSnackBar(
              icon: Icons.copy,
              title: "Link copied to Clipboard",
              duration: Duration(seconds: 2),
              context: context,
            );
            break;
          case "Download":
            showModalBottomSheet<dynamic>(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30)
                ),
              ),
              clipBehavior: Clip.antiAlias,
              context: context,
              builder: (context) {
                String url = infoItem.url;
                return Wrap(
                  children: [
                    Consumer<ManagerProvider>(
                      builder: (context, provider, _) {
                        return DownloadMenu(
                          videoUrl: url,
                          scaffoldState: provider
                            .internalScaffoldKey.currentState,
                        );
                      }
                    ),
                  ],
                );
              }
            );
            break;
          case "Remove":
            onDelete(infoItem);
            break;
          case "AddPlaylist":
            if (infoItem is StreamInfoItem) {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)
                  )
                ),
                builder: (context) {
                  return AddStreamToPlaylistSheet(stream: infoItem);
                }
              );
            } else {
              PlaylistInfoItem playlist = infoItem as PlaylistInfoItem;
              if (prefs.streamPlaylists.indexWhere((element) => element.name == playlist.name) != -1) {
                AppSnack.showSnackBar(
                  icon: Icons.warning_rounded,
                  title: Languages.of(context).labelCancelled,
                  message: "Playlist already exists!",
                  context: context,
                );
                return;
              }
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return LoadingDialog();
                }
              );
              prefs.streamPlaylistCreate(
                playlist.name,
                playlist.uploaderName,
                await PlaylistExtractor.getPlaylistStreams(playlist.url)
              );
              Navigator.pop(context);
              AppSnack.showSnackBar(
                icon: Icons.playlist_add_check_rounded,
                title: Languages.of(context).labelCompleted,
                message: "Playlist saved successfully!",
                context: context,
              );
            }
            break;
          }
      },
      borderRadius: 10,
      child: Container(
        padding: EdgeInsets.all(4),
        color: Colors.transparent,
        child: Icon(Icons.more_vert_rounded,
          size: 16),
      ),
    );
  }

}