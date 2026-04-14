import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';

class CustomFloatingBottomNav extends StatelessWidget {
  const CustomFloatingBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceBright.withValues(alpha:0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GlassContainer(
        blur: 20,
        color: Colors.transparent,
        border: Border.all(color: Colors.transparent),
        borderRadius: AppShapes.fullRadius,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.auto_awesome_motion, 'Home', true),
            _buildNavItem(Icons.explore_outlined, 'Qibla', false),
            _buildNavItem(Icons.ads_click, 'Tasbih', false),
            _buildNavItem(Icons.group_outlined, 'Community', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppShapes.fullRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha:0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: AppTypography.label.copyWith(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary.withValues(alpha:0.5), size: 24),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: AppTypography.label.copyWith(
              color: AppColors.primary.withValues(alpha:0.5),
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
