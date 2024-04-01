import 'package:adsense_platform_interface/adsense_platform_interface.dart';
import 'package:flutter/widgets.dart';

class Adsense {
  static AdsensePlatform instance = AdsensePlatform.instance;

  void initialize() {
    instance.initialize();
  }

  Widget adView() {
    return instance.adView();
  }
}