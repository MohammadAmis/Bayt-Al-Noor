import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';

class SpiritualQuoteCard extends StatelessWidget {
  const SpiritualQuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(24),
      color: AppColors.secondaryFixed.withValues(alpha:0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_toggle_off, color: AppColors.secondary, size: 20),
              const SizedBox(width: 12),
              Text(
                'THE FLOW OF TIME',
                style: AppTypography.label.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"Verily, prayer is enjoined on believers at fixed times."',
            style: AppTypography.body.copyWith(
              fontSize: 16,
              color: AppColors.primary,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '— Surah An-Nisa [4:103]',
            style: AppTypography.label.copyWith(
              fontSize: 10,
              color: AppColors.onSurfaceVariant.withValues(alpha:0.6),
            ),
          ),
        ],
      ),
    );
  }
}
