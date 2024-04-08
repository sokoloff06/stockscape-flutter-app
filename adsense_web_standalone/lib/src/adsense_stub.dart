library adsense_web_standalone;

import 'dart:developer';

import 'package:flutter/cupertino.dart';

/// A web implementation of the AdsensePlatform of the Adsense plugin.
class Adsense {
  static final Adsense _instance = Adsense._internal();

  factory Adsense() {
    return _instance;
  }

  Adsense._internal();

  Widget adView() {
    return const Text("Unsupported platform");
  }

  void initialize() {
    log("Unsupported platform");
  }

  static setHeightUpdateListener(Function(int height) listener) {
    log("Unsupported platform");
  }
}
