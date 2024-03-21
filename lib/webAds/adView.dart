import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/cupertino.dart';
import 'package:web/web.dart';

// <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-6765186714303261"
// crossorigin="anonymous"></script>
// <ins class="adsbygoogle"
// style="display:block; text-align:center;"
// data-ad-layout="in-article"
// data-ad-format="fluid"
// data-ad-client="ca-pub-6765186714303261"
// data-ad-slot="3698125675"></ins>
// <script>
// (adsbygoogle = window.adsbygoogle || []).push({});
// </script>


class AdView {
  static void init() {
    ui.PlatformViewRegistry().registerViewFactory(
      'adView',
          (int viewId) {
        var insElement = html.document.createElement("ins");
        insElement
          ..className = 'adsbygoogle'
          ..style.display = 'block'
          ..dataset = Map.of(
            {
              "adClient": "ca-pub-6765186714303261",
              "adSlot": "3698125675",
              "adFormat": "auto",
              "fullWidthResponsive": "true"
            },
          );
        var text = html.DivElement()
          ..text = "Ad View Placement"
          ..style.textAlign = 'center';
        var div = html.DivElement()
          ..id = 'ad-view'
          ..style.border = 'solid black 1px'
          ..style.background = 'darkseagreen';
        div.children = [text, insElement];
        return div;
      },
    );
  }
}

class AdViewWidget extends StatelessWidget {
  const AdViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(viewType: 'adView');
  }
}
