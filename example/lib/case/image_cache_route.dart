import 'package:flutter/material.dart';

import 'package:flutter_boost/flutter_boost.dart';
import 'apng_vs_gif_route.dart';

class ImageCacheRoute extends StatefulWidget {
  const ImageCacheRoute({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<ImageCacheRoute> createState() => _ImageCacheRouteState();
}

class _ImageCacheRouteState extends State<ImageCacheRoute> {
  bool precache = false;
  bool withContainer = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('precache'),
                      Switch(
                          value: precache,
                          onChanged: (bool value) {
                            setState(() {
                              precache = value;
                            });
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('withContainer'),
                      Switch(
                          value: withContainer,
                          onChanged: (bool value) {
                            setState(() {
                              withContainer = value;
                            });
                          }),
                    ],
                  ),
                ],
              )),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text('Asset Images'),
                  onPressed: () {
                    BoostNavigator.instance.push('assetImageRoute',
                        arguments: <String, dynamic>{'precache': precache},
                        withContainer: withContainer);
                  },
                ),
                ElevatedButton(
                  child: const Text('APNG vs. GIF'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ApngGifRoute(precache: precache)),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
