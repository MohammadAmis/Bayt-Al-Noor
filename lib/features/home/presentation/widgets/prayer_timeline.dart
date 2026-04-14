import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/design_tokens.dart';

class PrayerTimeline extends StatefulWidget {
  const PrayerTimeline({super.key});

  @override
  State<PrayerTimeline> createState() => _PrayerTimelineState();
}

class _PrayerTimelineState extends State<PrayerTimeline>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow/ring for the current prayer (Animated breathing)
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryFixed
                        .withValues(alpha:0.15 * _animation.value),
                    blurRadius: 60 * _animation.value,
                    spreadRadius: 10 * _animation.value,
                  ),
                ],
              ),
            ),

            // Main Circle Background (Glassmorphism effect)
            ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceContainerLowest.withValues(alpha:0.75),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha:0.2),
                      width: 1,
                    ),
                  ),
                  child: CustomPaint(
                    painter: TimelinePainter(pulseValue: _animation.value),
                  ),
                ),
              ),
            ),

            // Center Content (Digital Time)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '6:45',
                  style: AppTypography.display.copyWith(
                    fontSize: 72,
                    color: AppColors.onSurface,
                    letterSpacing: -2,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'MAGHRIB',
                  style: AppTypography.label.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 4,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class TimelinePainter extends CustomPainter {
  final double pulseValue;

  TimelinePainter({required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw the subtle background ring
    final bgRingPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha:0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 10, bgRingPaint);

    // Draw the 5 prayer points on the circle
    final paintPointOff = Paint()
      ..color = AppColors.primary.withValues(alpha:0.15)
      ..style = PaintingStyle.fill;

    const prayerTimes = [
      0.1, // Fajr
      0.3, // Dhuhr
      0.45, // Asr
      0.65, // Maghrib
      0.85, // Isha
    ];

    for (var position in prayerTimes) {
      final angle = (position * 2 * pi) - (pi / 2);
      final offset = Offset(
        center.dx + (radius - 10) * cos(angle),
        center.dy + (radius - 10) * sin(angle),
      );

      canvas.drawCircle(offset, 3, paintPointOff);
    }

    // Draw the progress indicator for current time
    final progressPaint = Paint()
      ..shader = AppColors.bentoGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      -pi / 2,
      1.3 * pi, // Mock progress to current prayer
      false,
      progressPaint,
    );

    // Current time indicator dot (Maghrib position)
    const dotAngle = (0.65 * 2 * pi) - (pi / 2);
    final dotOffset = Offset(
      center.dx + (radius - 10) * cos(dotAngle),
      center.dy + (radius - 10) * sin(dotAngle),
    );

    // Dynamic glow for the active prayer
    final indicatorPaint = Paint()..color = AppColors.secondary;
    canvas.drawCircle(dotOffset, 6, indicatorPaint);

    final glowPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha:0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * pulseValue);
    canvas.drawCircle(dotOffset, 14 * pulseValue, glowPaint);
  }

  @override
  bool shouldRepaint(covariant TimelinePainter oldDelegate) =>
      oldDelegate.pulseValue != pulseValue;
}
