import 'dart:developer';
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web';

import 'package:flutter/widgets.dart';

class AdViewWidget extends StatefulWidget {
  final Function? heightListener;

  const AdViewWidget(this.heightListener, {super.key});

  @override
  State<AdViewWidget> createState() => _AdViewWidgetState();
}

// TODO: add callback on the div size change
class _AdViewWidgetState extends State<AdViewWidget> {
  int size = 0;

  static void onElementAttached(html.Element element) {
    log("onElementAttached: ${element.toString()}");
    final html.Element? located = html.document.querySelector('#adView');
    // assert(located == element, 'Wrong `element` located!');
    // Do things with `element` or `located`, or call your code now...
    element.style.backgroundColor = 'red';

    var pushAdsScript = html.ScriptElement();
    pushAdsScript.innerText =
        "(adsbygoogle = window.adsbygoogle || []).push({});";
    log("Adding push ads script");

    element.append(pushAdsScript);
  }

  void onElementCreated(Object element) {
    log("onElementCreated: ${element.toString()}");
    element as html.HtmlElement;
    element.id = 'adView';

    // Creating ins element
    var insElement = html.document.createElement("ins");
    insElement
      // ..id = (++adViewCounter).toString()
      ..className = 'adsbygoogle'
      ..style.display = 'block'
      // ..style.pointerEvents = 'none'
      ..dataset = Map.of(
        {
          "adClient": "ca-pub-0556581589806023",
          "adSlot": "4773943862",
          "adFormat": "auto",
          "adtest": "on",
          "fullWidthResponsive": "true"
        },
      );
    // Adding ins inside of the adView
    element.append(insElement);
    // Create the observer
    final html.ResizeObserver observer = html.ResizeObserver(
        (List<dynamic> entries, html.ResizeObserver observer) {
      for (dynamic entry in entries) {
        log("entries: ${entries.length}");
        if (entry is JSObject) {
          log("current entry: ${(entry.getProperty("target" as JSString) as JSObject).getProperty("id" as JSString).toString()}");
          JSObject? rect = entry.getProperty('contentRect' as JSString);
          if (rect != null) {
            var newHeight = rect.getProperty('height' as JSString);
            if (int.parse(newHeight.toString()) != 0) {
              if (widget.heightListener != null) {
                widget.heightListener!(newHeight);
              }
            }
          }
        }
      }
      if (element.isConnected! && !element.dataset.containsKey("attached")) {
        // Call our callback.
        element.dataset.addAll({"attached": "true"});
        onElementAttached(element);
      }
    });
    // Connect the observer.
    observer.observe(element);
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
        tagName: "div", onElementCreated: onElementCreated, isVisible: true);

    // const adViewElement = HtmlElementView(
    //     onPlatformViewCreated: onPlatformViewCreated,
    //     viewType: 'adView');
    // return adViewElement;
  }
}

void onPlatformViewCreated(id) {
  log("onPlatformViewCreated: $id");
  log(PlatformViewRegistry().getViewById(id).toString());
}
