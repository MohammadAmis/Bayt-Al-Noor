import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';

class PrayerStatusCard extends StatelessWidget {
  final String nextPrayer;
  final String countdown;

  const PrayerStatusCard({
    super.key,
    required this.nextPrayer,
    required this.countdown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: AppShapes.lgRadius,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NEXT PRAYER',
                style: AppTypography.label.copyWith(
                  color: AppColors.primary.withValues(alpha:0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nextPrayer,
                style: AppTypography.display.copyWith(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha:0.08),
              borderRadius: AppShapes.defaultRadius,
            ),
            child: Column(
              children: [
                Text(
                  'STARTS IN',
                  style: AppTypography.label.copyWith(
                    color: AppColors.primary.withValues(alpha:0.6),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  countdown,
                  style: AppTypography.title.copyWith(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
