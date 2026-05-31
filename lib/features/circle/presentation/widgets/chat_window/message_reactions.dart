import 'package:flutter/material.dart';
import '../../../../../core/design_tokens.dart';

/// Emoji reaction bar — shown below a message on long-press.
/// Displays a row of quick-pick emojis and the running reaction counts.
class MessageReactions extends StatelessWidget {
  final Map<String, int> reactions; // e.g. {'❤️': 2, '👍': 5}
  final String? myReaction;         // which emoji the current user picked
  final ValueChanged<String> onReact;

  static const _quickEmojis = ['❤️', '👍', '😂', '😮', '🤲', '🥹'];

  const MessageReactions({
    super.key,
    required this.reactions,
    this.myReaction,
    required this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: reactions.entries.map((entry) {
        final isOwn = entry.key == myReaction;
        return GestureDetector(
          onTap: () => onReact(entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOwn
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.surfaceContainerHigh,
              borderRadius: AppShapes.fullRadius,
              border: Border.all(
                color: isOwn
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(entry.key, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 3),
                Text(
                  '${entry.value}',
                  style: AppTypography.labelSmall.copyWith(
                    color: isOwn ? AppColors.primary : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Floating emoji picker shown above the message on long-press.
class EmojiPickerBar extends StatelessWidget {
  final VoidCallback onReply;
  final ValueChanged<String> onReact;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;

  static const _emojis = ['❤️', '👍', '😂', '😮', '🤲', '🥹'];

  const EmojiPickerBar({
    super.key,
    required this.onReply,
    required this.onReact,
    this.onDelete,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick emoji row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _emojis.map((emoji) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  onReact(emoji);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 4),
          // Action row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _actionButton(
                  icon: Icons.reply_rounded,
                  label: 'Reply',
                  onTap: () {
                    Navigator.of(context).pop();
                    onReply();
                  }),
              if (onCopy != null)
                _actionButton(
                    icon: Icons.copy_rounded,
                    label: 'Copy',
                    onTap: () {
                      Navigator.of(context).pop();
                      onCopy!();
                    }),
              if (onDelete != null)
                _actionButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    color: AppColors.error,
                    onTap: () {
                      Navigator.of(context).pop();
                      onDelete!();
                    }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? AppColors.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: c),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSmall
                  .copyWith(color: c, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
