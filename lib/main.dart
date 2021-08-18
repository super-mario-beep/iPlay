// Flutter
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:songtube/internal/ad_state.dart';
import 'package:songtube/internal/languages.dart';
import 'package:songtube/internal/nativeMethods.dart';
import 'package:songtube/internal/randomString.dart';

// Internal
import 'package:songtube/intro/introduction.dart';
import 'package:songtube/provider/downloadsProvider.dart';
import 'package:songtube/provider/managerProvider.dart';
import 'package:songtube/provider/configurationProvider.dart';
import 'package:songtube/lib.dart';
import 'package:songtube/internal/legacyPreferences.dart';
import 'package:songtube/provider/mediaProvider.dart';

// Packages
import 'package:audio_service/audio_service.dart';
import 'package:provider/provider.dart';
import 'package:songtube/provider/preferencesProvider.dart';
import 'package:songtube/provider/videoPageProvider.dart';
import 'package:songtube/ui/internal/scrollBehavior.dart';
import 'package:newpipeextractor_dart/utils/reCaptcha.dart';
import 'package:newpipeextractor_dart/utils/navigationService.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';

// UI
import 'package:songtube/ui/internal/themeValues.dart';

// Debug
import 'package:flutter/scheduler.dart' show timeDilation;

import 'audioStreamYt.dart';

// const dsn = '';
// final sentry = SentryClient(SentryOptions(dsn: dsn));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LegacyPreferences preferences = new LegacyPreferences();
  if (AdManager.HAS_ADS) {
    MobileAds.instance.initialize();
   /* MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
        maxAdContentRating: MaxAdContentRating.g,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
        testDeviceIds: ["A012A23F9E1C0D5C6B7EFB8EFD20B1A9"]),);*/
    for (int i = 0; i < 1; i++){
      AdManager.banner = BannerAd(
          size: AdSize.banner,
          request: AdRequest(),
          listener: AdManager.listener,
          adUnitId: AdManager.bannerAdUnitId)
        ..load();
    }
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await preferences.initPreferences();
  if (kDebugMode)
    timeDilation = 1.0;
  runApp(Main(preloadedFs: preferences, prefs: prefs));

  AudioStreamPlayer.player = AudioPlayer();


  /*if(AdManager.HAS_ADS) {
    AdManager.banner = AdmobBanner(
        adUnitId: AdManager.bannerAdUnitId, adSize: AdmobBannerSize.BANNER);
    /*AdManager.interstitial = AdmobInterstitial(
      adUnitId: AdManager.interstitialAdUnitId,
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) {
          AdManager.interstitial.load();
        }
      },
    );
    AdManager.interstitial.load();*/
  }*/
}

class Main extends StatefulWidget {

  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MainState>();
    state.setLocale(newLocale);
  }

  final LegacyPreferences preloadedFs;
  final SharedPreferences prefs;

  Main({
    @required this.preloadedFs,
    @required this.prefs
  });

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {

  // Language
  Locale _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConfigurationProvider>(
            create: (context) =>
                ConfigurationProvider(preferences: widget.preloadedFs)
        ),
        ChangeNotifierProvider<ManagerProvider>(
            create: (context) => ManagerProvider()
        ),
        ChangeNotifierProvider<DownloadsProvider>(
            create: (context) => DownloadsProvider()
        ),
        ChangeNotifierProvider<MediaProvider>(
            create: (context) => MediaProvider()
        ),
        ChangeNotifierProvider<PreferencesProvider>(
          create: (context) => PreferencesProvider(widget.prefs),
        ),
        ChangeNotifierProvider<VideoPageProvider>(
          create: (context) => VideoPageProvider(),
        ),
      ],
      child: Builder(builder: (context) {
        ConfigurationProvider config = Provider.of<ConfigurationProvider>(
            context);
        ThemeData customTheme;
        ThemeData darkTheme;

        darkTheme = AppTheme.dark(config.accentColor);

        customTheme = darkTheme;


        List<Locale> supportedLocales = [];
        supportedLanguages.forEach((element) =>
            supportedLocales.add(Locale(element.languageCode, '')));

        return MaterialApp(
          locale: _locale,
          supportedLocales: supportedLocales,
          localizationsDelegates: [
            FallbackLocalizationDelegate(),
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale?.languageCode == locale?.languageCode &&
                  supportedLocale?.countryCode == locale?.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales?.first;
          },
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: child,
            );
          },
          navigatorKey: NavigationService.instance.navigationKey,
          title: "iPlay",
          theme: customTheme,
          darkTheme: darkTheme,
          initialRoute: 'homeScreen',
          routes: {
            'homeScreen': (context) =>
                AudioServiceWidget(child: Material(child: Lib())),
          },
        );
      }),
    );
  }
}
