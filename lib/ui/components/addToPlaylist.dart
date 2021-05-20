import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/languages.dart';
import 'package:songtube/internal/models/playlist.dart';
import 'package:songtube/lib.dart';
import 'package:songtube/provider/mediaProvider.dart';
import 'package:songtube/provider/preferencesProvider.dart';

class AddStreamToPlaylistSheet extends StatefulWidget {
  final StreamInfoItem stream;

  AddStreamToPlaylistSheet({@required this.stream});

  @override
  _AddStreamToPlaylistSheetState createState() =>
      _AddStreamToPlaylistSheetState();
}

class _AddStreamToPlaylistSheetState extends State<AddStreamToPlaylistSheet>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    return Wrap(
      children: [
        Container(
          height: kToolbarHeight * 1.1,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded,
                    color: Theme.of(context).iconTheme.color),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Languages.of(context).labelAddToPlaylist,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1.color,
                          fontSize: 18,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      widget.stream.name,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color,
                        fontSize: 12,
                        fontFamily: 'Product Sans',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 32)
            ],
          ),
        ),
        Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[600].withOpacity(0.1),
            indent: 12,
            endIndent: 12),
        CheckboxListTile(
            contentPadding: EdgeInsets.only(left: 32, right: 16),
            title: Text(
              Languages.of(context).labelFavorites,
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .color
                      .withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            value: prefs.favoriteHasVideo(widget.stream),
            onChanged: (_) {
              if (!prefs.favoriteHasVideo(widget.stream)) {
                List<StreamInfoItem> videos = prefs.favoriteVideos;
                videos.add(widget.stream);
                prefs.favoriteVideos = videos;
              } else {
                List<StreamInfoItem> videos = prefs.favoriteVideos;
                videos.removeWhere((element) => element.id == widget.stream.id);
                prefs.favoriteVideos = videos;
              }
            }),
        Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[600].withOpacity(0.1),
            indent: 12,
            endIndent: 12),
        Container(
          height: kToolbarHeight * 1.1,
          child: Row(
            children: [
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Audio playlists",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1.color,
                      fontSize: 16,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  String name = await showDialog(
                      context: context,
                      builder: (context) {
                        return CreatePlaylistDialog();
                      });
                  if (name != null) {
                    if(prefs.audioPlaylists.contains(name)){
                      print("Playlist " + name + " already exist");
                      return;
                    }
                    print("New playlist created: " + name);
                    List<String> list = prefs.audioPlaylists;
                    list.add(name);
                    prefs.audioPlaylists = list;
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      Icon(Icons.add_rounded,
                          color: Theme.of(context).iconTheme.color, size: 18),
                      SizedBox(width: 4),
                      Text(
                        Languages.of(context).labelCreate,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1.color,
                            fontSize: 14,
                            fontFamily: 'Product Sans',
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[600].withOpacity(0.1),
            indent: 12,
            endIndent: 12),
        if (prefs.audioPlaylists.isNotEmpty)
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            vsync: this,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: prefs.audioPlaylists.length,
              itemBuilder: (context, index) {
                String playlist = prefs.audioPlaylists[index];
                return Container(
                  child: Row(
                    children: [
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          playlist,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1.color,
                              fontSize: 14,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          int fun = _getFunctionJobPlaylist(
                              context, playlist, widget.stream.name);
                          prefs.printSongsInPlaylist(playlist);
                          List<String> songs =
                              prefs.getSongsForPlaylist(playlist);
                          if (fun == 1) {
                            print("Removing " +
                                widget.stream.name +
                                " from " +
                                playlist);
                            songs.remove(widget.stream.name);
                            prefs.setSongsForPlaylist(playlist, songs);
                          } else if (fun == 2) {
                            print("Adding " +
                                widget.stream.name +
                                " to " +
                                playlist);
                            songs.add(widget.stream.name);
                            prefs.setSongsForPlaylist(playlist, songs);
                          } else {
                            //Download & Add
                          }
                          setState(() {
                            _AddStreamToPlaylistSheetState createState() =>
                                _AddStreamToPlaylistSheetState();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.only(right: 16),
                          child: Row(
                            children: [
                              Icon(
                                  !_isSongInPlaylist(
                                          context, widget.stream.name, playlist)
                                      ? Icons.add_rounded
                                      : Icons.remove,
                                  color: Theme.of(context).iconTheme.color,
                                  size: 18),
                              SizedBox(width: 4),
                              _getFunctionTextPlaylist(
                                  context, playlist, widget.stream.name),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(bottom: 10, top: index == 0 ? 10 : 0),
                );
              },
            ),
          ),
        Container(
            height: MediaQuery.of(context).padding.bottom,
            color: Theme.of(context).cardColor)
      ],
    );
  }

  bool _isSongDownloaded(BuildContext context, String songName) {
    MediaProvider mediaProvider =
        Provider.of<MediaProvider>(context, listen: false);
    List<MediaItem> list = mediaProvider.databaseSongs;
    for (MediaItem item in list) {
      if (item.title == songName || item.title == songName.replaceAll("|", ""))
        return true;
    }
    return false;
  }

  bool _isSongInPlaylist(
      BuildContext context, String songName, String playlistName) {
    PreferencesProvider prefs =
        Provider.of<PreferencesProvider>(context, listen: false);
    List<String> list = prefs.getSongsForPlaylist(playlistName);
    for (String s in list) {
      if (s == songName) {
        return true;
      }
    }
    return false;
  }

  int _getFunctionJobPlaylist(
      BuildContext context, String playlist, String songName) {
    bool isDownloaded = _isSongDownloaded(context, songName);
    bool isInPlaylist = _isSongInPlaylist(context, songName, playlist);
    if (isDownloaded) {
      if (isInPlaylist) {
        return 1; //Remove
      } else {
        return 2; //Add
      }
    } else {
      if (Lib.DOWNLOADING_ENABLED) {
        return 3; //Download & Add
      }
    }
    return 0;
  }

  Widget _getFunctionTextPlaylist(
      BuildContext context, String playlist, String songName) {
    bool isDownloaded = _isSongDownloaded(context, songName);
    bool isInPlaylist = _isSongInPlaylist(context, songName, playlist);
    if (isDownloaded) {
      if (isInPlaylist) {
        return Text(
          "Remove",
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              fontSize: 14,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w600),
        );
      } else {
        return Text(
          "Add",
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              fontSize: 14,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w600),
        );
      }
    } else {
      if (Lib.DOWNLOADING_ENABLED) {
        return Text(
          "Download & Add",
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              fontSize: 14,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w600),
        );
      } else {
        return Text(
          "Only downloaded songs can be added",
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              fontSize: 14,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w600),
        );
      }
    }
  }
}

class CreatePlaylistDialog extends StatefulWidget {
  @override
  _CreatePlaylistDialogState createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text(
        Languages.of(context).labelCreate +
            " " +
            Languages.of(context).labelPlaylist,
        style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10)),
            child: TextField(
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1.color,
                  fontSize: 14),
              controller: controller,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(14.0),
                hintText: Languages.of(context).labelEditorTitle,
                hintStyle: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .color
                        .withOpacity(0.4),
                    fontSize: 14),
                border: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      actions: [
        TextButton(
            child: Text(
              Languages.of(context).labelCreate,
              style: TextStyle(
                  color:
                      controller.text.isNotEmpty && controller.text.length > 2
                          ? Theme.of(context).accentColor
                          : Theme.of(context)
                              .textTheme
                              .bodyText1
                              .color
                              .withOpacity(0.4)),
            ),
            onPressed: controller.text.isNotEmpty && controller.text.length > 2
                ? () => Navigator.pop(context, controller.text)
                : null),
        TextButton(
          child: Text(
            Languages.of(context).labelCancel,
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}
