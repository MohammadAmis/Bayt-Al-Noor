import 'package:flutter/material.dart';
import '../../../../../core/design_tokens.dart';

class DropdownSettingTile<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? icon;
  final String? hintText;
  
  const DropdownSettingTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: AppColors.primary) : null,
      title: Text(title, style: AppTypography.title.copyWith(color: AppColors.onSurface)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant))
          : null,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: AppShapes.defaultRadius,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            hint: hintText != null
                ? Text(hintText!, style: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant))
                : null,
            items: items,
            onChanged: onChanged,
            style: AppTypography.body.copyWith(color: AppColors.onSurface),
            dropdownColor: AppColors.surfaceContainer,
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.onSurfaceVariant),
          ),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}