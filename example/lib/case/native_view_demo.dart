import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter_boost_example/case/native_view.dart';

class NativeViewExample extends StatefulWidget {
  @override
  NativeViewExampleState createState() => NativeViewExampleState();
}

class NativeViewExampleState extends State<NativeViewExample> {
  // '<color-rectangle>', '<runball-surface>', '<simple-text-view>'
  final String viewType = '<simple-text-view>';
  bool hybridCompositionMode = false;
  bool hidePlatformView = false;
  double opacity = 1.0;
  double radius = 30;
  double scale = 0.75;
  double angle = 45; // This will rotate widget in 45 degrees.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('PlatformView Example'),
              actions: <Widget>[
                const Text("HybridComposition"),
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
              Expanded(
                  flex: 2,
                  child: Stack(children: <Widget>[
                    Container(
                      constraints: BoxConstraints.expand(
                        height: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .fontSize! *
                                1.1 +
                            50.0,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.blue[600],
                      alignment: Alignment.center,
                      transform: Matrix4.rotationZ(0.75),
                      child: Text('Flutter UI: BOTTOM',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(color: Colors.white)),
                    ),
                    if (!hidePlatformView)
                      MutatorNativeView(
                        viewType: viewType,
                        isHCMode: hybridCompositionMode,
                        angle: -math.pi / 180 * angle,
                        opacity: opacity,
                        radius: radius,
                        scale: scale,
                      ),
                    Container(
                      constraints: BoxConstraints.expand(
                        height: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .fontSize! *
                                1.1 +
                            50.0,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.blue[600],
                      alignment: Alignment.center,
                      transform: Matrix4.rotationZ(0.15),
                      child: Text('Flutter UI: TOP',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(color: Colors.white)),
                    ),
                  ])),
              Expanded(
                  flex: 3,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(children: [
                          const Text("Hide platformview"),
                          Switch(
                            value: hidePlatformView,
                            onChanged: (value) {
                              setState(() {
                                hidePlatformView = value;
                              });
                            },
                            activeTrackColor: Colors.lightGreenAccent,
                            activeColor: Colors.green,
                          ),
                        ]),
                        Row(
                          children: [
                            Text('Opacity'),
                            Slider(
                              value: opacity,
                              min: 0.0,
                              max: 1.0,
                              divisions: 20,
                              activeColor: Colors.greenAccent,
                              label: opacity.toString(),
                              onChanged: (double value) {
                                setState(() {
                                  opacity = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Rotate'),
                            Slider(
                              value: angle,
                              min: 0.0,
                              max: 360.0,
                              divisions: 72,
                              activeColor: Colors.greenAccent,
                              label: angle.round().toString(),
                              onChanged: (double value) {
                                setState(() {
                                  angle = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Radius'),
                            Slider(
                              value: radius,
                              min: 0.0,
                              max: 100.0,
                              divisions: 10,
                              activeColor: Colors.greenAccent,
                              label: radius.round().toString(),
                              onChanged: (double value) {
                                setState(() {
                                  radius = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Scale'),
                            Slider(
                              value: scale,
                              min: 0.0,
                              max: 1.0,
                              divisions: 10,
                              activeColor: Colors.greenAccent,
                              label: scale.toString(),
                              onChanged: (double value) {
                                setState(() {
                                  scale = value;
                                });
                              },
                            ),
                          ],
                        ),
                        InkWell(
                          child: Container(
                              margin: const EdgeInsets.all(10.0),
                              color: Colors.yellow,
                              child: const Text(
                                'Open flutter page',
                                style: TextStyle(
                                    fontSize: 20.0, color: Colors.black),
                              )),
                          onTap: () => BoostNavigator.instance
                              .push("flutterPage", withContainer: true),
                        ),
                        InkWell(
                          child: Container(
                              margin: const EdgeInsets.all(10.0),
                              color: Colors.yellow,
                              child: const Text(
                                'Open another platform view',
                                style: TextStyle(
                                    fontSize: 20.0, color: Colors.black),
                              )),
                          onTap: () => BoostNavigator.instance.push(
                              "platformview/animation",
                              withContainer: true),
                        ),
                      ])),
            ]))));
  }
}

class MutatorNativeView extends StatelessWidget {
  const MutatorNativeView(
      {required this.viewType,
      required this.isHCMode,
      required this.angle,
      required this.opacity,
      required this.radius,
      required this.scale,
      Key? key})
      : super(key: key);
  final String viewType;
  final bool isHCMode;
  final double opacity;
  final double radius;
  final double angle;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: SizedBox(
              height: 300,
              width: 300,
              child: NativeView(viewType, isHCMode),
            ),
          ),
        ),
      ),
    );
  }
}
