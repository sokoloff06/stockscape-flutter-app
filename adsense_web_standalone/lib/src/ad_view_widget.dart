import 'dart:developer';
import 'dart:html' as html;

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
  final Map<String, String> slotParams;
  final html.Element insElement = html.document.createElement("ins");

  AdViewWidget(
      {required this.adClient,
      required this.adSlot,
      required this.adLayoutKey,
      required this.adLayout,
      required this.adFormat,
      required this.isAdTest,
      required this.isFullWidthResponsive,
      required this.slotParams,
      super.key}) {
    insElement
      ..className = 'adsbygoogle'
      ..style.display = 'block'
      ..dataset = Map.of({
        "adClient": "ca-pub-$adClient",
        "adSlot": adSlot,
        "adFormat": adFormat,
        "adtest": isAdTest.toString(),
        "fullWidthResponsive": isFullWidthResponsive.toString()
      });
    if (adLayoutKey != "") {
      insElement.dataset.addAll({"adLayoutKey": adLayoutKey});
    }
    if (adLayout != "") {
      insElement.dataset.addAll({"adLayout": adLayout});
    }
    if (slotParams.isNotEmpty) {
      insElement.dataset.addAll(slotParams);
    }
  }

  @override
  State<AdViewWidget> createState() => _AdViewWidgetState();
}

class _AdViewWidgetState extends State<AdViewWidget>
    with AutomaticKeepAliveClientMixin {
  static int adViewCounter = 0;
  double adHeight = 1;
  late html.HtmlElement adViewDiv;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: adHeight,
      child: HtmlElementView.fromTagName(
          tagName: "div", onElementCreated: onElementCreated, isVisible: true),
    );
  }

  static void onElementAttached(html.Element element) {
    log("Element ${element.id} attached with style: height=${element.offsetHeight} and width=${element.offsetWidth}");

    // final html.Element? located = html.document.querySelector('#adView');
    // assert(located == element, 'Wrong `element` located!');
    // Do things with `element` or `located`, or call your code now...

    // AdsByGoogle.push(element);

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
          } else {
            // Resized while being in DOM (by AdSense or by us)
            for (html.ResizeObserverEntry entry in entries) {
              var target = entry.target!;
              log("RO current entry: ${target.id}");
              if (entry.contentRect != null &&
                  isFilled(target.children.first)) {
                updateHeight(entry.contentRect!.height);
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
        var target = entry.target as html.Element;
        log("MO current entry: ${target.toString()}");
        // isFilled(target, resizeObserver, element, observer);
        if (isFilled(target)) {
          resizeObserver.unobserve(element);
          observer.disconnect();
        }
      }
    });
    mutationObserver.observe(widget.insElement,
        attributes: true, attributeFilter: ["data-ad-status"]);
  }

  bool isFilled(html.Element target) {
    var adStatus = target.dataset["adStatus"];
    switch (adStatus) {
      case "filled":
        {
          log("Ad filled");
          return true;
        }
      case "unfilled":
        {
          log("Ad unfilled!");
          return false;
          // element.style.height = "0px";
        }
      default:
        log("No data-ad-status attribute found");
        return false;
    }
  }

  void updateHeight(newHeight) {
    debugPrint("listener invoked with height $newHeight");
    setState(() {
      adHeight = newHeight.toDouble();
    });
  }
}
