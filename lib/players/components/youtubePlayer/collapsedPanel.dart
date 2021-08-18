import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:provider/provider.dart';
import 'package:songtube/audioStreamYt.dart';
import 'package:songtube/players/components/musicPlayer/ui/marqueeWidget.dart';
import 'package:songtube/provider/videoPageProvider.dart';
import 'package:transparent_image/transparent_image.dart';

class VideoPageCollapsed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    VideoPageProvider pageProvider = Provider.of<VideoPageProvider>(context);
    String title = pageProvider?.infoItem?.name ?? "";
    String author = pageProvider?.infoItem?.uploaderName ?? "";
    String thumbnailUrl = pageProvider.infoItem is StreamInfoItem
        ? pageProvider?.infoItem?.thumbnails?.hqdefault ?? ""
        : pageProvider?.infoItem?.thumbnailUrl ?? "";
    return Container(
      height: kBottomNavigationBarHeight * 1.15,
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 1.2),
            child: Row(
              children: [
                Icon(
                  EvaIcons.arrowUp,
                  size: 11,
                ),
                Icon(
                  EvaIcons.arrowUp,
                  size: 11,
                ),
                Icon(
                  EvaIcons.arrowUp,
                  size: 11,
                ),
                SizedBox(
                  width: 15,
                ),
                Text("SWIPE UP FOR MORE",textAlign: TextAlign.center,style: TextStyle(fontSize: 13),),
                SizedBox(
                  width: 15,
                ),
                Icon(
                  EvaIcons.arrowUp,
                  size: 11,
                ),
                Icon(
                  EvaIcons.arrowUp,
                  size: 11,
                ),
                Icon(
                  EvaIcons.arrowUp,
                  size: 11,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      margin: EdgeInsets.only(left: 8),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: pageProvider.infoItem is StreamInfoItem
                              ? FadeInImage(
                                  fadeInDuration: Duration(milliseconds: 400),
                                  placeholder: MemoryImage(kTransparentImage),
                                  image: NetworkImage(thumbnailUrl),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Icon(MdiIcons.playlistMusic,
                                      color: Theme.of(context).iconTheme.color),
                                )),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MarqueeWidget(
                              animationDuration: Duration(seconds: 8),
                              backDuration: Duration(seconds: 3),
                              pauseDuration: Duration(seconds: 2),
                              direction: Axis.horizontal,
                              child: Text(
                                "$title",
                                style: TextStyle(
                                    fontFamily: 'YTSans', fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ),
                            ),
                            if (author != "") SizedBox(height: 2),
                            if (author != "")
                              Text(
                                "$author",
                                style: TextStyle(
                                    fontFamily: 'YTSans',
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color
                                        .withOpacity(0.6)),
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                maxLines: 1,
                              )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // Play/Pause
              SizedBox(width: 8),
              Container(
                color: Colors.transparent,
                child: IconButton(
                    icon: (AudioStreamPlayer.isAudioPlayer &&
                                AudioStreamPlayer.isPlaying) ||
                            (!AudioStreamPlayer.isAudioPlayer &&
                                AudioStreamPlayer.isVideoPlaying)
                        ? Icon(MdiIcons.pause, size: 22)
                        : Icon(MdiIcons.play, size: 22),
                    onPressed: () {
                      if (AudioStreamPlayer.isAudioPlayer) {
                        if (AudioStreamPlayer.isPlaying) {
                          AudioStreamPlayer.pause();
                          pageProvider.setState();
                          AudioStreamPlayer.isPlaying = false;
                        } else {
                          AudioStreamPlayer.play();
                          pageProvider.setState();
                          AudioStreamPlayer.isPlaying = true;
                        }
                      } else {
                        if (AudioStreamPlayer.isVideoPlaying) {
                          AudioStreamPlayer.videoPlayerController.pause();
                          AudioStreamPlayer.isVideoPlaying = false;
                          pageProvider.setState();
                        } else {
                          AudioStreamPlayer.videoPlayerController.play();
                          AudioStreamPlayer.isVideoPlaying = true;
                          pageProvider.setState();
                        }
                      }
                    }),
              ),
              InkWell(
                onTap: () {
                  AudioStreamPlayer.stop();
                  AudioStreamPlayer.videoPlayerController.pause();
                  AudioStreamPlayer.isAudioPlayer = true;
                  pageProvider.closeVideoPanel();
                },
                child: Ink(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(EvaIcons.closeOutline),
                    )),
              ),
              SizedBox(width: 16)
            ],
          ),
        ],
      ),
    );
  }
}
