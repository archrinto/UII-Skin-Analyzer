import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/deteksi_model.dart';

class DrawInCanvas extends CustomPainter {
  DrawInCanvas({required this.objects, required this.color, required this.strokeWidth});
  final List<DeteksiModel> objects;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    for (var object in objects) {
      if (object.points != null) {
        List<Offset> points = [];

        for (var point in object.points!) {
          var dx = size.width * point[0];
          var dy = size.height * point[1];
          points.add(Offset(dx, dy));
        }

        canvas.drawPoints(PointMode.points, points, paint1);
      } else if (object.score! > 0.3) {
        var ymin = object.ymin, xmin = object.xmin, ymax = object.ymax, xmax = object.xmax;
        var left = xmin! * size.width;
        var right = xmax! * size.width;
        var top = ymin! * size.height;
        var bottom = ymax! * size.height;
        var boxH = bottom - top, boxW = right - left;
        var radius = sqrt(pow(boxH, 2) + pow(boxW, 2)) / 2;

        canvas.drawCircle(
            Offset(
              left + boxW / 2,
              top + boxH / 2,
            ),
            radius,
            paint1);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
