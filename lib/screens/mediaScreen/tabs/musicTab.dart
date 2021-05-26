// Flutter
import 'package:flutter/material.dart';

// Internal
import 'package:songtube/provider/mediaProvider.dart';
import 'package:songtube/provider/preferencesProvider.dart';
import 'package:songtube/screens/mediaScreen/components/mediaListBase.dart';

// Packages
import 'package:audio_service/audio_service.dart';
import 'package:provider/provider.dart';
import 'package:songtube/screens/mediaScreen/components/playlistEmpty.dart';
import 'package:songtube/screens/mediaScreen/components/songsListView.dart';

class MediaMusicTab extends StatelessWidget {
  final List<MediaItem> songs;
  final bool isNotPlaylistView;
  MediaMusicTab(this.songs, {this.isNotPlaylistView = true});

  @override
  Widget build(BuildContext context) {
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    MediaProvider mediaProvider = Provider.of<MediaProvider>(context);

    if (songs.isEmpty) {
      return PlaylistEmptyWidget();
    } else {
      return MediaListBase(
        isLoading: mediaProvider.loadingMusic,
        isEmpty: mediaProvider.listMediaItems.isEmpty,
        listType: MediaListBaseType.Any,
        child: SongsListView(
          songs: songs,
          searchQuery: "",
          isNotPlaylistView: false,
        ),
      );
    }
  }
}
