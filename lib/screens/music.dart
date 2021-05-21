import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_fade/image_fade.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/radioStationList.dart';
import 'package:songtube/internal/radioStreamingController.dart';
import 'package:songtube/pages/channel.dart';
import 'package:songtube/pages/settings.dart';
import 'package:songtube/provider/managerProvider.dart';
import 'package:songtube/provider/preferencesProvider.dart';
import 'package:songtube/ui/animations/blurPageRoute.dart';
import 'package:songtube/ui/components/autoHideScaffold.dart';
import 'package:songtube/ui/components/shimmerContainer.dart';
import 'package:songtube/ui/internal/popupMenu.dart';
import 'package:songtube/ui/layout/streamsLargeThumbnail.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:http/http.dart' as http;

class SubscriptionsScreen extends StatefulWidget {
  @override
  _SubscriptionsScreenState createState() => _SubscriptionsScreenState();
}

class RadioStationCountry {
  String name;
  int radios;
  static List<RadioStationCountry> countryNames = [];

  RadioStationCountry(this.name, this.radios);
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  setCountries(BuildContext context) async {
    if (RadioStationCountry.countryNames.isNotEmpty) {
      setState(() {
        loading = false;
        countries = RadioStationCountry.countryNames;
      });
    } else {
      final response =
          await http.get('https://de1.api.radio-browser.info/json/countries');
      var json = jsonDecode(response.body);
      List<RadioStationCountry> val = [];
      for (LinkedHashMap<String, dynamic> obj in json) {
        val.add(new RadioStationCountry(obj["name"], obj["stationcount"]));
      }
      setState(() {
        RadioStationCountry.countryNames = val;
        loading = false;
        countries = val;
      });
    }
  }

  List<RadioStationCountry> countries = [];
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    ManagerProvider manager = Provider.of<ManagerProvider>(context);
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    if (countries.isEmpty && loading) setCountries(context);
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: AutoHideScaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).cardColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).cardColor,
          title: AnimatedSwitcher(
              duration: Duration(milliseconds: 250),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 8),
                    child: Icon(
                      EvaIcons.radio,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  Text(
                    "Radio",
                    style: TextStyle(
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Theme.of(context).textTheme.bodyText1.color),
                  ),
                  Spacer(),
                ],
              )),
        ),
        body: Column(
          children: [
            Container(
                height: 40,
                color: Theme.of(context).cardColor,
                child: TabBar(
                  labelStyle: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3),
                  unselectedLabelStyle: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2),
                  labelColor: Theme.of(context).accentColor,
                  unselectedLabelColor: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .color
                      .withOpacity(0.4),
                  indicator: MD2Indicator(
                    indicatorSize: MD2IndicatorSize.tiny,
                    indicatorHeight: 4,
                    indicatorColor: Theme.of(context).accentColor,
                  ),
                  tabs: [
                    Tab(child: Text("All")),
                    Tab(child: Text("Favorites")),
                  ],
                )),
            Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[600].withOpacity(0.1),
                indent: 12,
                endIndent: 12),
            Expanded(
              child: TabBarView(
                children: [
                  _getListOfCountriesWidget(),
                  _getListOfFavoritesWidget(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getListOfCountriesWidget() {
    if(countries.isNotEmpty && !loading){
      return ListView.builder(
          padding: EdgeInsets.only(left: 16, top: 10, bottom: 10),
          shrinkWrap: true,
          itemCount: countries.length,
          itemBuilder: (context, index) {
            RadioStationCountry country = countries[index];
            return ListTile(
                title: Text(
                  country.name,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1.color,
                  ),
                ),
                subtitle: Text(
                  country.radios == 1
                      ? country.radios.toString() + " radio station"
                      : country.radios.toString() + " radio stations",
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
                          blurStrength: Provider.of<PreferencesProvider>(
                              context,
                              listen: false)
                              .enableBlurUI
                              ? 20
                              : 0,
                          builder: (_) => RadioStationList(country.name)));
                });
          });
    }else if(!loading){
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "We couldn't find any radio stations",
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
                      child: Icon(Icons.radio,
                          color: Theme.of(context).accentColor),
                    ),
                  ),
                ),
              ]),
        ),
      );
    }else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Loading...",
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
                    child: Icon(Icons.radio,
                        color: Theme.of(context).accentColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _getListOfFavoritesWidget(BuildContext context) {
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    List<RadioStation> stations = prefs.favoriteRadios;
    if (stations.isNotEmpty) {
      return ListView.builder(
          padding: EdgeInsets.only(left: 16, top: 10, bottom: 10),
          shrinkWrap: true,
          itemCount: stations.length,
          itemBuilder: (context, index) {
            RadioStation station = stations[index];
            return ListTile(
                title: Text(
                  station.name,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color:
                    Theme
                        .of(context)
                        .textTheme
                        .bodyText1
                        .color,
                  ),
                ),
                subtitle: Text(
                  "Bitrate " +
                      station.bitrate.toString() +
                      " - " +
                      station.country,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyText1
                          .color
                          .withOpacity(0.6)),
                ),
                trailing: FlexiblePopupMenu(
                    borderRadius: 10,
                    items: [
                      !_containFavoriteRadio(stations, station) ?
                      FlexiblePopupItem(
                          title: "Add to favorites",
                          value: "Add") :
                      FlexiblePopupItem(
                          title: "Remove from favorites",
                          value: "Remove")
                    ],
                    onItemTap: (String value) async {
                      if (value != null) {
                        switch (value) {
                          case "Add":
                            stations.add(station);
                            prefs.favoriteRadios = stations;
                            break;
                          case "Remove":
                            stations.remove(station);
                            prefs.favoriteRadios = stations;
                            break;
                        }
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.more_vert, size: 18),
                    )),
                onTap: () async {
                  changeStreamStation(station);
                });
          });
    } else{
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Your favorite radios will be shown here",
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
                      child: Icon(Icons.radio,
                          color: Theme.of(context).accentColor),
                    ),
                  ),
                ),
              ]),
        ),
      );
    }
  }


  var streamingController = StreamingController();
  void _loadingAlert(int duration) {
    String text = "Loading...";
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                Container(
                  child: Text(
                    text,
                    style: TextStyle(
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Theme.of(context).textTheme.bodyText1.color),
                  ),
                  padding: EdgeInsets.only(left: 35),
                )
              ],
            ),
            height: 90,
            padding: EdgeInsets.only(left: 40),
          ),
        );
      },
    );
    new Future.delayed(new Duration(seconds: duration), () {
      Navigator.pop(context); //pop dialog
    });
  }
  changeStreamStation(RadioStation station) {
    if (StreamingController.IS_PLAYING) {
      StreamingController.IS_PLAYING = false;
      streamingController.stop();
      preLoadRadio(station);
    } else {
      StreamingController.IS_PLAYING = true;
      streamingController.config(
          url: station.url,
          title: station.name,
          desc: "Live at " + station.bitrate.toString() + " kbps");
      streamingController.play();
    }
  }

  Future preLoadRadio(RadioStation station) {
    _loadingAlert(3);
    return new Future.delayed(
        const Duration(seconds: 3), () => {changeStreamStation(station)});
  }

  _containFavoriteRadio(List<RadioStation> list, RadioStation station){
    for(RadioStation r in list){
      if(r.name == station.name){
        return true;
      }
    }
    return false;
  }

}
