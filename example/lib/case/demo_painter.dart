import "dart:math" show pi;

import 'package:flutter/material.dart';

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
