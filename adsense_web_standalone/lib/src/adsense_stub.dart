library adsense_web_standalone;

import 'dart:developer';

import 'package:flutter/cupertino.dart';

/// A web implementation of the AdsensePlatform of the Adsense plugin.
/// TODO: remove stub and use conditional import in the example app
class Adsense {
  static final Adsense _instance = Adsense._internal();

  factory Adsense() {
    return _instance;
  }

  Adsense._internal();

  Widget adView(
      {required String adClient,
      required String adSlot,
      String adLayoutKey = "",
      String adLayout = "",
      String adFormat = "auto",
      bool isAdTest = false,
      bool isFullWidthResponsive = true}) {
    return const Text("Unsupported platform");
  }

  void initialize(String adClient) {
    log("Unsupported platform");
  }

  static setHeightUpdateListener(Function(int height) listener) {
    log("Unsupported platform");
  }
}
