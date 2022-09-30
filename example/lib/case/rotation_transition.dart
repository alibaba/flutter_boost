// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class RotationTranDemo extends StatefulWidget {
  RotationTranDemo({Key? key}) : super(key: key);

  @override
  RotationTranDemoState createState() => RotationTranDemoState();
}

class RotationTranDemoState extends State<RotationTranDemo>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 3000),
        vsync: this,
        value: 0.25,
        lowerBound: 0.25,
        upperBound: 0.5);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);

    // _controller.forward();
    _controller.repeat(reverse: true);

    // Adding a listener to set the state is needed
    // if your widget tree needs to rebuild in each tick
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Afterimage Test'),
      ),
      body: Container(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  'There may be an afterimage after coming back from the background on Android.'),
              RotationTransition(
                  turns: _animation,
                  child: Text('~~ I rotate, rotate, rotate... ～~',
                      style: TextStyle(color: Colors.red, fontSize: 24))),
            ]),
      ),
    );
  }
}
