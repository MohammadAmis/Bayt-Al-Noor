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
      _checkAlignment();
    }
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
    final ringRotation = widget.deviceHeading ?? 0;

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
                    turns: ringRotation / 360,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    child: const _CompassRing(),
                  ),

                  // 🎯 FIXED Qibla Needle (always points up/12 o'clock)
                  _QiblaNeedle(
                    qiblaDegrees: widget.qiblaDirection.degrees,
                    isAligned: _isAligned,
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

        const SizedBox(height: 30),

        // 📍 Location Info Card
        _LocationInfoCard(direction: widget.qiblaDirection),
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
  final double qiblaDegrees;
  final bool isAligned;

  const _QiblaNeedle({
    required this.qiblaDegrees,
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isAligned ? AppColors.celestialGold : AppColors.celestialGoldLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isAligned ? AppColors.celestialGlow : Colors.transparent),
                  blurRadius: isAligned ? 20 : 10,
                  spreadRadius: isAligned ? 3 : 0,
                ),
              ],
            ),
            child: Icon(
              Icons.mosque,
              color: isAligned ? Colors.white : AppColors.compassFace,
              size: 24,
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
                borderRadius: BorderRadius.circular(2),
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
// 📍 Location Info Card
// ============================================================================

class _LocationInfoCard extends StatelessWidget {
  final QiblaDirection direction;

  const _LocationInfoCard({required this.direction});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppShapes.xlRadius,
        border: Border.all(
          color: AppColors.celestialGold.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: AppColors.primaryFixed,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QIBLA DIRECTION',
                  style: AppTypography.label.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  direction.formatted,
                  style: AppTypography.headline.copyWith(
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Calculated at ${_formatTime(direction.calculatedAt)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.outlineVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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