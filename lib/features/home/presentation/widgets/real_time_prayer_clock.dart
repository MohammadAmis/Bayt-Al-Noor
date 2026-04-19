import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import '../../../../core/design_tokens.dart';

/// Data representing common markers (icons or labels) for the outer ring.
class _RingMarker {
  final String? label;
  final IconData? icon;
  double angle;
  final Color color;
  final bool isIcon;

  _RingMarker(
      {this.label,
      this.icon,
      required this.angle,
      required this.color,
      required this.isIcon});
}

class _DrawableSegment {
  final Prayer prayer;
  final Color color;
  final double startAngle;
  final double sweepAngle;
  final bool isActive;
  final double durationMinutes;
  final DateTime absStartTime;

  _DrawableSegment({
    required this.prayer,
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
    required this.isActive,
    required this.durationMinutes,
    required this.absStartTime,
  });
}

class RealTimePrayerClock extends StatefulWidget {
  final PrayerTimes prayerTimes;

  const RealTimePrayerClock({
    super.key,
    required this.prayerTimes,
  });

  @override
  State<RealTimePrayerClock> createState() => _RealTimePrayerClockState();
}

class _RealTimePrayerClockState extends State<RealTimePrayerClock> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  late bool _showPM;
  List<_DrawableSegment> _visibleSegments = [];
  List<_RingMarker> _ringMarkers = [];

  static const Color themeBackground = Color(0xFFF1F5F2);
  static const Color themeNeedle = Color(0xFF003D32);
  static const Color themeBorder = Color(0xFFD1D5D1);

  @override
  void initState() {
    super.initState();
    _showPM = _now.hour >= 12;
    _calculateDisplayData();
    _startOptimizedTimer();
  }

  @override
  void didUpdateWidget(RealTimePrayerClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prayerTimes != widget.prayerTimes) {
      _calculateDisplayData();
    }
  }

  void _startOptimizedTimer() {
    final nextMinute =
        DateTime(_now.year, _now.month, _now.day, _now.hour, _now.minute + 1);
    final durationToNextMinute = nextMinute.difference(DateTime.now());

    Future.delayed(durationToNextMinute, () {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
        _calculateDisplayData();
      });
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        if (mounted) {
          setState(() {
            _now = DateTime.now();
            _calculateDisplayData();
          });
        }
      });
    });
  }

  void _calculateDisplayData() {
    _calculateSegments();
    _calculateRingMarkers();
  }

  void _calculateSegments() {
    final currentPrayer = widget.prayerTimes.currentPrayer();
    final winStart = _showPM ? 720.0 : 0.0;
    final winEnd = _showPM ? 1440.0 : 720.0;

    final baseData = [
      {
        'p': Prayer.fajr,
        's': widget.prayerTimes.fajr,
        'e': widget.prayerTimes.sunrise,
        'c': AppColors.fajr,
      },
      // 🌅 Sunrise restriction (20 min)
      {
        'p': Prayer.sunrise,
        's': widget.prayerTimes.sunrise,
        'e': widget.prayerTimes.sunrise.add(const Duration(minutes: 20)),
        'c': Colors.blueGrey.withValues(alpha: 0.6),
        'l': 'Sunrise',
      },
      // ✅ Unified Ishraq and Chast
      {
        'p': Prayer.sunrise,
        's': widget.prayerTimes.sunrise.add(const Duration(minutes: 20)),
        'e': widget.prayerTimes.dhuhr.subtract(const Duration(minutes: 15)),
        'c': const Color(0xFFFFA000), // Ishraq/Chast Gold
        'l': 'Ishraq and Chast',
        'isDuha': true,
      },
      // ⚠️ Zawal Window (15 min)
      {
        'p': Prayer.sunrise,
        's': widget.prayerTimes.dhuhr.subtract(const Duration(minutes: 15)),
        'e': widget.prayerTimes.dhuhr,
        'c': const Color(0xFFD32F2F).withValues(alpha: 0.4),
        'l': 'Zawal',
      },
      {
        'p': Prayer.dhuhr,
        's': widget.prayerTimes.dhuhr,
        'e': widget.prayerTimes.asr,
        'c': AppColors.dhuhr,
      },
      {
        'p': Prayer.asr,
        's': widget.prayerTimes.asr,
        'e': widget.prayerTimes.maghrib,
        'c': AppColors.asr,
      },
      {
        'p': Prayer.maghrib,
        's': widget.prayerTimes.maghrib,
        'e': widget.prayerTimes.isha,
        'c': AppColors.maghrib,
      },
      {
        'p': Prayer.isha,
        's': widget.prayerTimes.isha,
        'e': widget.prayerTimes.fajr.add(const Duration(days: 1)),
        'c': AppColors.isha,
      },
    ];

    List<_DrawableSegment> list = [];
    for (var seg in baseData) {
      DateTime s = seg['s'] as DateTime;
      DateTime e = seg['e'] as DateTime;
      double sMin = s.hour * 60.0 + s.minute;
      double duration = e.difference(s).inMinutes.toDouble();
      double eMin = sMin + duration;

      _clipAndAddArc(sMin, eMin, winStart, winEnd, seg, list, currentPrayer, s);
      _clipAndAddArc(sMin - 1440, eMin - 1440, winStart, winEnd, seg, list,
          currentPrayer, s);
      _clipAndAddArc(sMin + 1440, eMin + 1440, winStart, winEnd, seg, list,
          currentPrayer, s);
    }
    _visibleSegments = list;
  }

  void _clipAndAddArc(double s, double e, double wS, double wE, Map config,
      List<_DrawableSegment> list, Prayer current, DateTime absStart) {
    double vS = max(s, wS);
    double vE = min(e, wE);
    if (vS < vE) {
      double startAngle = ((vS % 720) / 720.0) * 2 * pi - pi / 2;
      double endAngle = ((vE % 720) / 720.0) * 2 * pi - pi / 2;
      double sweepAngle = endAngle - startAngle;
      if (sweepAngle <= 0) sweepAngle += 2 * pi;

      list.add(_DrawableSegment(
        prayer: config['p'] as Prayer,
        color: config['c'] as Color,
        startAngle: startAngle,
        sweepAngle: sweepAngle,
        isActive: current == config['p'],
        durationMinutes: vE - vS,
        absStartTime: absStart,
      ));
    }
  }

  void _calculateRingMarkers() {
    final winStart = _showPM ? 720.0 : 0.0;
    final winEnd = _showPM ? 1440.0 : 720.0;
    List<_RingMarker> markers = [];

    // 1. Icons at absolute start times
    final moments = [
      {'t': widget.prayerTimes.fajr, 'i': Icons.campaign, 'l': 'Fajr'},
      {'t': widget.prayerTimes.sunrise, 'i': Icons.wb_sunny, 'l': 'Sunrise'},
      {'t': widget.prayerTimes.dhuhr, 'i': Icons.campaign, 'l': 'Dhuhr'},
      {'t': widget.prayerTimes.asr, 'i': Icons.campaign, 'l': 'Asr'},
      {'t': widget.prayerTimes.maghrib, 'i': Icons.campaign, 'l': 'Maghrib'},
      {
        't': widget.prayerTimes.maghrib.add(const Duration(minutes: 5)),
        'i': Icons.wb_twilight,
        'l': null
      },
      {'t': widget.prayerTimes.isha, 'i': Icons.campaign, 'l': 'Isha'},
    ];

    for (var m in moments) {
      final t = m['t'] as DateTime;
      final tMin = t.hour * 60.0 + t.minute;
      if (tMin >= winStart && tMin < winEnd) {
        final angle = ((tMin % 720) / 720.0) * 2 * pi - (pi / 2);
        markers.add(_RingMarker(
          icon: m['i'] as IconData,
          angle: angle,
          color: (m['i'] == Icons.campaign)
              ? themeNeedle
              : const Color(0xFFC99B35),
          isIcon: true,
        ));
      }
    }

    // 2. Labels at angular CENTER of arcs
    for (var seg in _visibleSegments) {
      final absMin = seg.absStartTime.hour * 60.0 + seg.absStartTime.minute;
      if (absMin >= winStart && absMin < winEnd) {
        final midAngle = seg.startAngle + (seg.sweepAngle / 2);
        
        // Handle custom labels (like Zawal or Ishraq and Chast)
        String label = _getLabelForPrayer(seg.prayer);
        if (seg.prayer == Prayer.sunrise) {
           // Find if it has a custom label in baseData (not stored directly in DrawableSegment currently)
           // Instead of complex lookup, let's use the segment width/position hint
           if (seg.sweepAngle > 0.5) {label = 'Ishraq /\nChasht';}
           else if (seg.startAngle < 0) {label = 'Zawal';} // Very simplified logic
        }

        markers.add(_RingMarker(
          label: label,
          angle: midAngle,
          color: seg.color.withValues(alpha: 0.9),
          isIcon: false,
        ));
      }
    }

    // 3. Add Preferred markers for Duha
    // Wait, the Python used Zawal for delta. In our app Zawal is dhuhr-15.
    final morningDuration = widget.prayerTimes.dhuhr.subtract(const Duration(minutes: 15)).difference(widget.prayerTimes.sunrise).inMinutes;
    
    final preferredTime = widget.prayerTimes.sunrise.add(Duration(minutes: morningDuration ~/ 4));
    final veryPreferredTime = widget.prayerTimes.sunrise.add(Duration(minutes: morningDuration ~/ 2));

    for (var t in [preferredTime, veryPreferredTime]) {
      final tMin = t.hour * 60.0 + t.minute;
      if (tMin >= winStart && tMin < winEnd) {
        markers.add(_RingMarker(
          icon: Icons.auto_awesome_rounded,
          angle: ((tMin % 720) / 720.0) * 2 * pi - (pi / 2),
          color: Colors.white.withValues(alpha: 0.8),
          isIcon: true,
        ));
      }
    }

    _resolveCollisions(markers);
    _ringMarkers = markers;
  }

  String _getLabelForPrayer(Prayer p) {
    switch (p) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return '';
    }
  }

  void _resolveCollisions(List<_RingMarker> markers) {
    if (markers.length < 2) return;
    markers.sort((a, b) => a.angle.compareTo(b.angle));
    const double minAngleDist = 0.22;
    for (int i = 0; i < markers.length - 1; i++) {
      if ((markers[i + 1].angle - markers[i].angle).abs() < minAngleDist) {
        markers[i].angle -= minAngleDist / 2;
        markers[i + 1].angle += minAngleDist / 2;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeBackground,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 80,
                        spreadRadius: 10),
                  ]),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _CelestialCompassPainter(
                        time: _now,
                        showPM: _showPM,
                        segments: _visibleSegments,
                        markers: _ringMarkers,
                        needleColor: themeNeedle,
                        backgroundColor: themeBackground,
                        borderColor: themeBorder,
                        sunrise: widget.prayerTimes.sunrise,
                        sunset: widget.prayerTimes.maghrib,
                      ),
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                        color: themeNeedle,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3.0)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Serenity Switch (Now placed BELOW clock)
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showPM = !_showPM;
                _calculateDisplayData();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 170,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.cream.withValues(alpha: 0.4),
                borderRadius: AppShapes.fullRadius,
                border: Border.all(
                  color: AppColors.mutedGold.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Magnetic Indicator
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    alignment:
                        _showPM ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 82,
                      height: 44,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppShapes.fullRadius,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mutedGold.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Labels
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wb_sunny_rounded,
                              size: 14,
                              color: !_showPM
                                  ? AppColors.mutedGold
                                  : AppColors.sage.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'AM',
                              style: AppTypography.label.copyWith(
                                color: !_showPM
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mode_night_rounded,
                              size: 14,
                              color: _showPM
                                  ? AppColors.mutedGold
                                  : AppColors.sage.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'PM',
                              style: AppTypography.label.copyWith(
                                color: _showPM
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CelestialCompassPainter extends CustomPainter {
  final DateTime time;
  final bool showPM;
  final List<_DrawableSegment> segments;
  final List<_RingMarker> markers;
  final Color needleColor;
  final Color backgroundColor;
  final Color borderColor;
  final DateTime sunrise;
  final DateTime sunset;
 
  _CelestialCompassPainter({
    required this.time,
    required this.showPM,
    required this.segments,
    required this.markers,
    required this.needleColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.sunrise,
    required this.sunset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    _drawIconRingBase(canvas, center, radius);
    _drawCelestialBackgrounds(canvas, center, radius);
    _drawSegments(canvas, center, radius);
    _drawLabels(canvas, center, radius);
    _drawRingMarkers(canvas, center, radius);

    final hourAngle = (time.hour % 12 + time.minute / 60) * 30 * pi / 180;
    _drawNeedle(canvas, center, radius * 0.42, hourAngle, 6.0, needleColor);

    final minuteAngle = (time.minute) * 6 * pi / 180;
    _drawNeedle(canvas, center, radius * 0.58, minuteAngle, 3.2,
        needleColor.withValues(alpha: 0.6));
  }

  void _drawIconRingBase(Canvas canvas, Offset center, double radius) {
    final outerRingStart = radius * 0.68;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, outerRingStart, shadowPaint);
    final ringBasePaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius - outerRingStart;
    canvas.drawCircle(center, (outerRingStart + radius) / 2, ringBasePaint);
    canvas.drawCircle(
        center,
        outerRingStart,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    canvas.drawCircle(
        center,
        radius - 1,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  void _drawCelestialBackgrounds(Canvas canvas, Offset center, double radius) {
    final outerRingStart = radius * 0.68;
    final strokeWidth = radius - outerRingStart;
    final rect = Rect.fromCircle(
        center: center, radius: (outerRingStart + radius) / 2);

    final winStart = showPM ? 720.0 : 0.0;
    final winEnd = showPM ? 1440.0 : 720.0;

    // Day: Sunrise to Sunset
    final sunriseMin = sunrise.hour * 60.0 + sunrise.minute;
    final sunsetMin = sunset.hour * 60.0 + sunset.minute;

    final dayPaint = Paint()
      ..color = const Color(0xFFFFF9C4).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final nightPaint = Paint()
      ..color = const Color(0xFFC5CAE9).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Drawing logic: 
    // We treat the whole ring as night first, then overlay the day part.
    canvas.drawCircle(center, (outerRingStart + radius) / 2, nightPaint);

    // Overlay Day
    _drawClippedArc(canvas, rect, sunriseMin, sunsetMin, winStart, winEnd, dayPaint);
    
    // Also check for wrapping (sunset > sunrise is normal, but if sunset < sunrise it spans midnight)
    if (sunsetMin < sunriseMin) {
       // This shouldn't normally happen in a standard day but good for robust logic
       _drawClippedArc(canvas, rect, 0, sunsetMin, winStart, winEnd, dayPaint);
       _drawClippedArc(canvas, rect, sunriseMin, 1440, winStart, winEnd, dayPaint);
    }
  }

  void _drawClippedArc(Canvas canvas, Rect rect, double s, double e, double wS, double wE, Paint paint) {
    double vS = max(s, wS);
    double vE = min(e, wE);
    if (vS < vE) {
      double startAngle = ((vS % 720) / 720.0) * 2 * pi - pi / 2;
      double endAngle = ((vE % 720) / 720.0) * 2 * pi - pi / 2;
      double sweepAngle = endAngle - startAngle;
      if (sweepAngle <= 0) sweepAngle += 2 * pi;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    }
  }

  void _drawSegments(Canvas canvas, Offset center, double radius) {
    final innerRadius = radius * 0.02;
    final outerRadius = radius * 0.65;
    final rect = Rect.fromCircle(
        center: center, radius: (innerRadius + outerRadius) / 2);
    final width = outerRadius - innerRadius;
    final innerShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, outerRadius, innerShadow);
    for (var seg in segments) {
      final ringPaint = Paint()
        ..color = seg.color.withValues(alpha: seg.isActive ? 1.0 : 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width;
      canvas.drawArc(rect, seg.startAngle, seg.sweepAngle, false, ringPaint);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    final textStyle = TextStyle(
        color: needleColor.withValues(alpha: 0.95),
        fontSize: 18,
        fontWeight: FontWeight.w900);
    final numberRadius = radius * 0.55;
    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final x = center.dx + numberRadius * cos(angle);
      final y = center.dy + numberRadius * sin(angle);
      final tp = TextPainter(
          text: TextSpan(text: '$i', style: textStyle),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  void _drawRingMarkers(Canvas canvas, Offset center, double radius) {
    final ringRadius = radius * 0.85;
    for (var m in markers) {
      final x = center.dx + ringRadius * cos(m.angle);
      final y = center.dy + ringRadius * sin(m.angle);

      if (m.isIcon) {
        final iconPainter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: String.fromCharCode(m.icon!.codePoint),
            style: TextStyle(
                fontSize: 22,
                fontFamily: m.icon!.fontFamily,
                package: m.icon!.fontPackage,
                color: m.color,
                shadows: [
                  Shadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]),
          ),
        )..layout();
        iconPainter.paint(canvas,
            Offset(x - iconPainter.width / 2, y - iconPainter.height / 2));
      } else {
        final labelPainter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: m.label!.toUpperCase(),
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: m.color,
                letterSpacing: 0.8),
          ),
        )..layout();
        labelPainter.paint(canvas,
            Offset(x - labelPainter.width / 2, y - labelPainter.height / 2));
      }
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double length, double angle,
      double width, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        center,
        Offset(
            center.dx + length * sin(angle), center.dy - length * cos(angle)),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
