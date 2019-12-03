
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FlutterWebPage extends StatefulWidget {
  FlutterWebPage({Key key, this.url}) : super(key: key);
  final String url;

  @override
  _FlutterWebPageState createState() => _FlutterWebPageState();
}

class _FlutterWebPageState extends State<FlutterWebPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebView(
          initialUrl: 'https://www.baidu.com/',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
        )
    );
  }
}
