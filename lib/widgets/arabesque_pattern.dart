import 'dart:math';
import 'package:flutter/material.dart';

class ArabesquePattern extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const ArabesquePattern({
    super.key,
    this.size = 180,
    this.color = Colors.white,
    this.opacity = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        size: Size(size, size),
        painter: _ArabesquePainter(color: color),
      ),
    );
  }
}

class _ArabesquePainter extends CustomPainter {
  final Color color;

  _ArabesquePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paintStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer circle
    canvas.drawCircle(center, radius * 0.9, paintStroke);
    // Middle dashed-effect circle
    canvas.drawCircle(center, radius * 0.65, paintStroke);
    // Inner circle
    canvas.drawCircle(center, radius * 0.4, paintStroke);

    // 8-pointed star / Islamic polygon
    final path = Path();
    const points = 16;
    for (int i = 0; i < points; i++) {
      final r = (i % 2 == 0) ? radius * 0.95 : radius * 0.55;
      final angle = (i * 2 * pi / points) - (pi / 2);
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paintStroke);

    // 8-pointed star rotated 45 degrees
    final path2 = Path();
    for (int i = 0; i < points; i++) {
      final r = (i % 2 == 0) ? radius * 0.75 : radius * 0.45;
      final angle = (i * 2 * pi / points) - (pi / 4);
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }
    path2.close();
    canvas.drawPath(path2, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
