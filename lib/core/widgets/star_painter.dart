import 'dart:math' as math;
import 'package:flutter/material.dart';

class IslamicStarPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final PaintingStyle style;

  IslamicStarPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.style = PaintingStyle.fill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = style
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.6;
    const points = 8;
    const angleStep = (math.pi * 2) / points;

    for (int i = 0; i < points; i++) {
      final angle = i * angleStep - math.pi / 2;
      final midAngle = angle + angleStep / 2;

      final outerPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final innerPoint = Offset(
        center.dx + innerRadius * math.cos(midAngle),
        center.dy + innerRadius * math.sin(midAngle),
      );

      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant IslamicStarPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.style != style;
  }
}

class IslamicStarDecoration extends StatelessWidget {
  final Widget child;
  final Color color;
  final double size;

  const IslamicStarDecoration({
    super.key,
    required this.child,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: IslamicStarPainter(color: color),
          ),
          child,
        ],
      ),
    );
  }
}
