import 'package:flutter/material.dart';
import '../../../../../core/design_tokens.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? footer;
  
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.label.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Card(
          color: AppColors.surfaceContainerLow,
          shape: RoundedRectangleBorder(borderRadius: AppShapes.lgRadius),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ...children.map((child) => Column(
                children: [
                  child,
                  // Divider between items (except last)
                  if (children.indexOf(child) < children.length - 1)
                    const Divider(height: 1, color: AppColors.outlineVariant, indent: 16, endIndent: 16),
                ],
              )),
              if (footer != null) ...[
                const Divider(height: 1, color: AppColors.outlineVariant, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: footer!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}