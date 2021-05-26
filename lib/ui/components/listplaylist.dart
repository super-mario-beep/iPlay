import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/models/playlist.dart';
import 'package:songtube/provider/preferencesProvider.dart';
import 'package:songtube/screens/mediaScreen/components/playlistEmpty.dart';
import 'package:songtube/ui/animations/blurPageRoute.dart';
import 'package:songtube/ui/internal/popupMenu.dart';

import 'editPlaylist.dart';

class ListPlaylists extends StatefulWidget {
  @override
  _MusicScreenAlbumsTabState createState() => _MusicScreenAlbumsTabState();
}

class _MusicScreenAlbumsTabState extends State<ListPlaylists> {
  @override
  Widget build(BuildContext context) {
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    List<String> playlists = prefs.audioPlaylists;
    if (playlists.length == 0) {
      return PlaylistEmptyWidget();
    } else {
      return ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            String playlist = playlists[index];
            return ListTile(
              title: Text(
                playlist,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
              ),
              subtitle: Text(
                prefs.getSongsForPlaylist(playlist).length == 1
                    ? prefs.getSongsForPlaylist(playlist).length.toString() +
                        " song"
                    : prefs.getSongsForPlaylist(playlist).length.toString() +
                        " songs",
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
              onTap: () async {
                Navigator.push(
                  context,
                  BlurPageRoute(
                      blurStrength: Provider.of<PreferencesProvider>(context,
                          listen: false)
                          .enableBlurUI
                          ? 20
                          : 0,
                      builder: (_) => EditPlaylist(playlist))).then((value) => {
                  setState(() {})
                });
              },
              trailing: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FlexiblePopupMenu(
                  borderRadius: 10,
                  items: [
                    FlexiblePopupItem(title: "Rename", value: "Rename"),
                    FlexiblePopupItem(title: "Delete", value: "Delete"),
                    playlist == prefs.mainPlaylist
                        ? FlexiblePopupItem(
                            title: "Unset as main playlist",
                            value: "Unset as main playlist")
                        : FlexiblePopupItem(
                            title: "Set as main playlist",
                            value: "Set as main playlist")
                  ],
                  onItemTap: (String value) async {
                    if (value != null) {
                      switch (value) {
                        case "Set as main playlist":
                          prefs.mainPlaylist = playlist;
                          break;
                        case "Unset as main playlist":
                          prefs.mainPlaylist = "";
                          break;
                        case "Delete":
                          prefs.setSongsForPlaylist(playlist, []);
                          List<String> list = prefs.audioPlaylists;
                          list.remove(playlist);
                          prefs.audioPlaylists = list;
                          if (prefs.mainPlaylist == playlist) {
                            prefs.mainPlaylist = "";
                          }
                          break;
                        case "Rename":
                          String name = await showDialog(
                              context: context,
                              builder: (context) {
                                return CreatePlaylistDialog();
                              });
                          if (name != null) {
                            print("Renaming " +
                                playlist +
                                " playlist to " +
                                name);
                            List<String> music =
                                prefs.getSongsForPlaylist(playlist);
                            prefs.setSongsForPlaylist(playlist, []);
                            prefs.setSongsForPlaylist(name, music);
                            List<String> playlists = prefs.audioPlaylists;
                            playlists.remove(playlist);
                            playlists.add(name);
                            prefs.audioPlaylists = playlists;
                            //Navigator.of(context).pop();
                            break;
                          }
                      }
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.more_vert, size: 18),
                  ),
                ),
              ),
            );
          });
    }
  }
}
