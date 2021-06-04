// Flutter
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/languages.dart';
import 'package:songtube/internal/radioStreamingController.dart';
import 'package:songtube/players/service/playerService.dart';
import 'package:songtube/provider/downloadsProvider.dart';
import 'package:songtube/provider/mediaProvider.dart';
import 'package:songtube/provider/preferencesProvider.dart';
import 'package:songtube/provider/videoPageProvider.dart';
import 'package:songtube/screens/downloadScreen/tabs/cancelledTab.dart';

// Internal
import 'package:songtube/screens/downloadScreen/tabs/downloadsTab.dart';

// Packages
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:songtube/screens/downloadScreen/tabs/queueTab.dart';
import 'package:songtube/ui/components/autoHideScaffold.dart';
import 'package:songtube/ui/sheets/joinTelegram.dart';

class DownloadTab extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    DownloadsProvider downloadsProvider =
        Provider.of<DownloadsProvider>(context, listen: false);
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    bool isShuffle = prefs.shuffle;
    MediaProvider mediaProvider = Provider.of<MediaProvider>(context);
    List<MediaItem> allMediaItems = mediaProvider.databaseSongs;
    List<String> downloadedSongsNames = [];
    List<MediaItem> downloadedMediaInPlaylist = [];
    List<MediaItem> _allMediaItems = [];

    for (MediaItem item in allMediaItems) {
      if (_allMediaItems
          .where((element) => element.title == item.title)
          .isEmpty) {
        _allMediaItems.add(item);
      }
    }

    if (_allMediaItems.length != allMediaItems.length) {
      print("Fixing download song list");
      mediaProvider.databaseSongs.clear();
      mediaProvider.databaseSongs.addAll(_allMediaItems.reversed);
    }

    for (MediaItem media in _allMediaItems.toSet().toList()) {
      if (!downloadedSongsNames.contains(media.title)) {
        downloadedMediaInPlaylist.add(media);
      }
    }


    Duration duration = downloadedMediaInPlaylist.fold(
        Duration(milliseconds: 0),
        (previousValue, element) => previousValue + element.duration);

    return DefaultTabController(
      initialIndex: downloadsProvider.queueList.isNotEmpty ||
              downloadsProvider.downloadingList.isNotEmpty ||
              downloadsProvider.convertingList.isNotEmpty
          ? 0
          : 1,
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).cardColor,
          title: Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 8),
                child: Icon(
                  EvaIcons.cloudDownloadOutline,
                  color: Theme.of(context).accentColor,
                ),
              ),
              Text(
                Languages.of(context).labelDownloads,
                style: TextStyle(
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Theme.of(context).textTheme.bodyText1.color),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 40,
              color: Theme.of(context).cardColor,
              child: TabBar(
                labelStyle: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3),
                unselectedLabelStyle: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2),
                labelColor: Theme.of(context).accentColor,
                unselectedLabelColor: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .color
                    .withOpacity(0.4),
                indicator: MD2Indicator(
                  indicatorSize: MD2IndicatorSize.normal,
                  indicatorHeight: 4,
                  indicatorColor: Theme.of(context).accentColor,
                ),
                tabs: [
                  Tab(child: Text(Languages.of(context).labelQueued)),
                  Tab(child: Text(Languages.of(context).labelCompleted)),
                  Tab(child: Text(Languages.of(context).labelCancelled))
                ],
              ),
            ),
            Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[600].withOpacity(0.1),
                indent: 12,
                endIndent: 12),
            downloadedMediaInPlaylist.length != 0
                ? Row(
                    children: [
                      Expanded(
                        child: Text(
                          downloadedMediaInPlaylist.length != 1
                              ? downloadedMediaInPlaylist.length.toString() +
                                  " songs"
                              : "1 song",
                          style: TextStyle(fontSize: 18, fontFamily: "YTSans"),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          duration.inMinutes.toString() +
                              ":" +
                              duration.inSeconds
                                  .remainder(60)
                                  .toString()
                                  .padLeft(2, '0') +
                              " min",
                          style: TextStyle(fontSize: 18, fontFamily: "YTSans"),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Row(
                            children: [
                              Container(
                                child: IconButton(
                                    icon: Icon(EvaIcons.shuffle2Outline),
                                    color: isShuffle
                                        ? Theme.of(context).accentColor
                                        : Colors.white,
                                    onPressed: () async {
                                      try {
                                        print(
                                            "Playing music while radio is on: " +
                                                StreamingController.IS_PLAYING
                                                    .toString());
                                        if (StreamingController.IS_PLAYING) {
                                          var streamingController =
                                              StreamingController();
                                          StreamingController.IS_PLAYING =
                                              false;
                                          streamingController.stop();
                                        }
                                      } on Exception catch (_) {
                                        print('Trying shut down radio');
                                      }
                                      if (!AudioService.running) {
                                        await AudioService.start(
                                          backgroundTaskEntrypoint:
                                              songtubePlayer,
                                          androidNotificationChannelName:
                                              'SongTube',
                                          // Enable this if you want the Android service to exit the foreground state on pause.
                                          //androidStopForegroundOnPause: true,
                                          androidNotificationColor: 0xFF2196f3,
                                          androidNotificationIcon:
                                              'drawable/ic_stat_music_note',
                                          androidEnableQueue: true,
                                        );
                                      }

                                      List<MediaItem> songs =
                                          mediaProvider.databaseSongs;
                                      songs.shuffle();
                                      if (listEquals(
                                              songs, AudioService.queue) ==
                                          false) {
                                        await AudioService.updateQueue(songs);
                                      }
                                      VideoPageProvider tmp =
                                          Provider.of<VideoPageProvider>(
                                              context,
                                              listen: false);
                                      await AudioService.playMediaItem(songs[0])
                                          .then((value) =>
                                              {tmp.closeVideoPanel()});
                                    }),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                          color: isShuffle
                                              ? Theme.of(context)
                                                  .accentColor
                                                  .withOpacity(0.15)
                                              : Colors.transparent,
                                          spreadRadius: 0.1,
                                          blurRadius: 15)
                                    ]),
                              ),
                              Text("Shuffle",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "YTSans",
                                      color: isShuffle
                                          ? Theme.of(context).accentColor
                                          : Colors.white)),
                            ],
                          ),
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
                                androidNotificationIcon:
                                    'drawable/ic_stat_music_note',
                                androidEnableQueue: true,
                              );
                            }

                            List<MediaItem> songs = mediaProvider.databaseSongs;
                            songs.shuffle();
                            if (listEquals(songs, AudioService.queue) ==
                                false) {
                              await AudioService.updateQueue(songs);
                            }
                            VideoPageProvider tmp =
                                Provider.of<VideoPageProvider>(context,
                                    listen: false);
                            await AudioService.playMediaItem(songs[0])
                                .then((value) => {tmp.closeVideoPanel()});
                          },
                        ),
                      ),
                    ],
                  )
                : Container(),
            Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).accentColor.withOpacity(0.1),
                indent: 12,
                endIndent: 12),
            Expanded(
              child: TabBarView(
                children: [
                  DownloadsQueueTab(),
                  DownloadsTab(),
                  DownloadsCancelledTab()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
