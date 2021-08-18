import 'dart:io';

//import 'package:admob_flutter/admob_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  // ignore: non_constant_identifier_names
  static final bool HAS_ADS = false;
  static final bool TEST_AD = true;

  static BannerAd banner;
  //static AdmobInterstitial interstitial;


  static String _bannerId = 'ca-app-pub-9933506788213398/9462636795';
  static String _interstitialId = 'ca-app-pub-9933506788213398/3492958965';


  static String get bannerAdUnitId{
    return TEST_AD ? 'ca-app-pub-3940256099942544/6300978111' : _bannerId;
  }

  static String get interstitialAdUnitId{
    return TEST_AD ? 'ca-app-pub-3940256099942544/1033173712' : _interstitialId;
  }

  static final BannerAdListener listener = BannerAdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) => print('Ad loaded.'),
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      // Dispose the ad here to free resources.
      ad.dispose();
      print("mario" + error.message);
      print('mario Ad failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => print('Ad opened.'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) => print('Ad closed.'),
    // Called when an impression occurs on the ad.
    onAdImpression: (Ad ad) => print('Ad impression.'),
  );


}


/*import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState{
  // ignore: non_constant_identifier_names
  static final bool TEST_AD = true;
  Future<InitializationStatus> initialization;

  AdState(this.initialization);

  String get bannerAdUnitId{
    return TEST_AD ? 'ca-app-pub-3940256099942544/6300978111' : 'ca-app-pub-9933506788213398/9462636795';
  }
  String get interstitialAdUnitId{
    return TEST_AD ? 'ca-app-pub-3940256099942544/1033173712' : 'ca-app-pub-9933506788213398/3492958965';
  }

  BannerAdListener get adListener => listener;


  final BannerAdListener listener = BannerAdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) => print('Ad loaded.'),
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      // Dispose the ad here to free resources.
      ad.dispose();
      print('Ad failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => print('Ad opened.'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) => print('Ad closed.'),
    // Called when an impression occurs on the ad.
    onAdImpression: (Ad ad) => print('Ad impression.'),
  );
}*/