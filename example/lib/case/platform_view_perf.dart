import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_boost_example/case/native_view.dart';

class PlatformViewPerf extends StatefulWidget {
  @override
  PlatformViewPerfState createState() => PlatformViewPerfState();
}

class PlatformViewPerfState extends State<PlatformViewPerf> {
  bool withContainer = true;
  bool usingHybridComposition = false;
  final url = 'https://flutter.dev';
  final String viewType = '<simple-text-view>';

  @override
  void initState() {
    super.initState();
    if (usingHybridComposition) {
      // Enable hybrid composition.
      if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('PlatformView Perf Test'),
              actions: <Widget>[
                Text("HybridComposition"),
                Switch(
                  value: usingHybridComposition,
                  onChanged: (value) {
                    setState(() {
                      usingHybridComposition = value;
                    });
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
              ],
            ),
            body: Container(
                child: Column(children: <Widget>[
              InkWell(
                child: Container(
                    margin: const EdgeInsets.all(10.0),
                    color: Colors.yellow,
                    child: Text(
                      'Open flutter page',
                      style: TextStyle(fontSize: 20.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance
                    .push("flutterPage", withContainer: withContainer),
              ),
              InkWell(
                child: Container(
                    margin: const EdgeInsets.all(10.0),
                    color: Colors.yellow,
                    child: Text(
                      'Open another PlatformView',
                      style: TextStyle(fontSize: 20.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance.push(
                    "platformview/listview",
                    withContainer: withContainer),
              ),
              Container(
                width: 1080,
                height: 25,
                margin: const EdgeInsets.all(10.0),
                child: MaterialButton(
                  color: Colors.blue,
                  child: Text(
                    'ListView',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  onPressed: () {},
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                          itemCount: 1000,
                          itemBuilder: (BuildContext context, int index) =>
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0,
                                    top: 4.0,
                                    right: 10.0,
                                    bottom: 4.0),
                                child: Column(
                                  children: <Widget>[
                                    Card(
                                      elevation: 2.0,
                                      child: ListTile(
                                        title: Text(
                                            'Flutter ListView item ${index + 1}'),
                                      ),
                                    ),
                                    Card(
                                      elevation: 2.0,
                                      child: SizedBox(
                                        height: 70,
                                        child: NativeView(
                                            viewType, usingHybridComposition),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                    ),
                    SizedBox(
                      height: 100,
                      child: WebView(initialUrl: url),
                    ),
                  ],
                ),
              ),
            ]))));
  }
}
