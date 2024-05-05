library adsense_web_standalone;

import 'dart:html' as html;

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import './views/ad_view_widget.dart';

/// A web implementation of the AdsensePlatform of the Adsense plugin.
class Adsense {
  static final Adsense _instance = Adsense._internal();

  factory Adsense() {
    return _instance;
  }

  Adsense._internal();

  void initialize() {
    _addMasterScript();
  }

  Widget adView(
      {required String adClient,
      required String adSlot,
      String adFormat = "auto",
      bool isAdTest = false,
      bool isFullWidthResponsive = true}) {
    var adViewWidget = AdViewWidget(
      adSlot: adSlot,
      adClient: adClient,
    );
    return adViewWidget;
  }

  static void _addMasterScript() {
    html.ScriptElement scriptElement = html.ScriptElement();
    scriptElement.async = true;
    scriptElement.src =
        "https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-0556581589806023";
    scriptElement.crossOrigin = "anonymous";
    html.document.head != null
        ? html.document.head!.append(scriptElement)
        : html.document.append(scriptElement);
  }
}
