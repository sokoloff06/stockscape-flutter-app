library adsense_web_standalone;

import 'dart:html' as html;
import 'dart:ui_web';

import 'package:flutter/cupertino.dart';

import './views/ad_view_widget.dart';

/// A web implementation of the AdsensePlatform of the Adsense plugin.
class Adsense {
  static final Adsense _instance = Adsense._internal();

  factory Adsense() {
    return _instance;
  }

  Adsense._internal();

  static int adViewCounter = 0;
  static Function? onNewHeightListener =
      (newHeight) => {debugPrint("onNewHeightListener: $newHeight")};

  Widget adView() {
    const adViewWidget = AdViewWidget();
    return adViewWidget;
  }

  void initialize() {
    registerPlatformView();
    addMasterScript();
  }

  static setHeightUpdateListener(Function(int height) listener) {
    onNewHeightListener = listener;
  }

  static void registerPlatformView() {
    PlatformViewRegistry().registerViewFactory('adView', (int viewId) {
      html.Element insElement = html.document.createElement("ins");
      insElement
        ..id = (++adViewCounter).toString()
        ..className = 'adsbygoogle'
        ..style.display = 'block'
        ..dataset = Map.of(
          {
            "adClient": "ca-pub-0556581589806023",
            "adSlot": "4773943862",
            "adFormat": "x",
            "fullWidthResponsive": "true"
          },
        );
      var text = html.DivElement()
        ..text = "Ad View Placement11"
        ..style.textAlign = 'center';
      var div = html.DivElement()
        ..id = 'ad-view'
        ..style.border = 'solid black 1px'
        ..style.background = 'darkseagreen';

      html.ScriptElement pushAdsScript = html.ScriptElement();
      // pushAdsScript.innerText = "(adsbygoogle = window.adsbygoogle || []).push({});";

      insElement.addEventListener(
          "DOMNodeInserted", (event) => updateHeight(event, div));

      div.children = [text, insElement, pushAdsScript];
      return div;
    });
  }

  static void updateHeight(html.Event event, html.DivElement container) {
    debugPrint("DOMNodeInserted: ${event.target}");
    if (event.target.toString() == "iframe") {
      var height = (event.target as html.Element).clientHeight;
      debugPrint("height: $height");
      // TODO: remove container height logic (only for debugging)
      if (height != 0) {
        onNewHeightListener!(container.clientHeight + height);
      }
    }
  }

  static void addMasterScript() {
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
