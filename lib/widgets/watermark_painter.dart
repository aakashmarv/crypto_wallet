import 'dart:math';
import 'package:flutter/material.dart';

class WatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Geometric pattern - circles and lines
    // Top right circles
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.2),
      40,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.2),
      60,
      paint,
    );

    // Bottom left circles
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.8),
      35,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.8),
      50,
      paint,
    );

    // Diagonal lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(size.width * 0.2 + (i * 30), 0),
        Offset(size.width * 0.5 + (i * 30), size.height),
        linePaint,
      );
    }

    // Hex pattern (optional)
    final hexPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    _drawHexagon(canvas, Offset(size.width * 0.3, size.height * 0.3), 25, hexPaint);
    _drawHexagon(canvas, Offset(size.width * 0.7, size.height * 0.7), 30, hexPaint);
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (60 * i - 30) * 3.14159 / 180;
      double x = center.dx + radius * cos(angle);
      double y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}