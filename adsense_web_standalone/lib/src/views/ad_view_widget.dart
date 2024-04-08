import 'package:flutter/widgets.dart';

class AdViewWidget extends StatefulWidget {
  const AdViewWidget({super.key});

  @override
  State<AdViewWidget> createState() => _AdViewWidgetState();
}

// TODO: add callback on the div size change
class _AdViewWidgetState extends State<AdViewWidget> {
  int size = 0;

  @override
  Widget build(BuildContext context) {
    const adViewElement = HtmlElementView(viewType: 'adView');
    return adViewElement;
  }
}
