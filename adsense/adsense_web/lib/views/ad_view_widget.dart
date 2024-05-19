import 'package:flutter/widgets.dart';

class AdViewWidget extends StatefulWidget {
  const AdViewWidget({super.key});

  @override
  State<AdViewWidget> createState() => _AdViewWidgetState();
}

class _AdViewWidgetState extends State<AdViewWidget> {
  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(viewType: 'adView');
  }
}
