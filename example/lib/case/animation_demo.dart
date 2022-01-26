import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import 'package:flutter_boost_example/case/demo_painter.dart';

class AnimationDemo extends StatefulWidget {
  _AnimationDemoState createState() => _AnimationDemoState();
}

class _AnimationDemoState extends State<AnimationDemo>
    with TickerProviderStateMixin {
  AnimationController _controller;

  //Here we configure the animation controller
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
      lowerBound: 0,
      upperBound: 1,
    );

    //We want the motion to be both sided
    _controller.repeat(reverse: true);

    //Adding a listener to set the state is needed
    //if your widget tree needs to rebuild in each tick
    _controller.addListener(() {
      setState(() {});
    });
  }

  //Don't forget to dispose a controller, once the widget is no longer visible
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //I use the controller value directly as a parameter to a painter widget
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DemoPainter(angle: _controller.value),
    );
  }
}
