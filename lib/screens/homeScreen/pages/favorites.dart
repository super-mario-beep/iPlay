import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:provider/provider.dart';
import 'package:songtube/provider/preferencesProvider.dart';
import 'package:songtube/ui/components/emptyIndicator.dart';
import 'package:songtube/ui/internal/snackbar.dart';
import 'package:songtube/ui/layout/streamsLargeThumbnail.dart';

class HomePageFavorites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    return AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: prefs.favoriteVideos.isNotEmpty
            ? StreamsLargeThumbnailView(
                infoItems: prefs.favoriteVideos,
                isFavorites: true,
                allowSaveToFavorites: false,
                allowSaveToWatchLater: true,
                onDelete: (infoItem) {
                  List<StreamInfoItem> videos = prefs.favoriteVideos;
                  videos.removeWhere((element) => element.url == infoItem.url);
                  prefs.favoriteVideos = videos;
                  AppSnack.showSnackBar(
                    icon: EvaIcons.alertCircleOutline,
                    title: "Video removed from Favorites",
                    context: context,
                  );
                },
              )
            : Container(
                alignment: Alignment.topCenter,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Your favorite videos will be shown here",
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
                            "Use the search-box at the top of the screen",
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
                                child: Icon(Icons.tv,
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
