import 'dart:ui';
import "dart:math" show pi;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

class DemoPainter extends CustomPainter {
  final double angle;

  DemoPainter({this.angle = 0});

  @override
  void paint(Canvas canvas, Size size) {
    //Painters aren't our topic in this article,
    //but briefly it draws 2 mirrored arcs by calculating the sweep angle
    Paint paint = Paint()..color = Colors.blue;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.height / 2, size.width / 2),
        height: 150,
        width: 150,
      ),
      pi / 4 * angle,
      pi - pi / 4 * angle,
      true,
      paint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.height / 2, size.width / 2),
        height: 150,
        width: 150,
      ),
      -pi / 4 * angle,
      -pi + pi / 4 * angle,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
