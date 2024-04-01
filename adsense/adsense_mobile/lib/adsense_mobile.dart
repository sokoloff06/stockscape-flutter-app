import 'package:adsense_mobile/views/native_ad.dart';
import 'package:adsense_platform_interface/adsense_platform_interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A mobile implementation of the AdsensePlatform of the Adsense plugin.
class AdsenseMobile extends AdsensePlatform {
  static void registerWith() {
    AdsensePlatform.instance = AdsenseMobile();
  }

  @override
  Widget adView() {
    const adView = NativeAdViewSmall();

    return const NativeAdViewSmall();
  }

  @override
  void initialize() {
    MobileAds.instance.initialize();
  }
}
