// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:newpipeextractor_dart/models/streams/audioOnlyStream.dart';
import 'package:newpipeextractor_dart/models/video.dart';
import 'package:newpipeextractor_dart/utils/httpClient.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/download/downloadItem.dart';
import 'package:songtube/internal/languages.dart';
import 'package:songtube/internal/models/tagsControllers.dart';
import 'package:songtube/provider/configurationProvider.dart';

class AudioDownloadMenu extends StatefulWidget {
  final YoutubeVideo video;
  final TagsControllers tags;
  final Function(DownloadItem) onDownload;
  final Function onBack;

  AudioDownloadMenu({
    @required this.video,
    @required this.onDownload,
    @required this.onBack,
    @required this.tags,
  });

  @override
  _AudioDownloadMenuState createState() => _AudioDownloadMenuState();
}

class _AudioDownloadMenuState extends State<AudioDownloadMenu>
    with TickerProviderStateMixin {
  // Variables
  double volumeModifier = 1;
  int bassGain = 0;
  int trebleGain = 0;
  bool normalizeAudio = false;

  void _onDownload(AudioOnlyStream streamInfo) {
    List<dynamic> list = [
      "Audio",
      streamInfo,
      volumeModifier.toString(),
      bassGain.toString(),
      trebleGain.toString(),
      normalizeAudio
    ];
    DownloadItem item = DownloadItem.fetchData(widget.video, list, widget.tags,
        Provider.of<ConfigurationProvider>(context, listen: false));
    widget.onDownload(item);
  }

  String volumeString(double value) {
    if (value == 1) {
      return "Default";
    } else if (value < 1) {
      return "-" + ((1 - value) * 100).toStringAsFixed(2) + "%";
    } else if (value > 1) {
      return "+" + (value * 100).toStringAsFixed(2) + "%";
    } else {
      return "Not Supported";
    }
  }

  @override
  Widget build(BuildContext context) {

    ConfigurationProvider config = Provider.of<ConfigurationProvider>(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Menu Title
          Container(
            margin: EdgeInsets.only(top: 8, left: 8, right: 8),
            child: Row(
              children: [
                IconButton(
                    icon: Icon(EvaIcons.arrowBackOutline),
                    onPressed: widget.onBack),
                SizedBox(width: 4),
                Text(Languages.of(context).labelSelectAudio,
                    style: TextStyle(fontSize: 20, fontFamily: "YTSans")),
              ],
            ),
          ),
          // Audio Download Options
          SizedBox(
            height: 150,
            child: ListView.builder(
              itemCount: widget.video.audioOnlyStreams.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return index == 0 ?
                 GestureDetector(
                  onTap: () {},
                  child: Container(
                      width: 220,
                      margin: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: widget.video.audioOnlyStreams[index] ==
                                    widget.video.audioWithBestAacQuality
                                ? Theme.of(context).accentColor
                                : Theme.of(context)
                                    .iconTheme
                                    .color
                                    .withOpacity(0.1),
                            width: 1.5,
                          ),
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 12,
                                color: Colors.black.withOpacity(0.04))
                          ]),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (widget.video.audioOnlyStreams[index] ==
                              widget.video.audioWithBestAacQuality)
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).accentColor,
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(10),
                                        topLeft: Radius.circular(5))),
                                child: Text(
                                  Languages.of(context).labelBest,
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(index == 0 ? EvaIcons.musicOutline : EvaIcons.lock,
                                  size: 32,
                                  color: Theme.of(context).accentColor),
                              SizedBox(height: 4),
                              Column(
                                children: [
                                  Text(
                                    "${widget.video.audioOnlyStreams[index].formatName}",
                                    overflow: TextOverflow.fade,
                                    textAlign: TextAlign.center,
                                    softWrap: false,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    "${widget.video.audioOnlyStreams[index].averageBitrate} Kbit/s",
                                    overflow: TextOverflow.fade,
                                    textAlign: TextAlign.center,
                                    softWrap: false,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  FutureBuilder(
                                      future:
                                          ExtractorHttpClient.getContentLength(
                                              widget.video
                                                  .audioOnlyStreams[index].url),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.hasData
                                              ? "${((snapshot.data / 1024) / 1024).toStringAsFixed(2)} MB"
                                              : "Loading...",
                                          overflow: TextOverflow.fade,
                                          textAlign: TextAlign.center,
                                          softWrap: false,
                                          style: TextStyle(fontSize: 10),
                                        );
                                      }),
                                ],
                              )
                            ],
                          ),
                        ],
                      )),
                ) :  Container();
              },
            ),
          ),
          // Enable Disable Conversion
          /*Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  config.enableFFmpegActionType =
                      !config.enableFFmpegActionType;
                  setState(() {});
                },
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                  padding: EdgeInsets.only(left: 12, bottom: 12, top: 4),
                  child: Row(
                    children: [
                      Checkbox(
                          value: config.enableFFmpegActionType,
                          onChanged: (_) {}),
                      Text(Languages.of(context).labelEnableAudioConversion,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500))
                    ],
                  ),
                ),
              ),
              Spacer(),
              AnimatedSwitcher(
                  duration: Duration(milliseconds: 400),
                  child: config.enableFFmpegActionType
                      ? DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            items: [
                              DropdownMenuItem<String>(
                                child: Text('AAC (.m4a)',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .color,
                                        fontWeight: FontWeight.w500)),
                                value: 'AAC',
                              ),
                              DropdownMenuItem<String>(
                                child: Text('OGG (.ogg)',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .color,
                                        fontWeight: FontWeight.w500)),
                                value: 'OGG Vorbis',
                              ),
                              DropdownMenuItem<String>(
                                child: Text('MP3 (.mp3)',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .color,
                                        fontWeight: FontWeight.w500)),
                                value: 'MP3',
                              ),
                            ],
                            onChanged: (String value) {
                              config.ffmpegActionTypeFormat = value;
                            },
                            value: config.ffmpegActionTypeFormat,
                            elevation: 1,
                            dropdownColor: Theme.of(context).cardColor,
                          ),
                        )
                      : Container()),
              SizedBox(width: 12)
            ],
          ),*/
          // Gain Controls
          Container(
            margin: EdgeInsets.only(left: 12, bottom: 16),
            child: Row(
              children: [
                Icon(EvaIcons.barChartOutline,
                    color: Theme.of(context).accentColor),
                SizedBox(width: 8),
                Text(Languages.of(context).labelGainControls,
                    style: TextStyle(fontSize: 20, fontFamily: "YTSans")),
              ],
            ),
          ),
          // Volume Modifier
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 16),
              Text(
                Languages.of(context).labelVolume + ": ",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                volumeString(volumeModifier),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
            ],
          ),
          SizedBox(
            height: 50,
            child: FlutterSlider(
              values: [volumeModifier * 100, 200],
              min: 0,
              max: 200,
              onDragging: (value, currentValue, upperValue) {
                double value = (currentValue / 100);
                value = double.parse(value.toStringAsFixed(2));
                setState(() => volumeModifier = value);
              },
              step: FlutterSliderStep(isPercentRange: true, rangeList: [
                FlutterSliderRangeStep(from: 0, to: 200, step: 5),
              ]),
              trackBar: FlutterSliderTrackBar(
                inactiveTrackBar: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).cardColor,
                ),
                activeTrackBar: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).accentColor),
              ),
              tooltip: FlutterSliderTooltip(
                disabled: true,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              SizedBox(width: 16),
              Text("-100%", style: TextStyle(fontSize: 10)),
              Spacer(),
              Text("+200%", style: TextStyle(fontSize: 10)),
              SizedBox(width: 16),
            ],
          ),
          SizedBox(height: 16),
          Flex(
            direction: Axis.horizontal,
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(width: 16),
                        Text(
                          Languages.of(context).labelBassGain + ": ",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          bassGain.toString(),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                      child: FlutterSlider(
                        values: [bassGain.toDouble(), 10],
                        min: -10,
                        max: 10,
                        onDragging: (value, currentValue, upperValue) {
                          setState(() => bassGain = currentValue.toInt());
                        },
                        step:
                            FlutterSliderStep(isPercentRange: true, rangeList: [
                          FlutterSliderRangeStep(from: -10, to: 10, step: 1),
                        ]),
                        trackBar: FlutterSliderTrackBar(
                          inactiveTrackBar: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).cardColor,
                          ),
                          activeTrackBar: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Theme.of(context).accentColor),
                        ),
                        tooltip: FlutterSliderTooltip(
                          disabled: true,
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 16),
                        Text("-10", style: TextStyle(fontSize: 10)),
                        Spacer(),
                        Text("+10", style: TextStyle(fontSize: 10)),
                        SizedBox(width: 16),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(width: 16),
                        Text(
                          Languages.of(context).labelTrebleGain + ": ",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          trebleGain.toString(),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                      child: FlutterSlider(
                        values: [trebleGain.toDouble(), 10],
                        min: -10,
                        max: 10,
                        onDragging: (value, currentValue, upperValue) {
                          setState(() => trebleGain = currentValue.toInt());
                        },
                        step:
                            FlutterSliderStep(isPercentRange: true, rangeList: [
                          FlutterSliderRangeStep(from: -10, to: 10, step: 1),
                        ]),
                        trackBar: FlutterSliderTrackBar(
                          inactiveTrackBar: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).cardColor,
                          ),
                          activeTrackBar: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Theme.of(context).accentColor),
                        ),
                        tooltip: FlutterSliderTooltip(
                          disabled: true,
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 16),
                        Text("-10", style: TextStyle(fontSize: 10)),
                        Spacer(),
                        Text("+10", style: TextStyle(fontSize: 10)),
                        SizedBox(width: 16),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 8),
         /*GestureDetector(
            onTap: () {
              setState(() => normalizeAudio = !normalizeAudio);
            },
            child: SwitchListTile(
              title: Container(
                child: Row(
                  children: [
                    Icon(EvaIcons.volumeDownOutline,
                        color: Theme.of(context).accentColor),
                    SizedBox(width: 8),
                    Text("Normalize Audio",
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).textTheme.bodyText1.color,
                            fontFamily: "YTSans")),
                  ],
                ),
              ),
              value: normalizeAudio,
              onChanged: (bool value) {
                setState(() => normalizeAudio = value);
              },
            ),
          ),*/
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: 16),
                GestureDetector(
                  onTap: () async {
                    normalizeAudio = true;
                    _onDownload(widget.video.audioOnlyStreams[0]);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(right: 16),
                    child: Row(
                      children: [
                        Icon(EvaIcons.cloudDownloadOutline,
                            color: Theme.of(context).accentColor, size: 26),
                        SizedBox(width: 8),
                        Text(
                          "Download",
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).textTheme.bodyText1.color,
                              fontFamily: "YTSans"),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            margin: EdgeInsets.only(bottom: 10, top: 10),
          ),
        ],
      ),
    );
  }
}
