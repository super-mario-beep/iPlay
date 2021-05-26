import 'dart:io';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songtube/downloadMenu/downloadMenu.dart';
import 'package:songtube/internal/ffmpeg/converter.dart';
import 'package:songtube/internal/languages.dart';
import 'package:songtube/internal/models/videoFile.dart';
import 'package:songtube/internal/radioStreamingController.dart';
import 'package:songtube/players/service/playerService.dart';
import 'package:songtube/players/videoPlayer.dart';
import 'package:songtube/provider/managerProvider.dart';
import 'package:songtube/provider/mediaProvider.dart';
import 'package:songtube/provider/preferencesProvider.dart';
import 'package:songtube/ui/animations/blurPageRoute.dart';
import 'package:songtube/ui/components/addToPlaylist.dart';
import 'package:songtube/ui/components/addToPlaylistDownloaded.dart';
import 'package:songtube/ui/internal/popupMenu.dart';
import 'package:songtube/ui/components/tagsEditorPage.dart';
import 'package:songtube/ui/internal/snackbar.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../../lib.dart';

class SongsListView extends StatelessWidget {
  final List<MediaItem> songs;
  final bool hasDownloadType;
  final String searchQuery;
  final bool isNotPlaylistView;

  SongsListView(
      {@required this.songs,
      this.hasDownloadType = false,
      this.searchQuery = "",
      this.isNotPlaylistView = true});

  @override
  Widget build(BuildContext context) {
    MediaProvider mediaProvider = Provider.of<MediaProvider>(context);
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        MediaItem song = songs[index];
        if (searchQuery == "") {
          return ListTile(
              title: Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
              ),
              subtitle: Text(
                song.artist,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .color
                        .withOpacity(0.6)),
              ),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasDownloadType)
                    Container(
                      height: 30,
                      width: 30,
                      margin: EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black12.withOpacity(0.04)),
                      child: Icon(
                        song.extras["downloadType"] == "Audio"
                            ? EvaIcons.musicOutline
                            : EvaIcons.videoOutline,
                        color: Theme.of(context).iconTheme.color,
                        size: 20,
                      ),
                    ),
                  Hero(
                    tag: song.title,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FadeInImage(
                            fadeInDuration: Duration(milliseconds: 200),
                            placeholder: MemoryImage(kTransparentImage),
                            image: FileImage(File(song.extras["artwork"])),
                            fit: BoxFit.cover,
                          )),
                    ),
                  ),
                ],
              ),
              trailing: FlexiblePopupMenu(
                  borderRadius: 10,
                  items: [
                    FlexiblePopupItem(title: "Delete song", value: "Delete"),
                    if(isNotPlaylistView)
                    FlexiblePopupItem(
                        title: "Add to playlist", value: "Add to playlist")
                  ],
                  onItemTap: (String value) async {
                    if (value != null) {
                      switch (value) {
                        case "Add to playlist":
                          showModalBottomSheet(
                              context: context,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15))),
                              builder: (context) {
                                return AddStreamToPlaylistSheetDl(
                                    stream: song.title);
                              });

                          break;
                        case "Delete":
                          if (AudioService.running &&
                              AudioService.playbackState.playing) {
                            if (AudioService.currentMediaItem.id == song.id) {
                              AudioService.stop();
                            }
                          }
                          mediaProvider.deleteSong(song);
                          PreferencesProvider prefs =
                              Provider.of<PreferencesProvider>(context,
                                  listen: false);
                          List<String> playlists = prefs.audioPlaylists;
                          for (String playlist in playlists) {
                            List<String> songs =
                                prefs.getSongsForPlaylist(playlist);
                            for (String s in songs) {
                              if (song.title == s) {
                                songs.remove(s);
                                prefs.setSongsForPlaylist(playlist, songs);
                                break;
                              }
                            }
                          }
                          break;
                        case "Apply Filters":
                          // TODO: Allow Audio Filters application
                          break;
                      }
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.more_vert, size: 18),
                  )),
              onTap: () async {
                try {
                  print("Playing music while radio is on: " + StreamingController.IS_PLAYING.toString());
                  if (StreamingController.IS_PLAYING) {
                    var streamingController = StreamingController();
                    StreamingController.IS_PLAYING = false;
                    streamingController.stop();
                  }
                } on Exception catch (_) {
                  print('Trying shut down radio');
                }

                if (hasDownloadType == false ||
                    song.extras["downloadType"] == "Audio") {
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
                  if (listEquals(songs, AudioService.queue) == false) {
                    await AudioService.updateQueue(songs);
                  }
                  await AudioService.playMediaItem(songs[index]);
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AppVideoPlayer(VideoFile(
                                name: song.title,
                                path: song.id,
                              ))));
                }
              });
        } else {
          return Container();
        }
      },
    );
  }
}
