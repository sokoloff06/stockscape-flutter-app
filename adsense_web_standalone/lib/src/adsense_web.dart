library adsense_web_standalone;

import 'dart:html' as html;

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import 'ad_view_widget.dart';
import 'adsense_stub.dart';

class AdsenseWeb implements Adsense {
  static final AdsenseWeb _instance = AdsenseWeb._internal();

  factory AdsenseWeb() {
    return _instance;
  }

  AdsenseWeb._internal();

  @override
  void initialize(String adClient) {
    _addMasterScript(adClient);
  }

  @override
  Widget adView(
      {required String adClient,
      required String adSlot,
      String adLayoutKey = "",
      String adLayout = "",
      String adFormat = "auto",
      bool isAdTest = false,
      bool isFullWidthResponsive = true,
      Map<String, String> slotParams = const {}}) {
    var adViewWidget = AdViewWidget(
      adSlot: adSlot,
      adClient: adClient,
      adLayoutKey: adLayoutKey,
      adLayout: adLayout,
      adFormat: adFormat,
      isAdTest: isAdTest,
      isFullWidthResponsive: isFullWidthResponsive,
      slotParams: slotParams,
    );
    return adViewWidget;
  }

  static void _addMasterScript(String adClient) {
    html.ScriptElement scriptElement = html.ScriptElement();
    scriptElement.async = true;
    scriptElement.src =
        "https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-$adClient";
    scriptElement.crossOrigin = "anonymous";
    html.document.head != null
        ? html.document.head!.append(scriptElement)
        : html.document.append(scriptElement);
  }
}
