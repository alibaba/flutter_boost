import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter_boost_example/case/animation_demo.dart';
import 'package:flutter_boost_example/case/native_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NativeViewExample extends StatefulWidget {
  @override
  NativeViewExampleState createState() => NativeViewExampleState();
}

class NativeViewExampleState extends State<NativeViewExample> {
  final String viewType1 = '<simple-text-view>';
  final String viewType2 = (defaultTargetPlatform == TargetPlatform.android)
      ? '<color-rectangle>'
      : '<simple-text-view>';
  final String viewType3 = (defaultTargetPlatform == TargetPlatform.android)
      ? '<runball-surface>'
      : '<simple-text-view>';
  bool hybridCompositionMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('PlatformView Example'),
              actions: <Widget>[
                Text("HybridComposition"),
                Switch(
                  value: hybridCompositionMode,
                  onChanged: (value) {
                    setState(() {
                      hybridCompositionMode = value;
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
                    .push("flutterPage", withContainer: true),
              ),
              InkWell(
                child: Container(
                    margin: const EdgeInsets.all(10.0),
                    color: Colors.yellow,
                    child: Text(
                      'Open another platform view',
                      style: TextStyle(fontSize: 20.0, color: Colors.black),
                    )),
                onTap: () => BoostNavigator.instance
                    .push("platformview/animation", withContainer: true),
              ),
              Expanded(
                  child: Row(children: [
                Expanded(child: NativeView(viewType3, hybridCompositionMode)),
                Expanded(child: NativeView(viewType3, hybridCompositionMode)),
              ])),
              Expanded(child: AnimationDemo()),
              Expanded(
                  child: Row(children: [
                Expanded(child: NativeView(viewType3, hybridCompositionMode)),
                Expanded(child: NativeView(viewType3, hybridCompositionMode)),
              ])),
              Expanded(child: NativeView(viewType2, hybridCompositionMode)),
              Expanded(child: NativeView(viewType1, hybridCompositionMode)),
            ]))));
  }
}
