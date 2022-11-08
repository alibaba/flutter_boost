import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

class SimpleWebView extends StatefulWidget {
  @override
  SimpleWebViewState createState() => SimpleWebViewState();
}

class SimpleWebViewState extends State<SimpleWebView> {
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    // if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://flutter.dev',
    );
  }
}
