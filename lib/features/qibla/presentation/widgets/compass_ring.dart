import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/design_tokens.dart';

/// Rotating compass ring with degree markings and cardinal directions
class CompassRing extends StatelessWidget {
  const CompassRing({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer decorative ring
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.celestialGold.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        
        // Degree markings (every 45°)
        ...List.generate(8, (index) {
          final angle = (index * 45).toDouble(); // ✅ Cast to double
          return Transform.rotate(
            angle: _toRadians(angle),
            child: _buildDegreeMarking(angle),
          );
        }),
        
        // Cardinal direction labels (N, E, S, W)
        _buildCardinalLabels(),
      ],
    );
  }

  /// Individual degree marking line
  Widget _buildDegreeMarking(double degrees) { // ✅ Accept double
    final isMajor = degrees % 90 == 0; // N/E/S/W get longer marks
    
    return Positioned(
      top: 10,
      child: Container(
        width: isMajor ? 2 : 1,
        height: isMajor ? 20 : 12,
        decoration: BoxDecoration(
          color: isMajor 
              ? AppColors.celestialGold 
              : AppColors.compassMarking.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  /// N/E/S/W labels positioned around compass
  Widget _buildCardinalLabels() {
    return const Stack(
      children: [
        Positioned(
          top: 30,
          child: _DirectionLabel(text: 'N', isHighlighted: true),
        ),
        Positioned(
          right: 30,
          child: _DirectionLabel(text: 'E'),
        ),
        Positioned(
          bottom: 30,
          child: _DirectionLabel(text: 'S'),
        ),
        Positioned(
          left: 30,
          child: _DirectionLabel(text: 'W'),
        ),
      ],
    );
  }

  // ✅ Helper: Degrees to radians (explicit double)
  double _toRadians(double degrees) => degrees * math.pi / 180;
}

/// Reusable direction label widget
class _DirectionLabel extends StatelessWidget {
  final String text;
  final bool isHighlighted;

  const _DirectionLabel({
    required this.text,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.compassDirection.copyWith(
        color: isHighlighted ? AppColors.celestialGold : AppColors.compassText,
        fontSize: isHighlighted ? 16 : 14,
        fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w700,
      ),
    );
  }
}