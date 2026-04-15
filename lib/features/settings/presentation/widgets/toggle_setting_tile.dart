import 'package:flutter/material.dart';
import '../../../../../core/design_tokens.dart';

class ToggleSettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  final bool enabled;
  
  const ToggleSettingTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      leading: icon != null
          ? Icon(icon, color: enabled ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha:0.5))
          : null,
      title: Text(
        title,
        style: AppTypography.title.copyWith(
          color: enabled ? AppColors.onSurface : AppColors.onSurfaceVariant.withValues(alpha:0.5),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}