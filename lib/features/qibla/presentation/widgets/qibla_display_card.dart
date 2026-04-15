import 'package:flutter/material.dart';
import '../../../../../core/design_tokens.dart';
import '../../domain/entities/qibla_direction.dart';

/// Info card showing calculated Qibla direction details
class QiblaDisplayCard extends StatelessWidget {
  final QiblaDirection direction;

  const QiblaDisplayCard({super.key, required this.direction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppShapes.xlRadius,
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: AppColors.primaryFixed,
            ),
          ),
          const SizedBox(width: 20),
          
          // Direction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QIBLA DIRECTION',
                  style: AppTypography.label.copyWith(
                    color: AppColors.outline,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
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
                const SizedBox(height: 8),
                Text(
                  'Calculated at ${_formatTime(direction.calculatedAt)}',
                  style: AppTypography.body.copyWith(
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