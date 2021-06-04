import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_pip/flutter_pip.dart';
import 'package:flutter_pip/models/pip_ratio.dart';
import 'package:flutter_pip/platform_channel/channel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:newpipeextractor_dart/models/infoItems/playlist.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/models/playlist.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/languages.dart';
import 'package:songtube/internal/musicBrainzApi.dart';
import 'package:songtube/internal/radioStreamingController.dart';
import 'package:songtube/lib.dart';
import 'package:songtube/pages/channel.dart';
import 'package:songtube/players/components/youtubePlayer/ui/comments.dart';
import 'package:songtube/players/components/youtubePlayer/videoPlayer.dart';
import 'package:songtube/players/service/playerService.dart';
import 'package:songtube/provider/mediaProvider.dart';
import 'package:songtube/provider/preferencesProvider.dart';
import 'package:songtube/pages/components/video/shimmer/shimmerVideoEngagement.dart';
import 'package:songtube/players/components/youtubePlayer/ui/fab.dart';
import 'package:songtube/players/components/youtubePlayer/ui/tags.dart';
import 'package:songtube/downloadMenu/downloadMenu.dart';
import 'package:songtube/provider/videoPageProvider.dart';
import 'package:songtube/ui/animations/blurPageRoute.dart';
import 'package:songtube/ui/animations/fadeIn.dart';
import 'package:songtube/ui/components/addToPlaylist.dart';
import 'package:songtube/ui/components/measureSize.dart';
import 'package:songtube/ui/components/tagsResultsPage.dart';
import 'package:songtube/ui/dialogs/loadingDialog.dart';
import 'package:songtube/ui/internal/lifecycleEvents.dart' as lifeCycle;
import 'package:songtube/ui/internal/snackbar.dart';
import 'package:flutter_screen/flutter_screen.dart';
import 'package:songtube/ui/layout/streamsListTile.dart';
import 'package:transparent_image/transparent_image.dart';

import 'ui/details.dart';
import 'ui/engagement.dart';

class YoutubePlayerVideoPage extends StatefulWidget {
  @override
  _YoutubePlayerVideoPageState createState() => _YoutubePlayerVideoPageState();
}

