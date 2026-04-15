import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/design_tokens.dart';

/// Animated needle pointing to Qibla direction
/// 
/// The needle stays fixed relative to the screen while the compass ring rotates.
/// This creates the illusion that the needle always points to Mecca.
class CompassNeedle extends StatelessWidget {
  final double qiblaDegrees; // 0-360 degrees from true north
  final bool isAligned; // Visual enhancement when aligned

  const CompassNeedle({
    super.key,
    required this.qiblaDegrees,
    this.isAligned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _toRadians(qiblaDegrees),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Main needle body
          _buildNeedleBody(),
          
          // Kaaba icon at needle tip
          Positioned(
            top: -50,
            child: _buildKaabaIcon(),
          ),
          
          // Alignment glow effect (when facing Qibla)
          if (isAligned) _buildAlignmentGlow(),
        ],
      ),
    );
  }

  /// Needle shaft + arrowhead
  Widget _buildNeedleBody() {
    return SizedBox(
      width: 24,
      height: 220,
      child: Column(
        children: [
          // Arrowhead (pointing to Qibla)
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isAligned ? AppColors.celestialGold : AppColors.celestialGoldLight,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: (isAligned ? AppColors.celestialGlow : Colors.transparent),
                  blurRadius: isAligned ? 15 : 0,
                  spreadRadius: isAligned ? 2 : 0,
                ),
              ],
            ),
            transform: Matrix4.rotationZ(math.pi / 4),
          ),
          
          // Gradient shaft fading to transparent
          Expanded(
            child: Container(
              width: 3,
              margin: const EdgeInsets.only(top: 10),
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
          
          // Counterweight (bottom of needle)
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.celestialSilver.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  /// Kaaba/Mosque icon at needle tip
  Widget _buildKaabaIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.celestialBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: isAligned ? AppColors.celestialGold : AppColors.celestialGoldLight,
          width: isAligned ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isAligned ? AppColors.celestialGlow : Colors.transparent,
            blurRadius: isAligned ? 20 : 0,
            spreadRadius: isAligned ? 3 : 0,
          ),
        ],
      ),
      child: Icon(
        Icons.mosque,
        color: isAligned ? AppColors.celestialGold : AppColors.celestialGoldLight,
        size: 24,
      ),
    );
  }

  /// Subtle pulse glow when aligned with Qibla
  Widget _buildAlignmentGlow() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.celestialGlow.withValues(alpha: 0.6),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }

  // Helper: Degrees to radians
  double _toRadians(double degrees) => degrees * math.pi / 180;
}