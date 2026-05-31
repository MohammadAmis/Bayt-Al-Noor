import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_tokens.dart';
import '../../../forum/data/providers/forum_providers.dart';
import '../../../forum/domain/entities/post_entity.dart';
import '../../../forum/presentation/widgets/forum_post_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SelfProfilePage extends ConsumerStatefulWidget {
  final String? userId;
  final String name;
  final String avatarUrl;
  final String bio;

  /// When true → shows "Edit Profile" button (own account).
  /// When false → shows "Follow + Message" buttons (viewing another user).
  final bool isOwnProfile;

  const SelfProfilePage({
    super.key,
    this.userId,
    required this.name,
    required this.avatarUrl,
    required this.bio,
    this.isOwnProfile = true,
  });

  @override
  ConsumerState<SelfProfilePage> createState() => _SelfProfilePageState();
}

class _SelfProfilePageState extends ConsumerState<SelfProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<PostEntity> _filterPosts(List<PostEntity> all) {
    // Prefer filtering by authorId (exact match), fall back to authorName
    if (widget.userId != null && widget.userId!.isNotEmpty) {
      final byId = all.where((p) => p.authorId == widget.userId).toList();
      if (byId.isNotEmpty) return byId;
    }
    return all.where((p) => p.authorName == widget.name).toList();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(forumPostsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── App Bar ──
          SliverAppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.onSurface,
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.isOwnProfile ? 'My Profile' : widget.name,
              style: AppTypography.titleMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                color: AppColors.onSurface,
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),

          // ── Profile Header ──
          SliverToBoxAdapter(
            child: postsAsync.when(
              loading: () => _buildHeader(postCount: 0),
              error: (_, __) => _buildHeader(postCount: 0),
              data: (all) => _buildHeader(postCount: _filterPosts(all).length),
            ),
          ),

          // ── Sticky Tab Bar ──
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2,
                labelStyle: AppTypography.labelMedium
                    .copyWith(fontWeight: FontWeight.bold),
                unselectedLabelStyle: AppTypography.labelMedium
                    .copyWith(fontWeight: FontWeight.w500),
                tabs: [
                  const Tab(text: 'Posts'),
                  const Tab(text: 'Comments'),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_outline,
                            size: 14,
                            color: widget.isOwnProfile
                                ? AppColors.onSurface
                                : AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        const Text('Saved'),
                      ],
                    ),
                  ),
                  const Tab(text: 'About'),
                ],
              ),
            ),
          ),
        ],

        // ── Tab Content ──
        body: TabBarView(
          controller: _tabController,
          children: [
            // Posts Tab
            _PostsTab(postsAsync: postsAsync, filterPosts: _filterPosts),

            // Comments Tab (placeholder)
            const _EmptyTab(
              icon: Icons.chat_bubble_outline_rounded,
              message: 'No comments yet',
            ),

            // Saved Tab (locked for others)
            _EmptyTab(
              icon: Icons.bookmark_outline_rounded,
              message: widget.isOwnProfile
                  ? 'Your saved posts will appear here'
                  : 'Saved posts are private',
              isLocked: !widget.isOwnProfile,
            ),

            // About Tab
            _AboutTab(bio: widget.bio, name: widget.name),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Header
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildHeader({required int postCount}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              Container(
                width: 128,
                height: 128,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                  color: AppColors.surfaceContainer,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    imageUrl: widget.avatarUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surfaceContainerHigh,
                      child: const Icon(Icons.person,
                          size: 56, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
              // Camera icon overlay for own profile
              if (widget.isOwnProfile)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            widget.name,
            style: AppTypography.display.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 10),

          // Bio — uses widget.bio (no more hardcode)
          if (widget.bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.bio,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Stats row — post count is real, others show '—' until API is wired
          _buildStatsRow(postCount: postCount),
          const SizedBox(height: 20),

          // Action buttons depend on isOwnProfile
          widget.isOwnProfile
              ? _buildEditProfileButton()
              : _buildFollowMessageButtons(),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStatsRow({required int postCount}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(postCount.toString(), 'Posts'),
          _buildVerticalDivider(),
          _buildStatItem('—', 'Comments'),
          _buildVerticalDivider(),
          _buildStatItem('—', 'Karma', showStar: true),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() => Container(
        width: 1,
        height: 32,
        color: AppColors.outlineVariant.withValues(alpha: 0.2),
      );

  Widget _buildStatItem(String value, String label, {bool showStar = false}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showStar) ...[
              const Icon(Icons.star, color: AppColors.secondary, size: 14),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            fontSize: 10,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // TODO: Navigate to edit profile page
        },
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text('Edit Profile'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildFollowMessageButtons() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: Text(
              'Follow',
              style: AppTypography.labelMedium
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.onSurface,
              side: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Message',
              style: AppTypography.labelMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.more_vert,
              size: 20, color: AppColors.onSurface),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Tab Widgets
// ────────────────────────────────────────────────────────────────────────────

class _PostsTab extends StatelessWidget {
  final AsyncValue<List<PostEntity>> postsAsync;
  final List<PostEntity> Function(List<PostEntity>) filterPosts;

  const _PostsTab({required this.postsAsync, required this.filterPosts});

  @override
  Widget build(BuildContext context) {
    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (all) {
        final posts = filterPosts(all);
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.post_add_rounded,
                    size: 56,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: AppTypography.labelMedium.copyWith(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, i) => ForumPostCard(post: posts[i]),
        );
      },
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isLocked;

  const _EmptyTab({
    required this.icon,
    required this.message,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLocked) ...[
            Icon(Icons.lock_outline_rounded,
                size: 22,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 6),
          ],
          Icon(icon,
              size: 52,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTypography.labelMedium.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  final String bio;
  final String name;

  const _AboutTab({required this.bio, required this.name});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (bio.isNotEmpty) ...[
          Text('Bio',
              style: AppTypography.titleMedium
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            bio,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
          const SizedBox(height: 24),
        ],
        Row(
          children: [
            const Icon(Icons.person_outline_rounded,
                size: 18, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 10),
            Text(
              name,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.onSurface),
            ),
          ],
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// SliverPersistentHeaderDelegate for the TabBar
// ────────────────────────────────────────────────────────────────────────────
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.15)),
        ),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate old) => tabBar != old.tabBar;
}
