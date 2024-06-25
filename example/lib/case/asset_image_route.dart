import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class AssetImageRoute extends StatefulWidget {
  final bool precache;
  const AssetImageRoute({Key? key, required this.precache}) : super(key: key);

  @override
  State<AssetImageRoute> createState() => _AssetImageRouteState();
}

class _AssetImageRouteState extends State<AssetImageRoute> {
  late Image image1;
  late Image image2;
  static const int seconds = 3;
  bool isTimerFinished = false;
  Timer? timer;
  bool withContainer = true;

  @override
  void dispose() {
    super.dispose();
    if (kDebugMode) {
      print('#dispose, $this');
    }
    timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    if (widget.precache) {
      timer = Timer(
        const Duration(seconds: seconds),
        () {
          // Execute your code here
          setState(() {
            isTimerFinished = true;
          });
        },
      );
    }
    image1 = Image.asset("images/picture1.jpg");
    image2 = Image.asset("images/picture2.jpg");
    if (kDebugMode) {
      print('#initState, $this');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.precache) {
      precacheImage(image1.image, context);
      precacheImage(image2.image, context);
    }

    if (kDebugMode) {
      print('#didChangeDependencies, precache=${widget.precache}, $this');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('#build, $this');
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Precache Images Demo"),
        actions: <Widget>[
          Switch(
            value: withContainer,
            onChanged: (value) {
              setState(() {
                withContainer = value;
              });
            },
            activeTrackColor: Colors.yellow,
            activeColor: Colors.orangeAccent,
          ),
        ],
      ),
      body: Center(
        child: (isTimerFinished || !widget.precache)
            ? SingleChildScrollView(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        image1,
                        image2,
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                BoostNavigator.instance.push("flutterPage",
                                    withContainer: withContainer);
                              },
                              child: const Text('Open flutter page'),
                            ),
                            const SizedBox(
                              width: 25,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Go back!'),
                            ),
                          ],
                        ),
                      ],
                    )))
            : Container(
                alignment: Alignment.center,
                child: const Text('Waiting $seconds seconds for precache...'),
              ),
      ),
    );
  }
}
