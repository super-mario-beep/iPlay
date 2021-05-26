import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/models/playlist.dart';
import 'package:songtube/provider/mediaProvider.dart';
import 'package:songtube/provider/preferencesProvider.dart';
import 'package:songtube/screens/mediaScreen/tabs/musicTab.dart';
import 'package:songtube/ui/animations/blurPageRoute.dart';
import 'package:songtube/ui/internal/popupMenu.dart';
import 'package:transparent_image/transparent_image.dart';

class AddAudioInPlaylist extends StatefulWidget {
  final String name;

  AddAudioInPlaylist(this.name);

  @override
  _AddAudioInPlaylist createState() => _AddAudioInPlaylist();
}

class _AddAudioInPlaylist extends State<AddAudioInPlaylist> {
  GlobalKey<ScaffoldState> scaffoldKey;

  @override
  void initState() {
    super.initState();
    scaffoldKey = GlobalKey<ScaffoldState>();
  }

  @override
  Widget build(BuildContext context) {
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    MediaProvider mediaProvider = Provider.of<MediaProvider>(context);
    List<MediaItem> allMediaItems = mediaProvider.databaseSongs;
    List<String> downloadedSongsNames = prefs.getSongsForPlaylist(widget.name);
    List<MediaItem> downloadedMediaInPlaylist = [];
    List<MediaItem> _allMediaItems = [];

    for(MediaItem item in allMediaItems){
      if(_allMediaItems.where((element) => element.title == item.title).isEmpty){
        _allMediaItems.add(item);
      }
    }
    if(_allMediaItems.length != allMediaItems.length){
      print("Fixing download song list");
      mediaProvider.databaseSongs.clear();
      mediaProvider.databaseSongs.addAll(_allMediaItems.reversed);
    }

    for (MediaItem media in _allMediaItems.toSet().toList()) {
      if (downloadedSongsNames.contains(media.title)) {
        downloadedMediaInPlaylist.add(media);
      }
    }



    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          "Add music to " + widget.name,
          style: TextStyle(
              fontFamily: 'Product Sans',
              color: Theme.of(context).textTheme.bodyText1.color),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        elevation: 0,
      ),
      body: allMediaItems.length != 0
          ? Container(
              child: _getMusicListWidget(context, allMediaItems, downloadedMediaInPlaylist, prefs),
            )
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 1, right: 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "We couldn't find any downloaded music",
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
                            "Download then add in playlist",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .iconTheme
                                    .color
                                    .withOpacity(0.6),
                                fontSize: 20,
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
                                child: Icon(EvaIcons.cloudDownloadOutline,
                                    color: Theme.of(context).accentColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  flex: 1,
                ),
              ],
            ),
    );
  }

  Widget _getMusicListWidget(BuildContext context, List<MediaItem> songs, List<MediaItem> playlistSongs, PreferencesProvider prefs) {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        MediaItem song = songs[index];
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
            trailing: GestureDetector(
              onTap: () async {
                bool _isInPlaylist = playlistSongs.contains(song);
                List<String> list = prefs.getSongsForPlaylist(widget.name);
                if(_isInPlaylist){
                  //Remove
                  list.remove(song.title);
                  prefs.setSongsForPlaylist(widget.name, list);
                }else{
                  //Add
                  list.add(song.title);
                  prefs.setSongsForPlaylist(widget.name, list);
                }
                setState(() {
                  prefs.getSongsForPlaylist(widget.name);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.black26,
                ),
                padding: EdgeInsets.only(top: 12,bottom: 12,left: 8,right: 8),
                margin: EdgeInsets.only(right: 3),
                width: playlistSongs.contains(song) ? 95 : 75,
                child: Row(
                  children: [
                    Icon(playlistSongs.contains(song) ? Icons.remove : Icons.add,
                        color: Theme.of(context).accentColor, size: 18),
                    SizedBox(width: 4),
                    Text(playlistSongs.contains(song) ? "Remove" : "Add",style: TextStyle(fontSize: 14),),
                  ],
                ),
              ),
            ),
        );
      },
    );
  }
}
