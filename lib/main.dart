import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_adsense/adsense.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockscape/ui/home_screen.dart';
import 'package:stockscape/ui/stock_detail_screen.dart';

import 'api_service.dart';
import 'firebase_options.dart';
import 'models/favorites.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
        path: '/stocks/:symbol',
        builder: (context, state) =>
            StockDetailScreen(state.pathParameters['symbol']!))
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  FavoritesModel(prefs);
  Cache(prefs);
  runApp(ChangeNotifierProvider(
      create: (BuildContext context) {
        return FavoritesModel.getInstance();
      },
      child: const MyApp()));
}

class MyApp extends StatefulWidget {
  static const IS_DEBUG_BUILD = true;
  static final APIService apiService = APIService(
      'cjp2419r01qj85r47bhgcjp2419r01qj85r47bi0',
      'iEzh6dNrbIfRncuAZdMRQ71fCLkMlD1M');

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<SharedPreferences> futurePrefs = SharedPreferences.getInstance();
  late SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    futurePrefs.then((value) => () {
          prefs = value;
        });
    initFirebase();
    if (!kIsWeb) {
      initAppsFlyer();
    } else {
      Adsense().initialize("0556581589806023");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stock Market App',
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/stockDetail': (context) => const StockDetailScreen(''),
      },
    );
  }

  Future<void> initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  void initAppsFlyer() {
    const afDevKey = 'LadcyeEpUmDJAMWDYEsZfH';
    const appId = '6464097305';

    AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
      afDevKey: afDevKey,
      appId: appId,
      showDebug: true,
      timeToWaitForATTUserAuthorization: 15, // for iOS 14.5
      // appInviteOneLink: oneLinkID, // Optional field
      // disableAdvertisingIdentifier: false, // Optional field
      // disableCollectASA: false
    ); // Optional field

    AppsflyerSdk appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
    appsflyerSdk.initSdk();
  }
}
