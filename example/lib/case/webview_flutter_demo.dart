import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_boost/boost_navigator.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewExample extends StatefulWidget {
  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {
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
              title: const Text('WebView Example'),
            ),
            body: Container(
                child: Column(children: <Widget>[
              Container(
                margin: const EdgeInsets.all(10.0),
                child: TextFormField(
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter something...'),
                ),
              ),
              InkWell(
                child: Container(
                    margin: const EdgeInsets.all(10.0),
                    color: Colors.yellow,
                    child: Text(
                      'open flutter page',
                      style: TextStyle(fontSize: 22.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance
                    .push("flutterPage", withContainer: true),
              ),
              Expanded(
                  child: Container(
                margin: const EdgeInsets.all(10.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                child: WebView(
                  initialUrl: 'https://github.com/alibaba/flutter_boost',
                ),
              )),
            ]))));
  }
}
