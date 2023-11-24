import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockscape/screens/home_screen.dart';
import 'package:stockscape/screens/stock_detail_screen.dart';
import 'api_service.dart';
import 'firebase_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final APIService apiService =
  APIService('cjp2419r01qj85r47bhgcjp2419r01qj85r47bi0', 'iEzh6dNrbIfRncuAZdMRQ71fCLkMlD1M');

  @override
  State<MyApp> createState() => _MyAppState();


}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    initFirebase();
    initAppsFlyer();
    return MaterialApp(
      debugShowCheckedModeBanner:false,
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
        '/stockDetail': (context) => StockDetailScreen(''),
      },
    );
  }

  Future<void> initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
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

    AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions (
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
