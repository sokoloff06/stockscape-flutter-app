import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  static Future<void> logEvent(String eventName, Map<String, dynamic> eventParams) async {
    await FirebaseAnalytics.instance.logEvent(name: eventName, parameters: eventParams);
  }
}