import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class ApngGifRoute extends StatefulWidget {
  final bool precache;
  const ApngGifRoute({Key? key, required this.precache}) : super(key: key);

  @override
  State<ApngGifRoute> createState() => _ApngGifRouteState();
}

class _ApngGifRouteState extends State<ApngGifRoute> {
  late Image image_gif;
  late Image image_apng;
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
    image_gif = Image.asset("images/elephant_gif.gif");
    image_apng = Image.asset("images/elephant_apng.png");
    if (kDebugMode) {
      print('#initState, $this');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.precache) {
      precacheImage(image_gif.image, context);
      precacheImage(image_apng.image, context);
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
        title: const Text("APNG vs. GIF"),
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
                        image_gif,
                        const SizedBox(
                          height: 25,
                          child: const Text('GIF',
                              style:
                                  TextStyle(fontSize: 22, color: Colors.cyan)),
                        ),
                        image_apng,
                        const SizedBox(
                            height: 25,
                            child: const Text('APNG',
                                style: TextStyle(
                                    fontSize: 22, color: Colors.cyan))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                BoostNavigator.instance
                                    .push("flutterPage", withContainer: true);
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
