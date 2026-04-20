import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/design_tokens.dart';
import '../../domain/entities/qibla_direction.dart';

/// Production-ready Qibla compass with Islamic aesthetics
/// 
/// How it works:
/// - Compass RING rotates based on device heading (so N always points north)
/// - Qibla NEEDLE stays fixed pointing up (12 o'clock)
/// - When device faces Qibla, the needle aligns with the ring's N marker
class CompassDial extends StatefulWidget {
  final QiblaDirection qiblaDirection;
  final double? deviceHeading; // Device heading from compass sensor (0-360)
  final double size;
  final VoidCallback? onAligned;

  const CompassDial({
    super.key,
    required this.qiblaDirection,
    this.deviceHeading,
    this.size = 300,
    this.onAligned,
  });

  @override
  State<CompassDial> createState() => _CompassDialState();
}

class _CompassDialState extends State<CompassDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isAligned = false;
  
  // 🔄 Add state to track continuous rotation
  double _lastRingHeading = 0;
  double _totalRingTurns = 0;
  
  double _lastNeedleHeading = 0;
  double _totalNeedleTurns = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _checkAlignment();
  }

  @override
  void didUpdateWidget(CompassDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.deviceHeading != oldWidget.deviceHeading) {
      _updateRotationState();
      _checkAlignment();
    }
  }

  /// Calculate cumulative turns for smooth continuous rotation
  void _updateRotationState() {
    final double newHeading = widget.deviceHeading ?? 0;
    
    // 1. Ring Rotation (-heading)
    final double ringTarget = -newHeading;
    final double ringDelta = _getShortestDelta(ringTarget, _lastRingHeading);
    _totalRingTurns += ringDelta / 360;
    _lastRingHeading = ringTarget;

    // 2. Needle Rotation (qibla - heading)
    final double needleTarget = widget.qiblaDirection.degrees - newHeading;
    final double needleDelta = _getShortestDelta(needleTarget, _lastNeedleHeading);
    _totalNeedleTurns += needleDelta / 360;
    _lastNeedleHeading = needleTarget;
  }

  /// Helper: Calculate shortest angle difference (-180 to 180)
  double _getShortestDelta(double target, double current) {
    double delta = (target - current) % 360;
    if (delta > 180) delta -= 360;
    if (delta < -180) delta += 360;
    return delta;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Check if user is facing Qibla (within 5° threshold)
  void _checkAlignment() {
    if (widget.deviceHeading == null) return;

    final qiblaDegrees = widget.qiblaDirection.degrees;
    final heading = widget.deviceHeading!;
    
    // Calculate smallest angle difference
    final diff = (qiblaDegrees - heading).abs();
    final normalizedDiff = diff > 180 ? 360 - diff : diff;
    
    final wasAligned = _isAligned;
    _isAligned = normalizedDiff <= 5.0;

    // Trigger haptic feedback on alignment
    if (_isAligned && !wasAligned) {
      HapticFeedback.lightImpact();
      widget.onAligned?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate compass ring rotation
    // The ring rotates so that North marker points to actual North

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Compass Container
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // ✨ Outer glow effect
            Container(
              width: widget.size + 40,
              height: widget.size + 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.celestialGold.withValues(alpha: _isAligned ? 0.6 : 0.3),
                    blurRadius: _isAligned ? 60 : 40,
                    spreadRadius: _isAligned ? 10 : 5,
                  ),
                ],
              ),
            ),

            // 🧭 Main Compass Dial
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.compassFace,
                    AppColors.compassFace.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: AppColors.celestialGold.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: AppColors.celestialGold.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 🔄 ROTATING Compass Ring (degree marks + N/E/S/W)
                  AnimatedRotation(
                    turns: _totalRingTurns,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    child: const _CompassRing(),
                  ),

                  // 🎯 ROTATING Qibla Needle (points to Kaaba relative to heading)
                  AnimatedRotation(
                    turns: _totalNeedleTurns,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    child: _QiblaNeedle(
                      isAligned: _isAligned,
                    ),
                  ),

                  // ⭐ Center Pivot
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.celestialGold,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  // ✨ Alignment pulse animation
                  if (_isAligned)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: widget.size * 0.9,
                          height: widget.size * 0.9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.celestialGold.withValues(
                                alpha: 0.6 * (1 - _pulseController.value * 0.5),
                              ),
                              width: 3,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            // 🏷️ Floating Direction Badge
            Positioned(
              bottom: -20,
              child: _DirectionBadge(
                degrees: widget.qiblaDirection.degrees,
                cardinal: widget.qiblaDirection.cardinal,
                isAligned: _isAligned,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// 🔄 Compass Ring (Degree Markings + Cardinal Directions)
// ============================================================================

class _CompassRing extends StatelessWidget {
  const _CompassRing();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer decorative ring
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.celestialGold.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),

          // Degree markings (every 10°)
          ...List.generate(36, (index) {
            final angle = index * 10;
            final isMajor = angle % 90 == 0; // N/E/S/W
            final isMedium = angle % 45 == 0; // NE/SE/SW/NW
            
            return Transform.rotate(
              angle: angle * math.pi / 180,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: isMajor ? 3 : (isMedium ? 2 : 1),
                  height: isMajor ? 20 : (isMedium ? 14 : 8),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: isMajor 
                        ? AppColors.celestialGold 
                        : (isMedium 
                            ? AppColors.celestialSilver 
                            : AppColors.compassMarking.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            );
          }),

          // Cardinal direction labels (N, E, S, W)
          const Positioned(
            top: 32,
            child: _CardinalLabel(text: 'N', isHighlighted: true),
          ),
          const Positioned(
            right: 32,
            child: _CardinalLabel(text: 'E'),
          ),
          const Positioned(
            bottom: 32,
            child: _CardinalLabel(text: 'S'),
          ),
          const Positioned(
            left: 32,
            child: _CardinalLabel(text: 'W'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 🎯 Qibla Needle (Fixed, Points Up)
// ============================================================================

class _QiblaNeedle extends StatelessWidget {
  final bool isAligned;

  const _QiblaNeedle({
    required this.isAligned,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 220,
      child: Column(
        children: [
          // Kaaba Icon at tip
          SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              Icons.mosque,
              color: isAligned ? Colors.white : AppColors.celestialGold,
              size: 32, // Slightly larger now that background is gone
              shadows: isAligned ? [
                const Shadow(
                  color: AppColors.celestialGold,
                  blurRadius: 20,
                ),
              ] : null,
            ),
          ),
          
          // Needle shaft with gradient
          Expanded(
            child: Container(
              width: 4,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isAligned ? AppColors.celestialGold : AppColors.celestialGoldLight,
                    (isAligned ? AppColors.celestialGold : AppColors.celestialGoldLight)
                        .withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          
          // Counterweight
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.celestialSilver.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 🏷️ Direction Badge
// ============================================================================

class _DirectionBadge extends StatelessWidget {
  final double degrees;
  final String cardinal;
  final bool isAligned;

  const _DirectionBadge({
    required this.degrees,
    required this.cardinal,
    required this.isAligned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      decoration: BoxDecoration(
        color: isAligned 
            ? AppColors.celestialGold 
            : AppColors.compassFace.withValues(alpha: 0.95),
        borderRadius: AppShapes.fullRadius,
        border: Border.all(
          color: isAligned ? Colors.white.withValues(alpha: 0.5) : AppColors.celestialGold.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAligned ? AppColors.celestialGlow : Colors.black).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${degrees.toStringAsFixed(1)}° $cardinal',
            style: AppTypography.headline.copyWith(
              fontSize: 22,
              color: isAligned ? Colors.white : AppColors.celestialGold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isAligned ? '✓ FACING QIBLA' : 'QIBLA DIRECTION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isAligned ? Colors.white.withValues(alpha: 0.9) : AppColors.celestialSilver,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 🧭 Cardinal Direction Label
// ============================================================================

class _CardinalLabel extends StatelessWidget {
  final String text;
  final bool isHighlighted;

  const _CardinalLabel({
    required this.text,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isHighlighted ? 18 : 16,
        fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w700,
        color: isHighlighted ? AppColors.celestialGold : AppColors.compassText,
        letterSpacing: 2,
      ),
    );
  }
}