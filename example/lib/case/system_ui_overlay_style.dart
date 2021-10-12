/// Flutter code sample for SystemChrome.setSystemUIOverlayStyle

// The following example creates a widget that changes the status bar color
// to a random value on Android.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boost/flutter_boost.dart';

/// This is the main application widget.
class SystemUiOverlayStyleDemo extends StatelessWidget {
  const SystemUiOverlayStyleDemo({Key key}) : super(key: key);

  static const String _title = 'SystemUiOverlayStyle Demo';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final math.Random _random = math.Random();
  SystemUiOverlayStyle _currentStyle = SystemUiOverlayStyle.light;

  void _changeColor() {
    final Color color = Color.fromRGBO(
      _random.nextInt(255),
      _random.nextInt(255),
      _random.nextInt(255),
      1.0,
    );
    setState(() {
      _currentStyle = SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: color,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: _currentStyle,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: const Text('Change SystemUiOverlayStyle'),
                onPressed: _changeColor,
              ),
              ElevatedButton(
                child: const Text('Open Flutter Page'),
                onPressed: () => BoostNavigator.instance
                    .push("flutterPage", withContainer: true),
              ),
            ],
          ),
        ));
  }
}
