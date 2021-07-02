import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songtube/lib.dart';
import 'package:songtube/pages/watchHistory.dart';
import 'package:songtube/provider/managerProvider.dart';
import 'package:songtube/provider/preferencesProvider.dart';
import 'package:songtube/ui/components/emptyIndicator.dart';
import 'package:songtube/ui/layout/streamsLargeThumbnail.dart';

class HomePageTrending extends StatefulWidget {
  @override
  _HomePageTrendingState createState() => _HomePageTrendingState();
}

class _HomePageTrendingState extends State<HomePageTrending> {
  @override
  Widget build(BuildContext context) {
    ManagerProvider manager = Provider.of<ManagerProvider>(context);
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    if (Lib.DOWNLOADING_ENABLED) {
      //return StreamsLargeThumbnailView(
          //infoItems: manager.homeTrendingVideoList);
      if(prefs.watchHistory.isEmpty) {
        return Container(
          padding: EdgeInsets.all(1),
          height: 240,
          width: MediaQuery
              .of(context)
              .size
              .width * 0.6,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 1, right: 1, top: 180),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "History",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme
                                    .of(context)
                                    .iconTheme
                                    .color
                                    .withOpacity(0.6),
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Product Sans'),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Your history will be shown here",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme
                                    .of(context)
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

                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              margin: EdgeInsets.only(left: 8, right: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Theme
                                            .of(context)
                                            .accentColor
                                            .withOpacity(0.2),
                                        blurRadius: 12,
                                        spreadRadius: 0.2)
                                  ],
                                  border: Border.all(
                                      color: Theme
                                          .of(context)
                                          .accentColor),
                                  color: Theme
                                      .of(context)
                                      .cardColor),
                              child: Center(
                                child: Icon(Icons.history,
                                    color: Theme
                                        .of(context)
                                        .accentColor),
                              ),
                            ),
                          ),
                        ]),
                  ),
                )
              ],
            ),
          ),
        );
      }else{
        return WatchHistoryPage();
      }
    } else {
      return Container(
        padding: EdgeInsets.all(1),
        height: 240,
        width: MediaQuery.of(context).size.width * 0.6,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 1, right: 1, top: 180),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Something went wrong. Try again",
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
                          "Tap to refresh",
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
                            print("Refreshing iPlay server");
                            if(Lib.DOWNLOADING_ENABLED){
                              setState(() {
                                Lib.DOWNLOADING_ENABLED = true;
                              });
                            }else{
                              Lib.checkForUpdatesStatic();
                              Future.delayed(const Duration(milliseconds: 320), (){
                                if(Lib.DOWNLOADING_ENABLED){
                                  setState(() {
                                    Lib.DOWNLOADING_ENABLED = true;
                                  });
                                }
                              });
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
                              child: Icon(Icons.refresh,
                                  color: Theme.of(context).accentColor),
                            ),
                          ),
                        ),
                      ]),
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}
