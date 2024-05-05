library adsense_web_standalone;

import 'dart:html' as html;
import 'dart:ui_web';

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

  static Function? onNewHeightListener =
      (newHeight) => {debugPrint("onNewHeightListener: $newHeight")};

  Widget adView(Function(int height)? heightListener) {
    var adViewWidget = AdViewWidget(heightListener);
    return adViewWidget;
  }

  void initialize() {
    // registerPlatformView();
    addMasterScript();
  }

  static setHeightUpdateListener(Function(int height) listener) {
    onNewHeightListener = listener;
  }

  // static void registerPlatformView() {
  //   PlatformViewRegistry().registerViewFactory('adView', (int viewId) {
  //     var text = html.DivElement()..text = "Ad View Placement11";
  //
  //     var insElement = html.document.createElement("ins");
  //     insElement
  //       ..id = (++adViewCounter).toString()
  //       ..className = 'adsbygoogle'
  //       ..style.display = 'block'
  //       ..dataset = Map.of(
  //         {
  //           "adClient": "ca-pub-0556581589806023",
  //           "adSlot": "4773943862",
  //           "adFormat": "auto",
  //           "adtest": "on",
  //           "fullWidthResponsive": "true"
  //         },
  //       );
  //     insElement.addEventListener(
  //         "DOMNodeInserted", (event) => onAdInserted(event, text));
  //
  //     var pushAdsScript = html.ScriptElement();
  //     pushAdsScript.innerText =
  //         "(adsbygoogle = window.adsbygoogle || []).push({});";
  //     // "performance.mark(\"eval script\");"
  //     // "setTimeout(() => {"
  //     //     "performance.mark(\"run ads\");"
  //     //     "console.log(\"push ads\");"
  //     //     "(adsbygoogle = window.adsbygoogle || []).push({});"
  //     //     "}, "
  //     // "1000);";
  //
  //     var div = html.DivElement()
  //       ..id = 'ad-view'
  //       ..style.border = 'solid black 1px'
  //       ..style.textAlign = 'center'
  //       ..style.background = 'darkseagreen';
  //
  //     div.children = [text, insElement, pushAdsScript];
  //     return div;
  //   });
  // }

  static void onAdInserted(html.Event event, html.DivElement offsetElement) {
    debugPrint("DOMNodeInserted: ${event.target}");
    if (["iframe", "ins"].contains(event.target.toString())) {
      var target = (event.target as html.Element);
      var height = target.clientHeight;
      var width = target.clientWidth;
      var offsetHeight = target.offsetHeight;
      var offsetWidth = target.offsetWidth;
      debugPrint(
          "height=$height; width=$width; offsetHeight=$offsetHeight; offsetWidth=$offsetWidth;");
      // TODO: remove offsetElement height logic (only for debugging)
      if (height != 0) {
        onNewHeightListener!(offsetElement.clientHeight + height);
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
