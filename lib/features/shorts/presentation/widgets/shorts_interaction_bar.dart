import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';

class ShortsInteractionBar extends StatelessWidget {
  final int likesCount;
  final int commentsCount;
  final int bookmarksCount;
  final bool isLiked;
  final bool isBookmarked;

  const ShortsInteractionBar({
    super.key,
    required this.likesCount,
    required this.commentsCount,
    required this.bookmarksCount,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Interaction Actions

        // Like
        _ActionButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          label: _formatCount(likesCount),
          iconColor: isLiked ? Colors.red : Colors.white,
        ),
        const SizedBox(height: 16),

        // Comment
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          label: _formatCount(commentsCount),
        ),
        const SizedBox(height: 16),

        // Bookmark
        _ActionButton(
          icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          label: _formatCount(bookmarksCount),
          iconColor: isBookmarked ? AppColors.emeraldSecondary : Colors.white,
        ),
        const SizedBox(height: 16),

        // Share
        const _ActionButton(
          icon: Icons.share,
          label: 'Share',
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
