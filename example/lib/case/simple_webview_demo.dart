import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SimpleWebView extends StatefulWidget {
  @override
  SimpleWebViewState createState() => SimpleWebViewState();
}

class SimpleWebViewState extends State<SimpleWebView> {
  final url = 'https://3g.163.com';

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Simple WebView Example'),
      ),
      body: WebView(initialUrl: url),
    ));
  }
}
