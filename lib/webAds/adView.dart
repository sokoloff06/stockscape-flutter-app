import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/cupertino.dart';
import 'package:web/web.dart';

// <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-0556581589806023"
//      crossorigin="anonymous"></script>
// <script>
//      (adsbygoogle = window.adsbygoogle || []).push({});
// </script>
// <ins class="adsbygoogle"
//      style="display:block"
//      data-ad-client="ca-pub-0556581589806023"
//      data-ad-slot="9710276704"
//      data-ad-format="auto"
//      data-full-width-responsive="true"></ins>


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
              "adClient": "ca-pub-0556581589806023",
              "adSlot": "9710276704",
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
