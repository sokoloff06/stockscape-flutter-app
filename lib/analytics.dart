import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:google_adsense/adsense.dart';

import 'firebase_options.dart';

class Analytics {
  static Analytics instance = Analytics();
  late AppsflyerSdk? appsflyerSdk;

  Future<void> logEvent(
      String eventName, Map<String, dynamic> eventParams) async {
    await FirebaseAnalytics.instance
        .logEvent(name: eventName, parameters: eventParams);
    if (!kIsWeb) {
      appsflyerSdk!.logEvent(eventName, eventParams);
    }
  }

  void initSDKs() {
    _initFirebase();
    if (!kIsWeb) {
      _initAppsFlyer();
    } else {
      Adsense().initialize("0556581589806023");
    }
  }

  static Future<void> _initFirebase() async {
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

  void _initAppsFlyer() {
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

    appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
    appsflyerSdk!.initSdk();
  }

  void logViewItem(String currency, double value,
      List<AnalyticsEventItem>? items, Map<String, Object>? params) {
    FirebaseAnalytics.instance.logViewItem(
        currency: currency, value: value, items: items, parameters: params);
    if (!kIsWeb) {
      var eventValues = {
        "items": items.toString(),
        "currency": currency,
        "value": value
      };
      if (params != null) eventValues.addAll(params);
      appsflyerSdk!.logEvent("af_content_view", eventValues);
    }
  }

  void logPurchase(
      String? currency, double value, List<AnalyticsEventItem>? items) {
    FirebaseAnalytics.instance
        .logPurchase(currency: currency, value: value, items: items);
    if (!kIsWeb) {
      var itemNames = items?.map((e) => e.itemName).toList();
      var eventValues = {
        "items": itemNames,
        "af_currency": currency,
        "af_revenue": value
      };
      appsflyerSdk!.logEvent("af_purchase", eventValues);
    }
  }
}
