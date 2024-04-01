// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui_web';

import 'package:adsense_platform_interface/adsense_platform_interface.dart';
import 'package:adsense_web/views/ad_view_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';


/// A web implementation of the AdsensePlatform of the Adsense plugin.
class AdsenseWeb extends AdsensePlatform {

  static void registerWith(Registrar registrar) {
    AdsensePlatform.instance = AdsenseWeb();
  }

  @override
  Widget adView() {
    return const AdViewWidget();
  }

  @override
  void initialize() {
    registerPlatformView();
    addMasterScript();
  }

  static void registerPlatformView() {
    PlatformViewRegistry().registerViewFactory('adView', (int viewId) {
      var insElement = html.document.createElement("ins");
      insElement
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
      div.children = [text, insElement];
      return div;
    });
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
