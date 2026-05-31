import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/providers/services_provider.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../widgets/forum_post_card.dart';
import '../../data/providers/forum_providers.dart';
import '../../domain/entities/post_entity.dart';

class ForumPage extends ConsumerStatefulWidget {
  const ForumPage({super.key});

  @override
  ConsumerState<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends ConsumerState<ForumPage> {
  String _activeTab = 'All';
  String _activeSort = 'All';

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(forumPostsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return postsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (List<PostEntity> allPosts) {
        var posts = List<PostEntity>.from(allPosts);

        // 1. Filter by Tab
        if (_activeTab == 'All') {
          posts = posts.toList();
        } else if (_activeTab == 'Joined') {
          posts = posts.where((p) => p.communityId == 'bayt-al-noor' || p.communityId == 'quran-study').toList();
        } else if (_activeTab == 'Discover') {
          posts = posts.where((p) => p.communityId != 'bayt-al-noor' && p.communityId != 'quran-study').toList();
        }

        // 2. Sort by Category
        switch (_activeSort) {
          case 'Trending':
            posts.sort((a, b) => b.commentCount.compareTo(a.commentCount));
            break;
          case 'New':
            posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            break;
          case 'Top':
            posts.sort((a, b) => b.score.compareTo(a.score));
            break;
          case 'Community':
            posts = posts.where((p) => p.isCommunityPost).toList();
            break;
        }

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppTopBar(
            title: 'Community',
            isMainScreen: true,
            location: 'Community',
            showLogo: true,
            showSearch: true,
            onSearchPressed: () => context.push('/community/search'),
            showProfile: true,
            profileImageUrl: currentUser?.userMetadata?['avatar_url'],
            onProfilePressed: () => context.push(
              '/profile',
              extra: {
                'name': currentUser?.userMetadata?['full_name'] ?? 'Guest',
                'avatarUrl': currentUser?.userMetadata?['avatar_url'] ??
                    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
                'bio': 'Seeking tranquility through reflection and prayer.',
                'userId': currentUser?.id,
              },
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: _buildFAB(),
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Main Tabs (Scrolling)
              SliverToBoxAdapter(
                child: _buildMainTabs(),
              ),

              // 2. Sort Chips (Sticky)
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverFilterDelegate(
                  child: _buildSortChips(),
                  extent: 48,
                ),
              ),

              // 2. Main Community Feed
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: ForumPostCard(
                          post: posts[index],
                          onUpvote: () => ref.read(forumPostsProvider.notifier).toggleUpvote(posts[index].id),
                          onDownvote: () => ref.read(forumPostsProvider.notifier).toggleDownvote(posts[index].id),
                          onBookmark: () => ref.read(forumPostsProvider.notifier).toggleBookmark(posts[index].id),
                          onShare: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Link copied to clipboard')),
                            );
                          },
                        ),
                      );
                    },
                    childCount: posts.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainTabs() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabButton('All'),
          _buildTabButton('Joined'),
          _buildTabButton('Discover'),
        ],
      ),
    );
  }

  Widget _buildSortChips() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildSortChip('All'),
                  _buildSortChip('Trending'),
                  _buildSortChip('New'),
                  _buildSortChip('Top'),
                  _buildSortChip('Community'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label) {
    bool isActive = _activeTab == label;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = label),
      child: Container(
        margin: const EdgeInsets.only(right: 24),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.mutedGold : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.title.copyWith(
            fontSize: 16,
            color: isActive ? AppColors.mutedGold : AppColors.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label) {
    bool isActive = _activeSort == label;
    return GestureDetector(
      onTap: () => setState(() => _activeSort = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.mutedGold.withValues(alpha: 0.1)
              : AppColors.surfaceContainerHigh,
          borderRadius: AppShapes.fullRadius,
          border: Border.all(
            color: isActive
                ? AppColors.mutedGold.withValues(alpha: 0.2)
                : AppColors.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            color: isActive ? AppColors.mutedGold : AppColors.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ),
    );
  }


  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => context.pushNamed('create_post'),
      backgroundColor: AppColors.mutedGold,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
    );
  }
}

class _SliverFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double extent;

  _SliverFilterDelegate({required this.child, required this.extent});

  @override
  double get minExtent => extent;
  @override
  double get maxExtent => extent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SliverFilterDelegate oldDelegate) {
    return true;
  }
}
