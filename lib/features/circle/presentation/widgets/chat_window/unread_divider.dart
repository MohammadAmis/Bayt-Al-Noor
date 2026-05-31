import 'package:flutter/material.dart';
import '../../../../../core/design_tokens.dart';

/// Horizontal divider shown between read and unread messages.
class UnreadDivider extends StatelessWidget {
  final int unreadCount;
  const UnreadDivider({super.key, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: AppColors.primary.withValues(alpha: 0.35),
              thickness: 1,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppShapes.fullRadius,
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25)),
            ),
            child: Text(
              '$unreadCount unread message${unreadCount == 1 ? '' : 's'}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              color: AppColors.primary.withValues(alpha: 0.35),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
