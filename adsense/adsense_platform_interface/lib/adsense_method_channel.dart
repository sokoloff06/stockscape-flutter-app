import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'adsense_platform_interface.dart';

/// An implementation of [AdsensePlatform] that uses method channels.
class MethodChannelAdsense extends AdsensePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('adsense');

  @override
  Widget adView() {
    throw UnimplementedError();
  }
}
