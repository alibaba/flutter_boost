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
  late Image sample_hdr;
  late Image sample_heic;
  late Image sample_heif;
  late Image sample_tiff;
  late Image sample_wbmp;
  late Image sample_webp;
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
    sample_hdr = Image.asset("images/sample_hdr.hdr");
    sample_heic = Image.asset("images/sample_heic.heic");
    sample_heif = Image.asset("images/sample_heif.heif");
    sample_tiff = Image.asset("images/sample_tiff.tiff");
    sample_wbmp = Image.asset("images/sample_wbmp.wbmp");
    sample_webp = Image.asset("images/sample_webp.webp");
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
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(flex: 1, child: const Text('HDR')),
                            Expanded(flex: 5, child: sample_hdr)
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(flex: 1, child: const Text('HEIC')),
                            Expanded(flex: 5, child: sample_heic)
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(flex: 1, child: const Text('HEIF')),
                            Expanded(flex: 5, child: sample_heif)
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(flex: 1, child: const Text('TIFF')),
                            Expanded(flex: 5, child: sample_tiff)
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(flex: 1, child: const Text('WBMP')),
                            Expanded(flex: 5, child: sample_wbmp)
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(flex: 1, child: const Text('WEBP')),
                            Expanded(flex: 5, child: sample_webp)
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
