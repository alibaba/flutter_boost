import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boost/flutter_boost.dart';

class NativeViewExample extends StatefulWidget {
  @override
  NativeViewExampleState createState() => NativeViewExampleState();
}

class NativeViewExampleState extends State<NativeViewExample> {
  bool hybridCompositionMode = true;

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
                    .push("nativeview", withContainer: true),
              ),
              Expanded(child: NativeView(hybridCompositionMode)),
              Expanded(child: NativeView(hybridCompositionMode)),
              Expanded(child: NativeView(hybridCompositionMode)),
            ]))));
  }
}

class NativeView extends StatelessWidget {
  const NativeView(this.hybridCompositionMode);
  final bool hybridCompositionMode;

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = '<platform-view-type>';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'msg': 'Hi there!',
      'hybridCompositionMode': hybridCompositionMode
    };

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Hybrid composition
        if (hybridCompositionMode) {
          return PlatformViewLink(
            viewType: viewType,
            surfaceFactory:
                (BuildContext context, PlatformViewController controller) {
              return AndroidViewSurface(
                controller: controller as AndroidViewController,
                gestureRecognizers: const <
                    Factory<OneSequenceGestureRecognizer>>{},
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            onCreatePlatformView: (PlatformViewCreationParams params) {
              return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: creationParams,
                creationParamsCodec: StandardMessageCodec(),
                onFocus: () {
                  params.onFocusChanged(true);
                },
              )
                ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
                ..create();
            },
          );
        }
        // Virtual Display
        return AndroidView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      default:
        throw UnsupportedError('Unsupported platform view');
    }
  }
}
