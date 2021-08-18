import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:provider/provider.dart';
import 'package:songtube/provider/mediaProvider.dart';
import 'package:songtube/provider/preferencesProvider.dart';
import 'package:songtube/ui/components/emptyIndicator.dart';
import 'package:songtube/ui/components/playlistSongList.dart';
import 'package:songtube/ui/internal/snackbar.dart';
import 'package:songtube/ui/layout/streamsLargeThumbnail.dart';

class HomePageWatchLater extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    List<String> audioPlaylists = prefs.audioPlaylists;
    MediaProvider mediaProvider = Provider.of<MediaProvider>(context);
    String mainPlaylist = audioPlaylists.length == 0 ? "" : prefs.mainPlaylist;

    return mainPlaylist != ""
        ? PlaylistSongList(
        songs: prefs.getAllMediaFromPlaylist(mainPlaylist,context), hasDownloadType: true)
        : Align(alignment: Alignment.topCenter, child: Container(
        alignment: Alignment.topCenter,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Your favorite playlist will be shown here",
                    //"Discover new Channels to start building your feed!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context)
                            .iconTheme
                            .color
                            .withOpacity(0.6),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Product Sans'),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Manage your playlist at the playlist tab",
                    //"Discover new Channels to start building your feed!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context)
                            .iconTheme
                            .color
                            .withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Product Sans'),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {},
                    child: Container(
                      height: 50,
                      width: 50,
                      margin: EdgeInsets.only(left: 8, right: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.2),
                                blurRadius: 12,
                                spreadRadius: 0.2)
                          ],
                          border: Border.all(
                              color: Theme.of(context).accentColor),
                          color: Theme.of(context).cardColor),
                      child: Center(
                        child: Icon(Icons.music_note,
                            color: Theme.of(context).accentColor),
                      ),
                    ),
                  ),
                ]),
          ),
        )

      //EmptyIndicator()
    ));
  }
}
