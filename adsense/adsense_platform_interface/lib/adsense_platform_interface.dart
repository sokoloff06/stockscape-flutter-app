import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class AdsensePlatform extends PlatformInterface {
  /// Constructs a AdsensePlatform.
  AdsensePlatform() : super(token: _token);

  static final Object _token = Object();

  static AdsensePlatform _instance = AdsenseStub();

  /// The default instance of [AdsensePlatform] to use.
  ///
  /// Defaults to [MethodChannelAdsense].
  static AdsensePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AdsensePlatform] when
  /// they register themselves.
  static set instance(AdsensePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Widget adView();

  void initialize();
}

class AdsenseStub extends AdsensePlatform {
  @override
  Widget adView() {
    // TODO: implement adView
    throw UnimplementedError();
  }

  @override
  void initialize() {
    // TODO: implement initialize
  }
}
