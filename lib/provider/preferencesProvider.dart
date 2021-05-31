import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:songtube/internal/models/playlist.dart';
import 'package:songtube/internal/radioStationList.dart';

import 'mediaProvider.dart';

class PreferencesProvider extends ChangeNotifier {

  PreferencesProvider(prefsInstance) {
    prefs = prefsInstance;
  }

  // Preferences Instance
  SharedPreferences prefs;

  // Favorites Videos
  List<StreamInfoItem> get favoriteVideos {
    var map = jsonDecode(prefs.getString('newFavoriteVideos') ?? "{}");
    List<StreamInfoItem> videos = [];
    if (map.isNotEmpty) {
      if (map['favoriteVideos'].isNotEmpty) {
        map['favoriteVideos'].forEach((v) {
          videos.add(StreamInfoItem.fromMap(v));
        });
      }
    }
    return videos;
  }
  set favoriteVideos(List<StreamInfoItem> videos) {
    var map = videos.map((e) {
      return e.toMap();
    }).toList();
    String json = jsonEncode({ 'favoriteVideos': map });
    prefs.setString('newFavoriteVideos', json).then((_) {
      notifyListeners();
    });
  }
  bool favoriteHasVideo(StreamInfoItem stream) {
    List<StreamInfoItem> videos = favoriteVideos;
    int index = videos.indexWhere((element) => element.id == stream.id);
    if (index == -1) {
      return false;
    } else {
      return true;
    }
  }

  // Watch Later Videos
  List<StreamInfoItem> get watchLaterVideos {
    var map = jsonDecode(prefs.getString('newWatchLaterList') ?? "{}");
    List<StreamInfoItem> videos = [];
    if (map.isNotEmpty) {
      if (map['watchLaterList'].isNotEmpty) {
        map['watchLaterList'].forEach((v) {
          videos.add(StreamInfoItem.fromMap(v));
        });
      }
    }
    return videos;
  }
  set watchLaterVideos(List<StreamInfoItem> videos) {
    var map = videos.map((e) {
      return e.toMap();
    }).toList();
    String json = jsonEncode({ 'watchLaterList': map });
    prefs.setString('newWatchLaterList', json).then((_) {
      notifyListeners();
    });
  }
  bool watchLaterHasVideo(StreamInfoItem stream) {
    List<StreamInfoItem> videos = watchLaterVideos;
    int index = videos.indexWhere((element) => element.id == stream.id);
    if (index == -1) {
      return false;
    } else {
      return true;
    }
  }

  // View History Videos
  List<StreamInfoItem> get viewHistory {
    var map = jsonDecode(prefs.getString('newViewHistory') ?? "{}");
    List<StreamInfoItem> videos = [];
    if (map.isNotEmpty) {
      if (map['viewHistory'].isNotEmpty) {
        map['viewHistory'].forEach((v) {
          videos.add(StreamInfoItem.fromMap(v));
        });
      }
    }
    return videos;
  }
  set addVideoToViewHistory(StreamInfoItem video) {
    List<StreamInfoItem> videos = viewHistory;
    videos.add(video);
    var map = videos.map((e) {
      return e.toMap();
    }).toList();
    String json = jsonEncode({ 'viewHistory': map });
    prefs.setString('newViewHistory', json).then((_) {
      notifyListeners();
    });
  }

  // Join Telegram Dialog
  bool get showJoinTelegramDialog {
    return false;
  }
  set showJoinTelegramDialog(bool value) {
    prefs.setBool('joinTelegramDialog', value);
  }
  // Remind Later
  bool remindTelegramLater = false;

  // Enable/Disable App's BlurUI
  bool get enableBlurUI {
    return prefs.getBool('enable_BlurUI') ?? false;
  }
  set enableBlurUI(bool value) {
    prefs.setBool('enable_BlurUI', value);
    notifyListeners();
  }

  bool get enablePlayerBlurBackground {
    return prefs?.getBool('enablePlayerBlurBackground') ?? true;
  }
  set enablePlayerBlurBackground(bool value) {
    prefs.setBool('enablePlayerBlurBackground', value);
    notifyListeners();
  }

