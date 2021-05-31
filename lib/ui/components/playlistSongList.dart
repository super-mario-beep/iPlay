import 'dart:io';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/ffmpeg/converter.dart';
import 'package:songtube/internal/languages.dart';
import 'package:songtube/internal/models/videoFile.dart';
import 'package:songtube/players/service/playerService.dart';
import 'package:songtube/players/videoPlayer.dart';
import 'package:songtube/provider/mediaProvider.dart';
import 'package:songtube/provider/preferencesProvider.dart';
import 'package:songtube/ui/animations/blurPageRoute.dart';
import 'package:songtube/ui/internal/popupMenu.dart';
import 'package:songtube/ui/components/tagsEditorPage.dart';
import 'package:songtube/ui/internal/snackbar.dart';
import 'package:transparent_image/transparent_image.dart';

class PlaylistSongList extends StatelessWidget {
  final List<MediaItem> songs;
  final bool hasDownloadType;
  final String searchQuery;
  PlaylistSongList({
    @required this.songs,
    this.hasDownloadType = false,
    this.searchQuery = ""
  });
  @override
  Widget build(BuildContext context) {
    MediaProvider mediaProvider = Provider.of<MediaProvider>(context);

    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        MediaItem song = songs[index];
        if (searchQuery == "" || getSearchQueryMatch(song)) {
            return ListTile(
                title: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color: Theme
                        .of(context)
                        .textTheme
                        .bodyText1
                        .color,
                  ),
                ),
                subtitle: Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyText1
                          .color
                          .withOpacity(0.6)
                  ),
                ),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                            )
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: FlexiblePopupMenu(
                    borderRadius: 10,
                    items: [
                      FlexiblePopupItem(
                          title: Languages
                              .of(context)
                              .labelEditTags,
                          value: "Edit Tags"
                      ),
                      FlexiblePopupItem(
                          title: Languages
                              .of(context)
                              .labelDeleteSong,
                          value: "Delete"
                      )
                    ],
                    onItemTap: (String value) async {
                      if (value != null) {
                        if (AudioService.running &&
                            AudioService.playbackState.playing) {
                          if (AudioService.currentMediaItem.id == song.id) {
                            AudioService.stop();
                          }
                        }
                        switch (value) {
                          case "Delete":
                            mediaProvider.deleteSong(song);
                            break;
                          case "Edit Tags":
                            FFmpegConverter().getMediaFormat(song.id).then((
                                format) {
                              if (format == "m4a") {
                                Navigator.of(context).push(
                                    BlurPageRoute(
                                      builder: (_) {
                                        return TagsEditorPage(
                                          song: song,
                                        );
                                      },
                                      blurStrength: Provider
                                          .of<PreferencesProvider>
                                        (context, listen: false)
                                          .enableBlurUI ? 20 : 0,
                                    )
                                );
                              } else {
                                AppSnack.showSnackBar(
                                  icon: EvaIcons.alertCircleOutline,
                                  title: "Cannot Edit Tags",
                                  message: "Audio format not supported ($format)",
                                  context: context,
                                );
                              }
                            });
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
                    )
                ),
                onTap: () async {
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
                        MaterialPageRoute(builder: (context) =>
                            AppVideoPlayer(VideoFile(
                              name: song.title,
                              path: song.id,
                            )))
                    );
                  }
                }
            );
        } else {
          return Container();
        }
      },
    );
  }

  bool getSearchQueryMatch(MediaItem song) {
    if (searchQuery != "") {
      if (song.title.toLowerCase().contains(searchQuery.toLowerCase())) {
        return true;
      } else if (song.artist.toLowerCase().contains(searchQuery.toLowerCase())) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

}