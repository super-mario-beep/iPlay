import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:newpipeextractor_dart/models/video.dart';
import 'package:provider/provider.dart';
import 'package:songtube/downloadMenu/downloadMenu.dart';
import 'package:songtube/internal/languages.dart';
import 'package:songtube/lib.dart';
import 'package:songtube/provider/managerProvider.dart';

class VideoEngagement extends StatelessWidget {
  final int likeCount;
  final int dislikeCount;
  final int viewCount;
  final Function onOpenComments;
  final Function onSaveToPlaylist;
  final YoutubeVideo video;
  final bool isAudioPlayer;
  final Function onPlayerTypeTap;

  VideoEngagement({
    @required this.likeCount,
    @required this.dislikeCount,
    @required this.viewCount,
    @required this.onOpenComments,
    @required this.onSaveToPlaylist,
    @required this.video,
    @required this.isAudioPlayer,
    @required this.onPlayerTypeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _engagementTile(
            icon: Icon(MdiIcons.thumbUpOutline,
                color: Theme.of(context).iconTheme.color),
            text: Text(
              NumberFormat.compact().format(likeCount),
              style: TextStyle(fontFamily: "Varela", fontSize: 10),
            ),
            onPressed: onOpenComments),
        // Open Comments Button
        _engagementTile(
            icon: Icon(MdiIcons.messageTextOutline,
                color: Theme.of(context).iconTheme.color),
            text: Text(
              "Comments",
              style: TextStyle(fontFamily: "Varela", fontSize: 10),
            ),
            onPressed: onOpenComments),

        // Add to Playlist Button
        _engagementTile(
            icon: Icon(MdiIcons.playlistPlus,
                color: Theme.of(context).iconTheme.color),
            text: Text(
              Languages.of(context).labelPlaylist,
              style: TextStyle(fontFamily: "Varela", fontSize: 10),
            ),
            onPressed: onSaveToPlaylist),
        isAudioPlayer
            ? _engagementTile(
                icon: Icon(Icons.tv, color: Theme.of(context).iconTheme.color),
                text: Text(
                  "Play video",
                  style: TextStyle(fontFamily: "Varela", fontSize: 10),
                ),
                onPressed: onPlayerTypeTap)
            : _engagementTile(
                icon: Icon(Icons.music_note, color: Theme.of(context).iconTheme.color),
                text: Text(
                  "Play audio",
                  style: TextStyle(fontFamily: "Varela", fontSize: 10),
                ),
                onPressed: onPlayerTypeTap),
        //Download
        if (Lib.DOWNLOADING_ENABLED)
          Container(
            child: GestureDetector(
              child: _engagementTile(
                icon: Icon(EvaIcons.cloudDownloadOutline,
                    color: Theme.of(context).iconTheme.color),
                text: Text(
                  "Download",
                  style: TextStyle(fontFamily: "Varela", fontSize: 10),
                ),
              ),
              onTap: () {
                showModalBottomSheet<dynamic>(
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    context: context,
                    builder: (context) {
                      String url = video.url;
                      return Wrap(
                        children: [
                          Consumer<ManagerProvider>(
                              builder: (context, provider, _) {
                            return DownloadMenu(
                              videoUrl: url,
                              scaffoldState:
                                  provider.internalScaffoldKey.currentState,
                            );
                          }),
                        ],
                      );
                    });
              },
            ),
          ),
      ],
    );
  }

  Widget _engagementTile(
      {final Widget icon, final Widget text, final Function onPressed}) {
    return Container(
      width: 65,
      height: 65,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[icon, SizedBox(height: 2), text],
        ),
      ),
    );
  }
}
