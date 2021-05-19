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
import 'package:songtube/ui/internal/popupMenu.dart';


class EditPlaylist extends StatefulWidget {
  final String name;

  EditPlaylist(this.name);

  @override
  _EditPlaylist createState() => _EditPlaylist();
}

class _EditPlaylist extends State<EditPlaylist> {
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
    bool isOnHomePage = prefs.homeTabPlaylist == widget.name ? true : false;

    for (MediaItem media in allMediaItems.toSet().toList()) {
      if (downloadedSongsNames.contains(media.title))
        downloadedMediaInPlaylist.add(media);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          "Playlist " + widget.name,
          style: TextStyle(
              fontFamily: 'Product Sans',
              color: Theme.of(context).textTheme.bodyText1.color),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete playlist'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('Do you really want to delete this playlist?'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Delete',style: TextStyle(color: Theme.of(context).accentColor),),
                            onPressed: () {
                              List<String> list = prefs.audioPlaylists;
                              prefs.setSongsForPlaylist(widget.name,[]);
                              list.remove(widget.name);
                              prefs.audioPlaylists = list;
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Cancel',style: TextStyle(color: Theme.of(context).accentColor),),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              })
        ],
        elevation: 0,
      ),
      body: downloadedMediaInPlaylist.length != 0
          ? /*Column(
              children: [
                Row(children: [
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: Text(
                        "Playlist title",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1.color,
                          fontSize: 16,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
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
                        print(
                            "Renaming " + widget.name + " playlist to " + name);
                        List<String> music =
                            prefs.getSongsForPlaylist(widget.name);
                        prefs.setSongsForPlaylist(widget.name, []);
                        prefs.setSongsForPlaylist(name, music);
                        List<String> playlists = prefs.audioPlaylists;
                        playlists.remove(widget.name);
                        playlists.add(name);
                        prefs.audioPlaylists = playlists;
                        Navigator.of(context).pop();
                        //_EditPlaylist createState() => _EditPlaylist();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(right: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: Text(
                          "Edit",
                          style: TextStyle(
                              color:
                              Theme.of(context).textTheme.bodyText1.color,
                              fontSize: 16,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  )
                ]),
                Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.red[600].withOpacity(0.1),
                    indent: 12,
                    endIndent: 12),
                Container(child: PlaylistSongList(songs: downloadedMediaInPlaylist, hasDownloadType: true),),
              ],
            )*/
      Container(
        child: MediaMusicTab(downloadedMediaInPlaylist),
      )
          : Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Your playlist has no music",
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
                      "Try add some",
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
                    GestureDetector(
                      onTap: () async {
                        //go to downloads
                      },
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
                          child: Icon(Icons.add,
                              color: Theme.of(context).accentColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
        "Rename Playlist",
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
                hintText: "Enter new title",
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
              "Rename",
              style: TextStyle(
                  color:
                  controller.text.isNotEmpty && controller.text.length > 3
                      ? Theme.of(context).accentColor
                      : Theme.of(context)
                      .textTheme
                      .bodyText1
                      .color
                      .withOpacity(0.4)),
            ),
            onPressed: controller.text.isNotEmpty && controller.text.length > 3
                ? () => Navigator.pop(context, controller.text)
                : null),
        TextButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}
