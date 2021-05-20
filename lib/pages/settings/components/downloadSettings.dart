// Dart
import 'dart:io';

// Flutter
import 'package:flutter/material.dart';
import 'package:songtube/internal/languages.dart';

// Internal
import 'package:songtube/provider/configurationProvider.dart';

// Packages
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

// UI
import 'package:songtube/ui/dialogs/alertDialog.dart';

class DownloadSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ConfigurationProvider config = Provider.of<ConfigurationProvider>(context);
    return ListView(
      children: <Widget>[
        ListTile(
            isThreeLine: true,
            onTap: () {
              Permission.storage.request().then((status) {
                if (status == PermissionStatus.granted) {
                  FilePicker.platform.getDirectoryPath().then((path) {
                    if (path != null) {
                      config.audioDownloadPath = path;
                    }
                  });
                }
              });
            },
            title: Text(
              Languages.of(context).labelAudioFolder,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1.color,
                  fontWeight: FontWeight.w500),
            ),
            subtitle: RichText(
              text: TextSpan(style: TextStyle(fontSize: 12), children: [
                TextSpan(
                    text: Languages.of(context).labelAudioFolderJustification +
                        "\n",
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .color
                          .withOpacity(0.8),
                    )),
                TextSpan(
                    text: config.audioDownloadPath,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .color
                          .withOpacity(0.8),
                    ))
              ]),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).scaffoldBackgroundColor),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(EvaIcons.folderOutline,
                    color: Theme.of(context).iconTheme.color, size: 24),
              ),
            )),
        ListTile(
            isThreeLine: true,
            onTap: () {
              Permission.storage.request().then((status) {
                if (status == PermissionStatus.granted) {
                  FilePicker.platform.getDirectoryPath().then((path) {
                    if (path != null) {
                      config.videoDownloadPath = path;
                    }
                  });
                }
              });
            },
            title: Text(
              Languages.of(context).labelVideoFolder,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1.color,
                  fontWeight: FontWeight.w500),
            ),
            subtitle: RichText(
              text: TextSpan(style: TextStyle(fontSize: 12), children: [
                TextSpan(
                    text: Languages.of(context).labelVideoFolderJustification +
                        "\n",
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .color
                          .withOpacity(0.8),
                    )),
                TextSpan(
                    text: config.videoDownloadPath,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .color
                          .withOpacity(0.8),
                    ))
              ]),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).scaffoldBackgroundColor),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(EvaIcons.folderOutline,
                    color: Theme.of(context).iconTheme.color, size: 24),
              ),
            )),
        ListTile(
          title: Text(
            Languages.of(context).labelAlbumFolder,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1.color,
                fontWeight: FontWeight.w500),
          ),
          subtitle: Text(Languages.of(context).labelAlbumFolderJustification,
              style: TextStyle(fontSize: 12)),
          trailing: Checkbox(
            activeColor: Theme.of(context).accentColor,
            value: config.enableAlbumFolder,
            onChanged: (bool newValue) async {
              config.enableAlbumFolder = newValue;
            },
          ),
        ),
        ListTile(
            title: Text(
              Languages.of(context).labelDeleteCache,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1.color,
                  fontWeight: FontWeight.w500),
            ),
            subtitle: Text(Languages.of(context).labelDeleteCacheJustification,
                style: TextStyle(fontSize: 12)),
            trailing: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).scaffoldBackgroundColor),
              child: IconButton(
                icon: Icon(EvaIcons.trashOutline,
                    color: Theme.of(context).iconTheme.color),
                onPressed: () async {
                  double totalSize = 0;
                  String tmpPath = (await getExternalStorageDirectory()).path;
                  List<FileSystemEntity> listFiles =
                      Directory(tmpPath).listSync();
                  listFiles.forEach((element) {
                    if (element is File) {
                      totalSize += element.statSync().size;
                    }
                  });
                  totalSize = totalSize * 0.000001;
                  if (totalSize < 1) {
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return CustomAlert(
                            leadingIcon: Icon(MdiIcons.trashCan),
                            title: Languages.of(context).labelCleaning,
                            content: Languages.of(context).labelCacheIsEmpty,
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        });
                    return;
                  }
                  showDialog(
                      context: context,
                      builder: (context) {
                        return CustomAlert(
                          leadingIcon: Icon(MdiIcons.trashCan),
                          title: Languages.of(context).labelCleaning,
                          content:
                              Languages.of(context).labelYouAreAboutToClear +
                                  ": " +
                                  totalSize.toStringAsFixed(2) +
                                  "MB",
                          actions: <Widget>[
                            TextButton(
                              onPressed: () async {
                                await Directory(tmpPath)
                                    .delete(recursive: true);
                                Navigator.pop(context);
                              },
                              child: Text("OK"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(Languages.of(context).labelCancel),
                            )
                          ],
                        );
                      });
                },
              ),
            )),
        SizedBox(height: 15),
        Container(
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
                            "Attention",
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
                            "We strongly recommend that you do not change any files or directories for downloads",
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

                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              margin: EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: Icon(Icons.block,
                                    color: Theme.of(context).accentColor,size: 60,),
                              ),
                            ),
                          ),
                        ]),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
