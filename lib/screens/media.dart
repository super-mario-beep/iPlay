// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/languages.dart';
import 'package:songtube/provider/mediaProvider.dart';
import 'package:songtube/provider/preferencesProvider.dart';

// Internal
import 'package:songtube/screens/mediaScreen/tabs/musicTab.dart';
import 'package:songtube/screens/mediaScreen/tabs/videosTab.dart';

// Packages
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:songtube/ui/components/addToPlaylist.dart';
import 'package:songtube/ui/components/autoHideScaffold.dart';
import 'package:songtube/ui/components/listplaylist.dart';
import 'package:songtube/ui/components/searchBar.dart';

// UI
import 'package:songtube/ui/components/fancyScaffold.dart';

import 'homeScreen/pages/favorites.dart';
import 'homeScreen/pages/watchLater.dart';

class MediaScreen extends StatefulWidget {
  @override
  _MediaScreenState createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  // Search Controller and FocusNode
  TextEditingController searchController;
  FocusNode searchNode;

  // Current Search Query
  String searchQuery = "";
  bool showSearchBar = false;

  @override
  void initState() {
    searchController = new TextEditingController();
    searchNode = new FocusNode();
    KeyboardVisibility.onChange.listen((bool visible) {
      if (visible == false) {
        searchNode.unfocus();
      }
    });
    Provider.of<MediaProvider>(context, listen: false).getDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: AutoHideScaffold(
        backgroundColor: Theme.of(context).cardColor,
        resizeToAvoidBottomInset: false,
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
                    EvaIcons.headphonesOutline,
                    color: Theme.of(context).accentColor,
                  ),
                ),
                Text(
                  "Playlists",
                  style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Theme.of(context).textTheme.bodyText1.color),
                ),
                Spacer(),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: IconButton(
                  icon: Icon(Icons.add,
                      color: Theme.of(context).iconTheme.color),
                  onPressed: () async {
                    String name = await showDialog(
                        context: context,
                        builder: (context) {
                          return CreatePlaylistDialog();
                        });
                    if (name != null) {
                      print("New playlist created: " + name);
                      List<String> tmp = prefs.audioPlaylists;
                      tmp.add(name);
                      prefs.audioPlaylists = tmp;
                    }
                  }),
            ),
          ],
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
                  Tab(child: Text("Audio playlists")),
                  Tab(child: Text("Video playlist"))
                ],
              ),
            ),
            Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[600].withOpacity(0.1),
                indent: 12,
                endIndent: 12),
            Expanded(
              child: TabBarView(
                children: [
                  ListPlaylists(),
                  HomePageFavorites()
                  //MediaMusicTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
