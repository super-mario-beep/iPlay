import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:songtube/internal/radioStreamingController.dart';
import 'dart:async';

class RadioStationList extends StatefulWidget {
  final String name;

  RadioStationList(this.name);

  // Scaffold Key
  @override
  _RadioStationList createState() => _RadioStationList();
}

class RadioStation {
  String name;
  String url;
  String country;
  String favicon;
  int bitrate;

  RadioStation(this.name, this.url, this.country, this.favicon, this.bitrate);
}

class _RadioStationList extends State<RadioStationList> {
  setRadioStations(BuildContext context) async {
    final response = await http.get(
        'https://de1.api.radio-browser.info/json/stations/bycountry/' +
            widget.name);
    var json = jsonDecode(response.body);
    List<RadioStation> val = [];
    for (LinkedHashMap<String, dynamic> obj in json) {
      val.add(new RadioStation(obj["name"], obj["url"], obj["country"],
          obj["favicon"], obj["bitrate"]));
    }
    setState(() {
      stations = val;
      loading = false;
    });
  }

  List<RadioStation> stations = [];
  bool loading = true;
  var streamingController = StreamingController();

  Future preLoadRadio(RadioStation station) {
    _loadingAlert(3);
    return new Future.delayed(
        const Duration(seconds: 3), () => {changeStreamStation(station)});
  }

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (stations.isEmpty && loading) setRadioStations(context);

    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          titleSpacing: 0,
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            "Radio list",
            style: TextStyle(
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Theme.of(context).textTheme.bodyText1.color),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            color: Theme.of(context).iconTheme.color,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: stations.isNotEmpty && !loading
                  ? ListView.builder(
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
                                    Theme.of(context).textTheme.bodyText1.color,
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
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color
                                      .withOpacity(0.6)),
                            ),
                            onTap: () async {
                              changeStreamStation(station);
                            });
                      })
                  : !loading
                      ? Center(
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
                                      margin:
                                          EdgeInsets.only(left: 8, right: 8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Theme.of(context)
                                                    .accentColor
                                                    .withOpacity(0.2),
                                                blurRadius: 12,
                                                spreadRadius: 0.2)
                                          ],
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .accentColor),
                                          color: Theme.of(context).cardColor),
                                      child: Center(
                                        child: Icon(Icons.radio,
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                        )
                      : Center(
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
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Theme.of(context)
                                                  .accentColor
                                                  .withOpacity(0.2),
                                              blurRadius: 12,
                                              spreadRadius: 0.2)
                                        ],
                                        border: Border.all(
                                            color:
                                                Theme.of(context).accentColor),
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
                        ),
            )
          ],
        ),
      ),
    );
  }
}