  // MusicPlayer Artwork Rounded Corners
  double get musicPlayerArtworkRoundCorners {
    return prefs.getDouble('musicPlayerArtworkRoundCorners') ?? 20;
  }
  set musicPlayerArtworkRoundCorners(double value) {
    prefs.setDouble('musicPlayerArtworkRoundCorners', value);
    notifyListeners();
  }

  // Youtube Auto-Play
  bool get youtubeAutoPlay {
    return prefs.getBool('youtubeAutoPlay') ?? true;
  }
  set youtubeAutoPlay(bool value) {
    prefs.setBool('youtubeAutoPlay', value);
    notifyListeners();
  }

  // Watch History
  List<StreamInfoItem> get watchHistory {
    String json = prefs.getString('newWatchHistory');
    if (json == null) return [];
    var map = jsonDecode(json);
    List<StreamInfoItem> history = [];
    if (map.isNotEmpty) {
      map.forEach((element) {
        history.add(StreamInfoItem.fromMap(element));
      });
    }
    return history;
  }
  set watchHistory(List<StreamInfoItem> history) {
    List<Map<String, dynamic>> map =
      history.map((e) => e.toMap()).toList();
    prefs.setString('newWatchHistory', jsonEncode(map));
    notifyListeners();
  }
  void watchHistoryInsert(dynamic video) {
    List<StreamInfoItem> history = watchHistory;
    history.add(video);
    watchHistory = history;
  }

  // ------------------------------------
  // Stream Playlists Creation/Management
  // ------------------------------------
  set streamPlaylists(List<StreamPlaylist> playlists) {
    String json = StreamPlaylist.listToJson(playlists);
    prefs.setString('playlists', json);
    notifyListeners();
  }
  List<StreamPlaylist> get streamPlaylists {
    String json = prefs.getString('playlists') ?? "";
    return StreamPlaylist.fromJsonList(json);
  }
  void streamPlaylistCreate(String playlistName, String author, List<StreamInfoItem> streams) {
    StreamPlaylist playlist = StreamPlaylist(
      name: playlistName,
      author: author,
      streams: streams,
      favorited: false
    );
    List<StreamPlaylist> playlists = streamPlaylists;
    playlists.add(playlist);
    streamPlaylists = playlists;
  }
  void streamPlaylistRemove(String playlistName) {
    List<StreamPlaylist> playlists = streamPlaylists;
    int index = playlists.indexWhere((element) => element.name == playlistName);
    if (index == -1) return;
    playlists.removeAt(index);
    streamPlaylists = playlists;
  }
  void streamPlaylistsInsertStream(String playlistName, StreamInfoItem stream) {
    List<StreamPlaylist> playlists = streamPlaylists;
    int index = playlists.indexWhere((element) => element.name == playlistName);
    if (index == -1) return;
    playlists[index].streams.add(stream);
    streamPlaylists = playlists;
  }
  void streamPlaylistRemoveStream(String playlistName, StreamInfoItem stream) {
    List<StreamPlaylist> playlists = streamPlaylists;
    int index = playlists.indexWhere((element) => element.name == playlistName);
    if (index == -1) return;
    playlists[index].streams.removeWhere((element) => element.id == stream.id);
    if (playlists[index].streams.isEmpty) {
      playlists.removeAt(index);
    }
    streamPlaylists = playlists;
  }
  bool streamPlaylistHasStream(String playlistName, StreamInfoItem stream) {
    List<StreamPlaylist> playlists = streamPlaylists;
    int playlistIndex = playlists.indexWhere((element) => element.name == playlistName);
    if (playlistIndex == -1) return false;
    StreamPlaylist playlist = playlists[playlistIndex];
    int streamIndex = playlist.streams.indexWhere((element) => element.id == stream.id);
    if (streamIndex == -1) {
      return false;
    } else {
      return true;
    }
  }

  // Youtube Player last set quality
  String get youtubePlayerQuality {
    return prefs.getString('youtubePlayerQuality') ?? "720";
  }
  set youtubePlayerQuality(String quality) {
    prefs.setString('youtubePlayerQuality', quality);
    notifyListeners();
  }

