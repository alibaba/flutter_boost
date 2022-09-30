// Copyright (c) 2019 Alibaba Group. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class RotationTranDemo extends StatefulWidget {
  RotationTranDemo({Key? key}) : super(key: key);

  @override
  RotationTranDemoState createState() => RotationTranDemoState();
}

class RotationTranDemoState extends State<RotationTranDemo>
    with TickerProviderStateMixin, PageVisibilityObserver {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
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
    print("RotationTranDemo - initState");
  }

  @override
  void dispose() {
    _controller.dispose();
    PageVisibilityBinding.instance.removeObserver(this);
    super.dispose();
    print("RotationTranDemo - dispose");
  }

  @override
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

  @override
  void onBackground() {
    super.onBackground();
    print("RotationTranDemo - onBackground");
  }

  @override
  void onForeground() {
    super.onForeground();
    print("RotationTranDemo - onForeground");
  }

  @override
  void onPageHide() {
    super.onPageHide();
    print("RotationTranDemo - onPageHide");
  }

  @override
  void onPageShow() {
    super.onPageShow();
    print("RotationTranDemo - onPageShow");
  }

  @override
  void didChangeDependencies() {
    PageVisibilityBinding.instance.addObserver(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
    print("RotationTranDemo - didChangeDependencies");
  }
}
