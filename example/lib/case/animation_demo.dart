import 'package:flutter/material.dart';

import 'demo_painter.dart';

class AnimationDemo extends StatefulWidget {
  const AnimationDemo({Key? key}) : super(key: key);
  @override
  State<AnimationDemo> createState() => _AnimationDemoState();
}

class _AnimationDemoState extends State<AnimationDemo>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  //Here we configure the animation controller
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0,
      upperBound: 1,
    );

    //We want the motion to be both sided
    _controller.repeat(reverse: true);

    // Adding a listener to set the state is needed
    // if your widget tree needs to rebuild in each tick
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
