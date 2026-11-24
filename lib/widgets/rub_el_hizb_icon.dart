import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom Islamic Rub el Hizb 8-pointed star icon
class RubElHizbIcon extends StatelessWidget {
  final double size;
  final Color color;

  const RubElHizbIcon({
    super.key,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RubElHizbPainter(color: color),
    );
  }
}

class _RubElHizbPainter extends CustomPainter {
  final Color color;

  _RubElHizbPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final side = size.width * 0.72;

    // Square 1
    final rect1 = Rect.fromCenter(center: center, width: side, height: side);
    canvas.drawRRect(RRect.fromRectAndRadius(rect1, const Radius.circular(2)), paint);

    // Square 2 (rotated 45 degrees)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4);
    final rect2 = Rect.fromCenter(center: Offset.zero, width: side, height: side);
    canvas.drawRRect(RRect.fromRectAndRadius(rect2, const Radius.circular(2)), paint);
    canvas.restore();

    // Small center ring
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, 1.8, paint);
  }

  @override
  bool shouldRepaint(covariant _RubElHizbPainter oldDelegate) =>
      oldDelegate.color != color;
}
