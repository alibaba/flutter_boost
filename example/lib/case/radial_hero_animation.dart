// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

// A "radial transition" that slightly differs from the Material
// motion spec:
// - The circular *and* the rectangular clips change as t goes from
//   0.0 to 1.0. (The rectangular clip doesn't change in the
//   Material motion spec.)
// - This requires adding LayoutBuilders and computing t.
// - The key is that the rectangular clip grows more slowly than the
//   circular clip.

import 'dart:math';

import 'package:flutter/material.dart';

class RadialExpansionDemo extends StatelessWidget {
  static const double kMinRadius = 32.0;
  static const double kMaxRadius = 128.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Radial Transition Demo'), centerTitle: true),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(height: 50),
            Container(
              width: MediaQuery.of(context).size.width - 100,
              child: Text(
                'Click to show big picture in popup window...',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            _buildHero(context, 'images/flutter.png', 'Click to return...')
          ],
        ),
      ),
    );
  }

  Widget _buildHero(
      BuildContext context, String imageName, String description) {
    return Container(
      width: kMinRadius * 2.0,
      height: kMinRadius * 2.0,
      child: Hero(
        createRectTween: _createRectTween,
        tag: imageName + "${context.hashCode}",
        child: RadialExpansion(
          maxRadius: kMaxRadius,
          child: Photo(
            photo: imageName,
            onTap: () async {
              Navigator.of(context).push(
                PhotoGalleryFadeRouter(
                  _buildPage(context, imageName, description),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage(
      BuildContext context, String imageName, String description) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).pop();
      },
      child: Container(
          color: Colors.black.withAlpha(200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: Card(
                  elevation: 8.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: kMaxRadius * 2.0,
                        height: kMaxRadius * 2.0,
                        child: Hero(
                          createRectTween: _createRectTween,
                          tag: imageName + '${context.hashCode}',
                          child: RadialExpansion(
                            maxRadius: kMaxRadius,
                            child: Photo(photo: imageName),
                          ),
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  static RectTween _createRectTween(Rect begin, Rect end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }
}

class Photo extends StatelessWidget {
  Photo({Key key, this.photo, this.color, this.onTap}) : super(key: key);

  final String photo;
  final Color color;
  final VoidCallback onTap;

  Widget build(BuildContext context) {
    return Material(
      // Slightly opaque color appears where the image has transparency.
      color: Theme.of(context).primaryColor.withOpacity(0.25),
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints size) {
            return Image.asset(photo, fit: BoxFit.contain);
          },
        ),
      ),
    );
  }
}

class RadialExpansion extends StatelessWidget {
  RadialExpansion({
    Key key,
    this.maxRadius,
    this.child,
  })  : clipRectSize = 2.0 * (maxRadius / sqrt2),
        super(key: key);

  final double maxRadius;
  final clipRectSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Center(
        child: SizedBox(
          width: clipRectSize,
          height: clipRectSize,
          child: ClipRect(child: child),
        ),
      ),
    );
  }
}

class PhotoGalleryFadeRouter extends PageRouteBuilder {
  final Widget widget;

  @override
  bool get opaque => false;

  PhotoGalleryFadeRouter(this.widget)
      : super(
          transitionDuration: Duration(milliseconds: 300),
          pageBuilder: (BuildContext context, Animation<double> animation1,
              Animation<double> animation2) {
            return widget;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation1,
              Animation<double> animation2,
              Widget child) {
            return FadeTransition(
              opacity: Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                    parent: animation1, curve: Curves.fastOutSlowIn),
              ),
              child: child,
            );
          },
        );
}
