import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

class ExtendedImageDemo extends StatelessWidget {
  final List<String> images = [
    "https://photo.tuchong.com/4870004/f/298584322.jpg",
    "https://photo.tuchong.com/4870004/f/298584322.jpg",
    "https://photo.tuchong.com/4870004/f/298584322.jpg",
    "https://photo.tuchong.com/4870004/f/298584322.jpg",
    "https://photo.tuchong.com/4870004/f/298584322.jpg",
    "https://photo.tuchong.com/4870004/f/298584322.jpg",
    "https://photo.tuchong.com/4870004/f/298584322.jpg",
    "https://photo.tuchong.com/4870004/f/298584322.jpg",
    "https://photo.tuchong.com/4870004/f/298584322.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Extended Image Demo'),
      ),
      body: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var image in images)
            Container(
              width: MediaQuery.of(context).size.width,
              child: ExtendedImage.network(
                image,
                fit: BoxFit.contain,
                mode: ExtendedImageMode.gesture,
                initGestureConfigHandler: (state) {
                  return GestureConfig(
                    minScale: 0.9,
                    animationMinScale: 0.7,
                    maxScale: 3.0,
                    animationMaxScale: 3.5,
                    speed: 1.0,
                    inertialSpeed: 100.0,
                    initialScale: 1.0,
                    inPageView: false,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
