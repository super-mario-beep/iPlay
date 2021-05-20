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
        : Align(alignment: Alignment.topCenter, child: const EmptyIndicator());
  }
}
