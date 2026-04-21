import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/shorts_provider.dart';
import '../widgets/short_video_player.dart';
import '../widgets/shorts_overlay.dart';
import '../widgets/shorts_interaction_bar.dart';
import '../../../../core/design_tokens.dart';

class ShortsScreen extends ConsumerStatefulWidget {
  const ShortsScreen({super.key});

  @override
  ConsumerState<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends ConsumerState<ShortsScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shortsAsync = ref.watch(shortsFeedProvider);
    final currentIndex = ref.watch(currentShortIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.emeraldBg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: shortsAsync.when(
        data: (shorts) => PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: shorts.length,
          onPageChanged: (index) {
            ref.read(currentShortIndexProvider.notifier).state = index;
          },
          itemBuilder: (context, index) {
            final video = shorts[index];
            final isVisible = index == currentIndex;

            return Stack(
              fit: StackFit.expand,
              children: [
                // Video Player
                ShortVideoPlayer(
                  videoUrl: video.videoUrl,
                  thumbnailUrl: video.thumbnailUrl,
                  isVisible: isVisible,
                ),

                // Content Overlay (Bottom)
                ShortsOverlay(
                  authorName: video.authorName,
                  authorAvatarUrl: video.authorAvatarUrl,
                  caption: video.caption,
                  reference: video.reference,
                  category: video.category,
                  tags: video.tags,
                ),

                // Interaction Bar (Right)
                Positioned(
                  right: 16,
                  bottom: 150,
                  child: ShortsInteractionBar(
                    likesCount: video.likesCount,
                    commentsCount: video.commentsCount,
                    bookmarksCount: video.bookmarksCount,
                    isLiked: video.isLiked,
                    isBookmarked: video.isBookmarked,
                  ),
                ),
              ],
            );
          },
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.emeraldPrimary),
        ),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.emeraldPrimary),
        onPressed: () => context.pushNamed('shorts_discovery'),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabButton(
            label: 'For You',
            isActive: true, // Mock selection
            onTap: () {},
          ),
          const SizedBox(width: 24),
          _TabButton(
            label: 'Following',
            isActive: false,
            onTap: () {},
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.emeraldPrimary),
          onPressed: () => context.pushNamed('shorts_discovery'),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.title.copyWith(
              color: isActive ? AppColors.emeraldSecondary : Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          if (isActive) ...[
            const SizedBox(height: 4),
            Container(
              width: 20,
              height: 2,
              color: AppColors.emeraldSecondary,
            ),
          ],
        ],
      ),
    );
  }
}
