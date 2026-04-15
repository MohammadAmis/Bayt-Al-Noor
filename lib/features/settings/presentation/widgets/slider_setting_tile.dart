import 'package:flutter/material.dart';
import '../../../../../core/design_tokens.dart';

class SliderSettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final ValueChanged<double> onChanged;
  final IconData? icon;
  
  const SliderSettingTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.label,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: icon != null ? Icon(icon, color: AppColors.primary) : null,
          title: Text(title, style: AppTypography.title.copyWith(color: AppColors.onSurface)),
          subtitle: subtitle != null
              ? Text(subtitle!, style: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant))
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.outlineVariant,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.2),
                    valueIndicatorColor: AppColors.primaryContainer,
                    valueIndicatorTextStyle: AppTypography.label.copyWith(color: AppColors.onPrimary),
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: divisions,
                    label: label,
                    onChanged: onChanged,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppShapes.defaultRadius,
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Text(
                  label ?? value.round().toString(),
                  style: AppTypography.label.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}