class _YoutubePlayerVideoPageState extends State<YoutubePlayerVideoPage>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey;

  // Player Height
  double playerHeight = 0;

  // Pip Status
  bool isInPictureInPictureMode = false;

  @override
  void initState() {
    super.initState();
    scaffoldKey = GlobalKey<ScaffoldState>();
    KeyboardVisibility.onChange.listen((bool visible) {
      if (mounted) {
        if (visible == false)
          FocusScope.of(context).requestFocus(new FocusNode());
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<VideoPageProvider>(context, listen: false)
          .fwController
          .open();
    });
  }

  void executeAutoPlay() {
    VideoPageProvider pageProvider =
        Provider.of<VideoPageProvider>(context, listen: false);
    StreamInfoItem currentStream = pageProvider.infoItem;
    bool isPlaylist = pageProvider.isPlaylist;
    if (isPlaylist) {
      int currentIndex =
          pageProvider.currentRelatedVideos.indexOf(currentStream);
      if (currentIndex + 1 <= pageProvider.currentRelatedVideos.length) {
        pageProvider.infoItem =
            pageProvider.currentRelatedVideos[currentIndex + 1];
      }
    } else {
      //pageProvider.currentRelatedVideos[0].getVideo.then((value) => {
        pageProvider.infoItem = pageProvider.currentRelatedVideos[0];
      //});

    }
  }

  @override
  Widget build(BuildContext context) {
    return PipWidget(
      onResume: (bool pipMode) {
        setState(() => isInPictureInPictureMode = pipMode);
      },
      child: Scaffold(
          key: scaffoldKey,
          body: _currentWidget(),
          floatingActionButton: _fab()),
    );
  }

  Widget _currentWidget() {
    if (isInPictureInPictureMode) {
      return _pipWidget();
    } else if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return _portraitPage();
    } else {
      return _fullscreenPage();
    }
  }

  Widget _videoPlayerWidget() {
    VideoPageProvider pageProvider = Provider.of<VideoPageProvider>(context);
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    return StreamManifestPlayer(
      quality: prefs.youtubePlayerQuality,
      onQualityChanged: (String quality) {
        prefs.youtubePlayerQuality = quality;
      },
      borderRadius:
          MediaQuery.of(context).orientation == Orientation.landscape ? 0 : 10,
      key: pageProvider.playerKey,
      videoTitle: pageProvider?.currentVideo?.name ?? "",
      streams: pageProvider.currentVideo.videoOnlyStreams,
      audioStream: pageProvider.currentVideo
          .getAudioStreamWithBestMatchForVideoStream(
              pageProvider.currentVideo.videoOnlyWithHighestQuality),
      isFullscreen: MediaQuery.of(context).orientation == Orientation.landscape
          ? true
          : false,
      onVideoEnded: () async {
        print("VIDEO ENDED");
        print("Is in app?: " +
            lifeCycle.LifecycleEventHandler.isAppActive.toString());
        if (lifeCycle.LifecycleEventHandler.isAppActive) {
          if (prefs.youtubeAutoPlay) {
            if (mounted) executeAutoPlay();
          }
        } else {
          prefs.youtubeAutoPlay = false;
        }
      },
      onFullscreenTap: () {
        if (MediaQuery.of(context).orientation == Orientation.landscape) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          SystemChrome.setEnabledSystemUIOverlays(
              [SystemUiOverlay.top, SystemUiOverlay.bottom]);
        } else {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
          SystemChrome.setEnabledSystemUIOverlays([]);
        }
      },
      onEnterPipMode: () {
        setState(() => isInPictureInPictureMode = true);
        FlutterPip.enterPictureInPictureMode();
      },
    );
  }

  Widget _pipWidget() {
    VideoPageProvider pageProvider = Provider.of<VideoPageProvider>(context);
    pageProvider.playerKey?.currentState?.controller?.play();
    pageProvider.fwController.open();
    FlutterScreen.resetBrightness();
    return AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        child: pageProvider.currentVideo != null
            ? _videoPlayerWidget()
            : _videoLoading(pageProvider.infoItem.thumbnails.hqdefault));
  }

  Widget _fullscreenPage() {
    VideoPageProvider pageProvider = Provider.of<VideoPageProvider>(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    return AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        child: pageProvider.currentVideo != null
            ? _videoPlayerWidget()
            : _videoLoading(pageProvider.infoItem.thumbnails.hqdefault));
  }

  Widget _portraitPage() {
    VideoPageProvider pageProvider = Provider.of<VideoPageProvider>(context);
    bool isPlaylist = pageProvider.isPlaylist;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    FlutterScreen.resetBrightness();
    return isPlaylist ? _portraitPlaylistPage() : _portraitVideoPage();
  }

  Widget _portraitVideoPage() {
    VideoPageProvider pageProvider = Provider.of<VideoPageProvider>(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    FlutterScreen.resetBrightness();
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.bottom,
              padding: EdgeInsets.only(top: 4),
              child: Column(children: <Widget>[
                // Top StatusBar Padding
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  height: MediaQuery.of(context).padding.top,
                  width: double.infinity,
                ),
                // Mini-Player
                Container(
                  margin: EdgeInsets.only(left: 12, right: 12),
                  child: MeasureSize(
                    onChange: (Size size) {
                      playerHeight = size.height;
                    },
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          child: pageProvider.currentVideo != null
                              ? _videoPlayerWidget()
                              : _videoLoading(
                                  pageProvider.infoItem is StreamInfoItem
                                      ? pageProvider
                                          .infoItem.thumbnails.hqdefault
                                      : pageProvider.infoItem
                                              is PlaylistInfoItem
                                          ? pageProvider.infoItem.thumbnailUrl
                                          : null,
                                )),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // Video Details
                VideoDetails(
                    infoItem: pageProvider.infoItem,
                    uploaderAvatarUrl:
                        pageProvider.currentChannel?.avatarUrl ?? null,
                    views: pageProvider.currentVideo?.viewCount ?? 0),
                // ---------------------------------------
                // Likes, dislikes, Views and Share button
                // ---------------------------------------
                _videoEngagementWidget(),
                Divider(height: 1),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        SizedBox(height: 4),
                        // Tags Editor (Not available on Playlists)
                        _isSongDownloadedPlay(pageProvider.infoItem, context),
                        /*AnimatedSize(
                            vsync: this,
                            duration: Duration(milliseconds: 300),
                            child: VideoTags(
                              tags: pageProvider.currentTags,
                              infoItem: pageProvider.infoItem is StreamInfoItem
                                ? pageProvider.infoItem : null,
                              onAutoTag: () async {
                                showDialog(
                                  context: context,
                                  builder: (_) => LoadingDialog()
                                );
                                String lastArtwork = pageProvider.currentTags.artworkController;
                                var record = await MusicBrainzAPI
                                  .getFirstRecord(pageProvider.currentTags.titleController.text);
                                pageProvider.currentTags = await MusicBrainzAPI.getSongTags(record);
                                if (pageProvider.currentTags.artworkController == null)
                                  pageProvider.currentTags.artworkController = lastArtwork;
                                Navigator.pop(context);
                                setState(() {});
                              },
                              onManualTag: () async {
                                var record = await Navigator.push(context,
                                  BlurPageRoute(builder: (context) =>
                                    TagsResultsPage(
                                      title: pageProvider.currentTags.titleController.text,
                                      artist: pageProvider.currentTags.artistController.text
                                    ),
                                    blurStrength: Provider.of<PreferencesProvider>
                                      (context, listen: false).enableBlurUI ? 20 : 0));
                                if (record == null) return;
                                showDialog(
                                  context: context,
                                  builder: (_) => LoadingDialog()
                                );
                                String lastArtwork = pageProvider.currentTags.artworkController;
                                pageProvider.currentTags = await MusicBrainzAPI.getSongTags(record);
                                if (pageProvider.currentTags.artworkController == null)
                                  pageProvider.currentTags.artworkController = lastArtwork;
                                Navigator.pop(context);
                                setState(() {});
                              },
                              onSearchDevice: () async {
                                File image = File((await FilePicker.platform
                                  .pickFiles(type: FileType.image))
                                  .paths[0]);
                                if (image == null) return;
                                pageProvider.currentTags.artworkController = image.path;
                                setState(() {});
                              },
                            ),
                          ),*/
                        SizedBox(height: 4),
                        // AutoPlay Widget
                        _autoPlayWidget(),
                        // Related Videos
                        StreamsListTileView(
                          shrinkWrap: true,
                          removePhysics: true,
                          streams: pageProvider?.currentRelatedVideos == null
                              ? []
                              : pageProvider.currentRelatedVideos,
                          onTap: (stream, index) async {
                            pageProvider.infoItem =
                                pageProvider.currentRelatedVideos[index];
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
        Container(
            height: MediaQuery.of(context).padding.bottom,
            color: Theme.of(context).cardColor)
      ],
    );
  }

  Widget _portraitPlaylistPage() {
    VideoPageProvider pageProvider = Provider.of<VideoPageProvider>(context);
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    FlutterScreen.resetBrightness();
    YoutubePlaylist playlist = pageProvider.currentPlaylist;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.bottom,
              padding: EdgeInsets.only(top: 4),
              child: Column(children: <Widget>[
                // Top StatusBar Padding
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  height: MediaQuery.of(context).padding.top,
                  width: double.infinity,
                ),
                // Mini-Player
                Container(
                  margin: EdgeInsets.only(left: 12, right: 12),
                  child: MeasureSize(
                    onChange: (Size size) {
                      playerHeight = size.height;
                    },
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          child: pageProvider.currentVideo != null
                              ? _videoPlayerWidget()
                              : _videoLoading(
                                  pageProvider.infoItem is StreamInfoItem
                                      ? pageProvider
                                          .infoItem.thumbnails.hqdefault
                                      : pageProvider.infoItem
                                              is PlaylistInfoItem
                                          ? pageProvider.infoItem.thumbnailUrl
                                          : null,
                                )),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // Video Details
                VideoDetails(
                  infoItem: pageProvider.infoItem,
                  uploaderAvatarUrl:
                      pageProvider.currentChannel?.avatarUrl ?? null,
                  views: pageProvider.currentVideo?.viewCount ?? 0,
                ),
                // ---------------------------------------
                // Likes, dislikes, Views and Share button
                // ---------------------------------------
                _videoEngagementWidget(),
                Divider(height: 1),
                // Playlist & Videos
                Container(
                  padding:
                      EdgeInsets.only(top: 16, bottom: 16, right: 24, left: 12),
                  child: Row(
                    children: [
                      Icon(MdiIcons.playlistMusicOutline, size: 28),
                      SizedBox(width: 8),
                      Text(
                        Languages.of(context).labelPlaylist,
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .color
                                .withOpacity(0.7)),
                      ),
                      Spacer(),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: playlist != null
                            ? Container(
                                height: 24,
                                width: 24,
                                color: Colors.transparent,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(EvaIcons.heart,
                                      color: prefs.streamPlaylists.indexWhere(
                                                  (element) =>
                                                      element.author +
                                                          element.name ==
                                                      playlist.uploaderName +
                                                          playlist.name) ==
                                              -1
                                          ? Theme.of(context).iconTheme.color
                                          : Colors.red),
                                  onPressed: () {
                                    if (prefs.streamPlaylists.indexWhere(
                                            (element) =>
                                                element.author + element.name ==
                                                playlist.uploaderName +
                                                    playlist.name) ==
                                        -1) {
                                      prefs.streamPlaylistCreate(
                                          playlist.name,
                                          playlist.uploaderName,
                                          playlist.streams);
                                      AppSnack.showSnackBar(
                                          icon: EvaIcons.heart,
                                          title: Languages.of(context)
                                              .labelPlaylist,
                                          message: "${playlist.name}",
                                          context: context,
                                          scaffoldKey:
                                              scaffoldKey.currentState);
                                    } else {
                                      prefs.streamPlaylistRemove(playlist.name);
                                    }
                                  },
                                ),
                              )
                            : Container(),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        StreamsListTileView(
                          shrinkWrap: true,
                          removePhysics: true,
                          topPadding: false,
                          streams: pageProvider?.currentRelatedVideos == null
                              ? []
                              : pageProvider.currentRelatedVideos,
                          onTap: (stream, index) async {
                            pageProvider.infoItem =
                                pageProvider.currentRelatedVideos[index];
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
        Container(
            height: MediaQuery.of(context).padding.bottom,
            color: Theme.of(context).cardColor)
      ],
    );
  }

  Widget _fab() {
    VideoPageProvider pageProvider = Provider.of<VideoPageProvider>(context);
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait &&
          Lib.DOWNLOADING_ENABLED &&
          false) {
        return VideoDownloadFab(
          readyToDownload: pageProvider.currentVideo == null ? false : true,
          onDownload: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            showModalBottomSheet<dynamic>(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                clipBehavior: Clip.antiAlias,
                context: context,
                builder: (context) {
                  return Wrap(
                    children: [
                      DownloadMenu(
                          video: pageProvider.currentVideo,
                          tags: pageProvider.currentTags,
                          scaffoldState: scaffoldKey.currentState,
                          relatedVideos: pageProvider.currentRelatedVideos),
                    ],
                  );
                });
          },
        );
      } else {
        return Container();
      }
    });
  }

  Widget _videoEngagementWidget() {
    VideoPageProvider pageProvider = Provider.of<VideoPageProvider>(context);
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    return AnimatedSize(
      vsync: this,
      duration: Duration(milliseconds: 300),
      child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: pageProvider.currentVideo != null
              ? ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 8),
                    VideoEngagement(
                      video: pageProvider.currentVideo,
                      likeCount: pageProvider.currentVideo.likeCount,
                      dislikeCount: pageProvider.currentVideo.dislikeCount,
                      viewCount: pageProvider.currentVideo.viewCount,
                      onSaveToPlaylist: () {
                        showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15))),
                            builder: (context) {
                              return AddStreamToPlaylistSheet(
                                  stream: pageProvider.infoItem);
                            });
                      },
                      onOpenComments: () {
                        double topPadding = MediaQuery.of(context).padding.top;
                        scaffoldKey.currentState.showBottomSheet((context) {
                          return VideoComments(
                            infoItem: pageProvider.infoItem,
                            topPadding: topPadding + playerHeight + 8,
                          );
                        });
                      },
                    ),
                    SizedBox(height: 8),
                  ],
                )
              : ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 12),
                    const ShimmerVideoEngagement(),
                  ],
                )),
    );
  }

  Widget _autoPlayWidget() {
    VideoPageProvider pageProvider = Provider.of<VideoPageProvider>(context);
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    bool isPlaylist = pageProvider.isPlaylist;
    List<StreamInfoItem> related = pageProvider?.currentRelatedVideos == null
        ? []
        : pageProvider.currentRelatedVideos;
    return Container(
      margin: EdgeInsets.only(bottom: 12, top: 8),
      height: 20,
      child: Row(
        children: [
          SizedBox(width: 16),
          Text(
            !isPlaylist
                ? Languages.of(context).labelRelated
                : Languages.of(context).labelPlaylist,
            style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyText1.color,
                fontFamily: 'YTSans'),
            textAlign: TextAlign.left,
          ),
          SizedBox(width: 8),
          AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: related.isEmpty
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                      ))
                  : Container()),
          Spacer(),
          Text(
            Languages.of(context).labelAutoPlay,
            style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyText1.color,
                fontFamily: 'YTSans'),
            textAlign: TextAlign.left,
          ),
          Switch(
              activeColor: Theme.of(context).accentColor,
              value: prefs.youtubeAutoPlay,
              onChanged: (bool value) {
                prefs.youtubeAutoPlay = value;
              }),
          SizedBox(width: 4)
        ],
      ),
    );
  }

  Widget _isSongDownloadedPlay(StreamInfoItem infoItem, BuildContext context) {
    PreferencesProvider prefs =
        Provider.of<PreferencesProvider>(context, listen: false);
    MediaProvider mediaProvider = Provider.of<MediaProvider>(context);
    List<MediaItem> list = mediaProvider.databaseSongs;
    for (MediaItem item in list) {
      if (item.title == infoItem.name) {
        return Column(
          children: [
            Row(
              children: [
                SizedBox(width: 18),
                Expanded(
                  child: Text(
                    "You have already downloaded this video. Play in audio player to save data?",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color,
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w400),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      print("Playing music while radio is on: " +
                          StreamingController.IS_PLAYING.toString());
                      if (StreamingController.IS_PLAYING) {
                        var streamingController = StreamingController();
                        StreamingController.IS_PLAYING = false;
                        streamingController.stop();
                      }
                    } on Exception catch (_) {
                      print('Trying shut down radio');
                    }
                    if (!AudioService.running) {
                      await AudioService.start(
                        backgroundTaskEntrypoint: songtubePlayer,
                        androidNotificationChannelName: 'SongTube',
                        // Enable this if you want the Android service to exit the foreground state on pause.
                        //androidStopForegroundOnPause: true,
                        androidNotificationColor: 0xFF2196f3,
                        androidNotificationIcon: 'drawable/ic_stat_music_note',
                        androidEnableQueue: true,
                      );
                    }

                    if (listEquals(list, AudioService.queue) == false) {
                      await AudioService.updateQueue(list);
                    }
                    VideoPageProvider tmp =
                        Provider.of<VideoPageProvider>(context, listen: false);
                    await AudioService.playMediaItem(item)
                        .then((value) => {tmp.closeVideoPanel()});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Theme.of(context).accentColor,
                    ),
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(right: 10, top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Icon(Icons.music_note,
                            color: Theme.of(context).iconTheme.color, size: 18),
                        SizedBox(width: 4),
                        Text("Play"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 1,
            ),
          ],
        );
      }
    }
    return Column(
      children: [
        ListTile(
          isThreeLine: false,
          subtitle: Text(
              "Are you experiencing troubles with playing this video? This will reload the video and complete video player.",
              style: TextStyle(fontSize: 12)),
          title: Text(
            "Reload video",
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1.color,
                fontWeight: FontWeight.w500),
          ),
          trailing: GestureDetector(
            onTap: () async {
              print("RELOADING VIDEO " + infoItem.name);
              VideoPageProvider pageProvider =
                  Provider.of<VideoPageProvider>(context, listen: false);
              pageProvider.closeVideoPanel();
              infoItem.getVideo.then((value) => {
                    //pageProvider.currentVideo = value,
                    if (infoItem is StreamInfoItem ||
                        infoItem is PlaylistInfoItem)
                      {
                        pageProvider.infoItem = infoItem,
                      }
                    else
                      {
                        Navigator.push(
                          context,
                          BlurPageRoute(
                            blurStrength: Provider.of<PreferencesProvider>(
                                        context,
                                        listen: false)
                                    .enableBlurUI
                                ? 20
                                : 0,
                            builder: (_) => YoutubeChannelPage(
                              url: infoItem.url,
                              name: infoItem.name,
                            ),
                          ),
                        ),
                      }
                  });
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).scaffoldBackgroundColor),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.refresh,
                    color: Theme.of(context).iconTheme.color, size: 24),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Divider(
          height: 1,
        ),
      ],
    );
  }

  Widget _videoLoading(String thumbnailUrl) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: FadeInImage(
            fadeInDuration: Duration(milliseconds: 250),
            placeholder: MemoryImage(kTransparentImage),
            image: thumbnailUrl == null
                ? MemoryImage(kTransparentImage)
                : NetworkImage(thumbnailUrl),
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      ],
    );
  }
}
