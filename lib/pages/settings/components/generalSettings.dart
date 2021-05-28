// Flutter
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/languages.dart';
import 'package:songtube/internal/nativeMethods.dart';
import 'package:songtube/provider/preferencesProvider.dart';

import '../../../lib.dart';

class GeneralSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    int val = prefs.homeTab;
    String currentHomeTab = "Trending";
    if(val == 1){
      currentHomeTab = "Favorites";
    }else if(val == 2){
      currentHomeTab = "Playlist";
    }

    String currentLang = "English";


    return ListView(
      children: <Widget>[
        //LANG
        ListTile(
          title: Text(
            Languages.of(context).labelLanguage,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1.color,
                fontWeight: FontWeight.w500),
          ),
          trailing: Container(
            color: Colors.transparent,
            child: DropdownButton<LanguageData>(
              iconSize: 30,
              onChanged: (LanguageData language) {
                changeLanguage(context, language.languageCode);
              },
              underline: DropdownButtonHideUnderline(child: Container()),
              items: supportedLanguages
                  .map<DropdownMenuItem<LanguageData>>(
                    (e) => DropdownMenuItem<LanguageData>(
                  value: e,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        e.name,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'YTSans',
                            fontWeight: FontWeight.w400,
                            color: e.name != currentLang ?Theme.of(context)
                                .textTheme
                                .bodyText1
                                .color : Theme.of(context).accentColor),
                      )
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ),
        //HOME TAB
        ListTile(
          subtitle: Text("Select tab to open first on your Home page. Current tab is '$currentHomeTab'",style: TextStyle(fontSize: 12)),
          title: Text(
            "Home Tab",
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1.color,
                fontWeight: FontWeight.w500),
          ),
          trailing: Container(
            color: Colors.transparent,
            child: DropdownButton<LanguageData>(
              iconSize: 30,
              onChanged: (LanguageData language) {
                String value = language.name;
                if(value == "Trending"){
                  prefs.homeTab = 0;
                }else if(value == "Favorites"){
                  prefs.homeTab = 1;
                }else if(value == "Playlist"){
                  prefs.homeTab = 2;
                }
                print("Changed home tab to: " + value);
              },
              underline: DropdownButtonHideUnderline(child: Container()),
              items: supportedTabs
                  .map<DropdownMenuItem<LanguageData>>(
                    (e) => DropdownMenuItem<LanguageData>(
                  value: e,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        e.name,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'YTSans',
                            fontWeight: FontWeight.w400,
                            color: e.name != currentHomeTab ?Theme.of(context)
                                .textTheme
                                .bodyText1
                                .color : Theme.of(context).accentColor),
                      )
                    ],
                  ),
                ),
              ).toList(),
            ),
          ),
        ),
        //AUTO DOWNLOAD
        FutureBuilder(
            future: DeviceInfoPlugin().androidInfo,
            builder: (context, AsyncSnapshot<AndroidDeviceInfo> info) {
              if (info.hasData && info.data.version.sdkInt > 29) {
                return ListTile(
                  title: Text(
                    Languages.of(context).labelAndroid11Fix,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  subtitle: Text(Languages.of(context).labelAndroid11FixJustification,
                      style: TextStyle(fontSize: 12)
                  ),
                  onTap: () {
                    NativeMethod.requestAllFilesPermission();
                  },
                );
              } else {
                return Container();
              }
            }
        ),
        if(Lib.DOWNLOADING_ENABLED && false)
          SwitchListTile(
            title: Text(
              "Auto-download music",
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1.color,
                  fontWeight: FontWeight.w500),
            ),
            subtitle: Text("Automatically downloads videos under 8 minutes",
                style: TextStyle(fontSize: 12)),
            value: prefs.autoDownload,
            onChanged: (value) => prefs.autoDownload = value,
          ),
      ],
    );
  }
}