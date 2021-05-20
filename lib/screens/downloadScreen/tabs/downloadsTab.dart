// Flutter
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

// Internal
import 'package:songtube/provider/mediaProvider.dart';
import 'package:songtube/screens/mediaScreen/components/mediaListBase.dart';

// Packages
import 'package:provider/provider.dart';

// UI
import 'package:songtube/screens/mediaScreen/components/songsListView.dart';

class DownloadsTab extends StatefulWidget {
  @override
  _DownloadsTabState createState() => _DownloadsTabState();
}

class _DownloadsTabState extends State<DownloadsTab> {

  @override
  void initState() {
    Provider.of<MediaProvider>(context, listen: false).getDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaProvider mediaProvider = Provider.of<MediaProvider>(context);
    List<MediaItem> list = mediaProvider.databaseSongs;
    List<MediaItem> _list = [];

    for(MediaItem item in list){
      if(_list.where((element) => element.title == item.title).isEmpty){
        _list.add(item);
      }
    }

    if(_list.length != list.length){
      print("Fixing download song list");
      mediaProvider.databaseSongs.clear();
      mediaProvider.databaseSongs.addAll(_list.reversed);
    }


    return MediaListBase(
      isLoading: mediaProvider.loadingDownloads,
      isEmpty: mediaProvider.databaseSongs.isEmpty,
      listType: MediaListBaseType.Downloads,
      child: SongsListView(
        songs: mediaProvider.databaseSongs,
        hasDownloadType: true,
      ),
    );
  }
}