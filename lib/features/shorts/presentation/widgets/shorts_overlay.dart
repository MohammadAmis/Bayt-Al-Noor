import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_tokens.dart';

class ShortsOverlay extends StatelessWidget {
  final String authorName;
  final String authorAvatarUrl;
  final String caption;
  final String reference;
  final String category;
  final List<String> tags;

  const ShortsOverlay({
    super.key,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.caption,
    required this.reference,
    required this.category,
    this.tags = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.shortsOverlayGradient,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.emeraldSecondary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              category.toUpperCase(),
              style: AppTypography.label.copyWith(
                color: AppColors.emeraldOnSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Caption
          Text(
            caption,
            style: AppTypography.display.copyWith(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),

          // Reference
          if (reference.isNotEmpty)
            Text(
              '($reference)',
              style: AppTypography.body.copyWith(
                color: AppColors.emeraldPrimary.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 12),

          // Tags
          Wrap(
            spacing: 8,
            children: tags.map((tag) => Text(
              tag,
              style: AppTypography.label.copyWith(
                color: AppColors.emeraldSecondary.withValues(alpha: 0.9),
                fontWeight: FontWeight.bold,
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          // 👤 Author Profile (YouTube Style)
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pushNamed('shorts_profile'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                    image: DecorationImage(
                      image: NetworkImage(authorAvatarUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '@$authorName',
                style: AppTypography.label.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Follow',
                  style: AppTypography.label.copyWith(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 60), // Space for bottom nav
        ],
      ),
    );
  }
}

class _ReactionButton extends StatefulWidget {
  final String label;

  const _ReactionButton({required this.label});

  @override
  State<_ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<_ReactionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: AppAnimations.fast,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: AppColors.emeraldPrimary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            widget.label,
            style: AppTypography.label.copyWith(
              color: AppColors.emeraldPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
