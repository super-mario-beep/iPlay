import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/languages.dart';
import 'package:songtube/provider/preferencesProvider.dart';
import 'package:songtube/ui/animations/showUp.dart';
import 'package:songtube/ui/components/addToPlaylist.dart';



class PlaylistEmptyWidget extends StatelessWidget {
  const PlaylistEmptyWidget();

  @override
  Widget build(BuildContext context) {
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);

    return ShowUpTransition(
      duration: Duration(milliseconds: 400),
      slideSide: SlideFromSlide.BOTTOM,
      forward: true,
      child: Container(
        padding: EdgeInsets.all(1),
        height: 240,
        width: MediaQuery.of(context).size.width * 0.6,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 1, right: 1),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "We couldn't find any playlists",
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
                          "Try add some",
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
                          onTap: () async {
                            String name = await showDialog(
                                context: context,
                                builder: (context) {
                                  return CreatePlaylistDialog();
                                });
                            if (name != null) {
                              print("New playlist created: " + name);
                              //s.streamPlaylistCreate(name, "local", [widget.stream]);
                              List<String> tmp = prefs.audioPlaylists;
                              tmp.add(name);
                              prefs.audioPlaylists = tmp;
                            }
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
                              child: Icon(Icons.add_rounded,
                                  color: Theme.of(context).accentColor),
                            ),
                          ),
                        ),]
                  ),
                ),)
            ],
          ),
        ),
      ),
    );
  }
}
