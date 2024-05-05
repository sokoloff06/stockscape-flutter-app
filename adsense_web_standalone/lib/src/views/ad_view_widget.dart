import 'dart:developer';
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class AdViewWidget extends StatefulWidget {
  final String adClient;
  final String adSlot;
  final String adFormat;
  final String adLayoutKey;
  final String adLayout;
  final bool isAdTest;
  final bool isFullWidthResponsive;
  final html.Element insElement = html.document.createElement("ins");

  AdViewWidget(
      {required this.adClient,
      required this.adSlot,
      required this.adLayoutKey,
      required this.adLayout,
      required this.adFormat,
      required this.isAdTest,
      required this.isFullWidthResponsive,
      super.key}) {
    insElement
      ..className = 'adsbygoogle'
      ..style.display = 'block'
      ..dataset = Map.of({
        "adClient": "ca-pub-$adClient",
        "adSlot": adSlot,
        "adFormat": adFormat,
        "adtest": true.toString(), //isAdTest.toString(),
        "fullWidthResponsive": isFullWidthResponsive.toString()
      });
    if (adLayoutKey != "") {
      insElement.dataset.addAll({"adLayoutKey": adLayoutKey});
    }
    if (adLayout != "") {
      insElement.dataset.addAll({"adLayout": adLayout});
    }
  }

  @override
  State<AdViewWidget> createState() => _AdViewWidgetState();
}

class _AdViewWidgetState extends State<AdViewWidget> {
  static int adViewCounter = 0;
  double adHeight = 100;
  late html.HtmlElement adViewDiv;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: adHeight,
      child: HtmlElementView.fromTagName(
          tagName: "div", onElementCreated: onElementCreated, isVisible: false),
    );
  }

  static void onElementAttached(html.Element element) {
    log("onElementAttached: ${element.toString()} with style: height=${element.clientHeight} and width=${element.clientWidth}");

    // final html.Element? located = html.document.querySelector('#adView');
    // assert(located == element, 'Wrong `element` located!');
    // Do things with `element` or `located`, or call your code now...
    var pushAdsScript = html.ScriptElement();
    pushAdsScript.innerText =
        "(adsbygoogle = window.adsbygoogle || []).push({});";
    log("Adding push ads script");
    element.append(pushAdsScript);
  }

  void onElementCreated(Object element) {
    log("onElementCreated: ${element.toString()}");
    adViewDiv = element as html.HtmlElement;
    adViewDiv
      ..id = 'adView${(adViewCounter++).toString()}'
      ..style.height = "min-content"
      ..style.textAlign = "center";
    // Adding ins inside of the adView
    adViewDiv.append(widget.insElement);

    // TODO: Make shared
    final html.ResizeObserver resizeObserver = html.ResizeObserver(
        (List<dynamic> entries, html.ResizeObserver observer) {
      // We only care about resize that happens after element is attached to DOM
      for (dynamic entry in entries) {
        var target = (entry as html.ResizeObserverEntry).target;
        if (target == null) return;
        if (target.isConnected!) {
          // First time resized since attached to DOM -> attachment callback from Flutter docs by David
          if (!target.dataset.containsKey("attached")) {
            onElementAttached(target);
            target.dataset.addAll({"attached": "true"});
            updateHeight(target.clientHeight);
            // TODO: should update Flutter Widget height?
          } else {
            // Resized while being in DOM (by AdSense or by us)
            for (dynamic entry in entries) {
              if (entry is JSObject) {
                log("RO current entry: ${(entry.getProperty("target" as JSString) as JSObject).getProperty("id" as JSString).toString()}");
                JSObject? rect = entry.getProperty('contentRect' as JSString);
                if (rect != null) {
                  var newHeight = rect.getProperty('height' as JSString);
                  updateHeight(newHeight);
                }
              }
            }
          }
        }
      }
    });
    // Connect the observer.
    resizeObserver.observe(element);

    final html.MutationObserver mutationObserver = html.MutationObserver(
        (List<dynamic> entries, html.MutationObserver observer) {
      for (html.MutationRecord entry in entries) {
        log("MO entries: ${entries.length}");
        if (entry is JSObject) {
          var target = entry.target as html.Element;
          log("MO current entry: ${target.toString()}");
          var adStatus = target.dataset["adStatus"];
          switch (adStatus) {
            case "filled":
              {
                log("Ad filled");
                resizeObserver.unobserve(element);
                observer.disconnect();
              }
            case "unfilled":
              {
                log("Ad unfilled!");
                element.style.height = "0px";
              }
            default:
              log("No data-ad-status attribute found");
          }
        }
      }
    });
    mutationObserver.observe(widget.insElement,
        attributes: true, attributeFilter: ["data-ad-status"]);
  }

  void updateHeight(newHeight) {
    debugPrint("listener invoked with height $newHeight");
    setState(() {
      adHeight = newHeight.toDouble();
    });
  }
}