  // Enable/Disable Youtube Music Screen
  bool get enableYoutubeMusicScreen {
    return true;
  }
  set enableYoutubeMusicScreen(bool value) {
    prefs.setBool('enableYoutubeMusicScreen', true);
    notifyListeners();
  }


  /* ******************************* CUSTOM ******************************* */
  //Enable auto-download
  bool get autoDownload{
    return prefs.getBool('autoDownload') ?? true;
  }
  set autoDownload(bool value){
    prefs.setBool('autoDownload',value);
    notifyListeners();
  }

  //Set home page shown tab
  int get homeTab{
    return prefs.getInt('homeTab') ?? 0;
  }
  set homeTab(int value){
    prefs.setInt('homeTab',value);
    notifyListeners();
  }

  //Save audio playlists names
  List<String> get audioPlaylists{
    List<String> l = [];
    return prefs.getStringList('audioPlaylists') ?? l;
  }
  set audioPlaylists(List<String> value){
    prefs.setStringList('audioPlaylists', value);
    notifyListeners();
  }
  void printPlaylists(){
    List<String> list = prefs.getStringList('audioPlaylists') ?? [];
    print("Printing playlists: ");
    for(String item in list){
      print(item);
    }
    print("----END OF PLAYLISTS----");
  }

  String get homeTabPlaylist{
    return prefs.getString('homeTabPlaylist') ?? "";
  }
  set homeTabPlaylist(String value){
    prefs.setString('homeTabPlaylist', value);
    notifyListeners();
  }

  //Set & Get songs in playlist
  List<String> getSongsForPlaylist(String playlistName){
    List<String> l = [];
    return prefs.getStringList(playlistName) ?? l;
  }
  void setSongsForPlaylist(String playlistName, List<String> songs){
    prefs.setStringList(playlistName, songs);
  }
  void printSongsInPlaylist(String playlistName){
    List<String> list = prefs.getStringList(playlistName) ?? [];
    print("Printing songs in playlist: " + playlistName);
    for(String item in list){
      print(item);
    }
    print("----END OF PLAYLIST----");
  }

  //Get main playlist
  String get mainPlaylist{
    return prefs.getString('mainPlaylist') ?? "";
  }
  set mainPlaylist(String value){
    prefs.setString('mainPlaylist', value);
    notifyListeners();
  }

  List<MediaItem> getAllMediaFromPlaylist(String playlistName, BuildContext context){
    MediaProvider mediaProvider = Provider.of<MediaProvider>(context);
    List<String> songsNames = getSongsForPlaylist(playlistName);
    List<MediaItem> items = [];
    if(playlistName == "")
      return items;
    for(MediaItem item in mediaProvider.databaseSongs){
      if(songsNames.contains(item.title))
        items.add(item);
    }
    return items.toSet().toList();
  }

  //Get favorite radios
  List<RadioStation> get favoriteRadios {
    var map = jsonDecode(prefs.getString('newFavoriteRadios') ?? "{}");
    List<RadioStation> radios = [];
    if (map.isNotEmpty) {
      if (map['favoriteRadios'].isNotEmpty) {
        map['favoriteRadios'].forEach((v) {
          radios.add(RadioStation.fromMap(v));
        });
      }
    }
    return radios;
  }
  set favoriteRadios(List<RadioStation> radios) {
    var map = radios.map((e) {
      return e.toMap();
    }).toList();
    String json = jsonEncode({ 'favoriteRadios': map });
    prefs.setString('newFavoriteRadios', json).then((_) {
      notifyListeners();
    });
  }

  //Favorite color fix
  int get favoriteColor{
    return prefs.getInt('favoriteColor') ?? 0;
  }
  set favoriteColor(int value){
    prefs.setInt('favoriteColor', value);
    notifyListeners();
  }

  //Shuffle
  bool get shuffle{
    return prefs.getBool('shuffle') ?? false;
  }
  set shuffle(bool value){
    prefs.setBool('shuffle', value);
    notifyListeners();
  }


}