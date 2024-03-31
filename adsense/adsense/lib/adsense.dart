import 'package:adsense_platform_interface/adsense_platform_interface.dart';
import 'package:flutter/widgets.dart';

class AdSense {
  AdSense();

  Widget adView() {
    return AdsensePlatform.instance.adView();
  }
}