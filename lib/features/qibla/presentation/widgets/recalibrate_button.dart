import 'package:flutter/material.dart';
import '../../../../../core/design_tokens.dart';

/// Button to trigger manual Qibla recalculation
class RecalibrateButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const RecalibrateButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isLoading 
              ? AppColors.surfaceContainerHighest.withValues(alpha: 0.5)
              : AppColors.surfaceContainerHighest,
          borderRadius: AppShapes.lgRadius,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            else
              const Icon(Icons.sync, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              isLoading ? 'CALIBRATING...' : 'RECALIBRATE COMPASS',
              style: AppTypography.label.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isLoading 
                    ? AppColors.outlineVariant 
                    : AppColors.primary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}