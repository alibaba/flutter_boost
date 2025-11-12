import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

class SimpleWebView extends StatefulWidget {
  @override
  SimpleWebViewState createState() => SimpleWebViewState();
}

class SimpleWebViewState extends State<SimpleWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://flutter.dev'));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}
