import 'dart:math';
import 'package:flutter/material.dart';

class RoundedPentagonPainter extends CustomPainter {
  final Color fillColor;
  final double strokeWidth;
  final double cornerRadius;

  RoundedPentagonPainter({
    this.fillColor = Colors.blue,
    this.strokeWidth = 3.0,
    this.cornerRadius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w / 2, h / 2);
    final double radius = min(w, h) / 2;

    // Compute pentagon vertices
    final List<Offset> points = [];
    for (int i = 0; i < 5; i++) {
      final double angle = -pi / 2 + (2 * pi * i / 5);
      points.add(
        Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ),
      );
    }

    final Path path = Path();

    // Helper to get next/prev point with wraparound
    Offset prev(int i) => points[(i - 1 + 5) % 5];
    Offset next(int i) => points[(i + 1) % 5];

    // Build rounded corners
    for (int i = 0; i < 5; i++) {
      final Offset p0 = prev(i);
      final Offset p1 = points[i];
      final Offset p2 = next(i);

      final Offset v1 = (p0 - p1).directionVector();
      final Offset v2 = (p2 - p1).directionVector();

      // Compute points where the arc will start/end
      final Offset start = p1 + v1 * cornerRadius;
      final Offset end = p1 + v2 * cornerRadius;

      i == 0
          ? path.moveTo(start.dx, start.dy)
          : path.lineTo(start.dx, start.dy);

      // Create the arc for the corner
      path.quadraticBezierTo(p1.dx, p1.dy, end.dx, end.dy);
    }

    path.close();

    // Fill
    final Paint fillPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = fillColor
          ..isAntiAlias = true;
    canvas.drawPath(path, fillPaint);

    // // Stroke
    // final Paint strokePaint =
    //     Paint()
    //       ..style = PaintingStyle.stroke
    //       ..color = strokeColor
    //       ..strokeWidth = strokeWidth
    //       ..isAntiAlias = true;
    // canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant RoundedPentagonPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        // oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}

extension on Offset {
  Offset directionVector() {
    final double len = sqrt(dx * dx + dy * dy);
    return Offset(dx / len, dy / len);
  }
}
