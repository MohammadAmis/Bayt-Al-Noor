import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_tokens.dart';
import '../../../forum/presentation/widgets/forum_post_card.dart';
import '../../../forum/data/providers/forum_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PublicProfilePage extends ConsumerStatefulWidget {
  final String communityId;
  final String communityName;

  const PublicProfilePage({
    super.key,
    required this.communityId,
    required this.communityName,
  });

  @override
  ConsumerState<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends ConsumerState<PublicProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isJoined = false;

  static const _tabs = ['Posts', 'About', 'Members', 'Mods'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(forumPostsProvider);

    // ✅ Scaffold is OUTSIDE postsAsync.when() — no more flash on reload
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── Collapsing Banner Header ──
          SliverToBoxAdapter(child: _buildCommunityHeader()),

          // ── Sticky Tab Bar ──
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.mutedGold,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                indicatorColor: AppColors.mutedGold,
                indicatorWeight: 3,
                labelStyle: AppTypography.label
                    .copyWith(fontWeight: FontWeight.w900, fontSize: 14),
                unselectedLabelStyle: AppTypography.label
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),
          ),
        ],

        // ── Tab Content — each tab is independent ──
        body: TabBarView(
          controller: _tabController,
          children: [
            // Posts tab — real data
            _PostsTab(
              postsAsync: postsAsync,
              communityId: widget.communityId,
            ),

            // About tab
            _AboutTab(communityName: widget.communityName),

            // Members tab — placeholder
            const _PlaceholderTab(
              icon: Icons.people_outline_rounded,
              message: 'Member list coming soon',
            ),

            // Mods tab — placeholder
            const _PlaceholderTab(
              icon: Icons.shield_outlined,
              message: 'Moderators coming soon',
            ),
          ],
        ),
      ),

      // FAB — Post to this community
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('create_post'),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon:
            const Icon(Icons.edit_note_rounded, color: Colors.white, size: 24),
        label: Text(
          'Post',
          style: AppTypography.labelLarge
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Community Header (banner + avatar + info)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCommunityHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDU1GXFlqzOhlKEAn55QQEwTM_wkKNeE0uXgYpTsY3PohMLujxexyUzZlLafBY3lfsQX-ar2VS0jZc7Xr9fHIaG9Gv_tg6oxhlPU2BorGVcYC2Eo62m8J9ECsLzBze5kJme8wj_AiFeVVIV13RRa26qrIznTplvKm9xR1-nOlCoRY-bObDPACbqsx0pPRiZed1K7PCFJoE8DoT6w08pDHggfotQknuDZI4YMShyx8e6gvZ3ecGHTUIQm3KzwfGuwD9sWJXBvu9_Nos',
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
            ),
            // Gradient overlay
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                    AppColors.surface.withValues(alpha: 0.5),
                    AppColors.surface,
                  ],
                ),
              ),
            ),
            // Back button
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 16,
              child: _iconButton(Icons.arrow_back_rounded,
                  onTap: () => context.pop()),
            ),
            // Share / more
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              right: 16,
              child: Row(
                children: [
                  _iconButton(Icons.share_outlined),
                  const SizedBox(width: 8),
                  _iconButton(Icons.more_vert_rounded),
                ],
              ),
            ),
            // Community avatar
            Positioned(
              bottom: -24,
              left: 20,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 4),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAvvpGis7WxBDMVs5lAV5t1tPO68LeqSRTzTCVb2eI3qrkwvxOm32xoDzlu2ar-6p3hKQiEqUvEQXZmhlna_Fe3y9rr3Gi8kB47EdZBjspjfUIOgKDY4jvT78RbQiaf6SGcguR934WfM5K8uIaxso8xELn6GUpzhISJBpbF0z5Evg6bknsQnWuVPmIPXQ0ERlPaYTXDt7wjw4eji-swzFpU1tN2nZBOEAUZT5k7gUG20_oJib6dF_dpp4Zu9WAcYBZNMwiYXJ14B78',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 36),

        // Community info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.communityName,
                          style: AppTypography.display.copyWith(
                            fontSize: 28,
                            color: AppColors.onSurface,
                            letterSpacing: -0.8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'r/${widget.communityId}',
                          style: AppTypography.label.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // ✅ Join/Leave toggle — no longer hardcoded
                  GestureDetector(
                    onTap: () => setState(() => _isJoined = !_isJoined),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isJoined
                            ? Colors.transparent
                            : AppColors.primary,
                        border: Border.all(
                            color: AppColors.primary,
                            width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isJoined ? 'JOINED' : 'JOIN',
                        style: AppTypography.label.copyWith(
                          color: _isJoined
                              ? AppColors.primary
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'A sanctuary for those seeking spiritual enlightenment through classical Islamic wisdom and contemporary community connection.',
                style: AppTypography.body.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.6,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),
              // Flair chips
              _buildFlairChips(),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _iconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
      ),
    );
  }

  Widget _buildFlairChips() {
    const flairs = ['#Quran', '#Sunnah', '#History', '#Community', '#Wisdom'];
    int activeIndex = 0;
    return StatefulBuilder(
      builder: (context, setLocal) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(flairs.length, (i) {
            final isActive = i == activeIndex;
            return GestureDetector(
              onTap: () => setLocal(() => activeIndex = i),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.mutedGold.withValues(alpha: 0.12)
                      : AppColors.surfaceContainerHigh,
                  borderRadius: AppShapes.fullRadius,
                  border: Border.all(
                    color: isActive
                        ? AppColors.mutedGold.withValues(alpha: 0.4)
                        : AppColors.outlineVariant.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  flairs[i],
                  style: AppTypography.label.copyWith(
                    color: isActive
                        ? AppColors.mutedGold
                        : AppColors.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Tab Widgets
// ────────────────────────────────────────────────────────────────────────────

class _PostsTab extends StatelessWidget {
  final AsyncValue postsAsync;
  final String communityId;

  const _PostsTab({required this.postsAsync, required this.communityId});

  @override
  Widget build(BuildContext context) {
    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allPosts) {
        final posts = (allPosts as List)
            .where((p) => p.communityId == communityId)
            .toList();
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
                  'No posts in this community yet',
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

class _AboutTab extends StatelessWidget {
  final String communityName;

  const _AboutTab({required this.communityName});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('About $communityName',
            style:
                AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          'A sanctuary for those seeking spiritual enlightenment through classical Islamic wisdom and contemporary community connection.',
          style: AppTypography.body
              .copyWith(color: AppColors.onSurfaceVariant, height: 1.6),
        ),
        const SizedBox(height: 24),
        _buildInfoRow(Icons.people_outline_rounded, '125k Seekers'),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.calendar_today_outlined, 'Created January 2023'),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.public_rounded, 'Public Community'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(text,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.onSurface)),
      ],
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String message;

  const _PlaceholderTab({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 56,
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

// ────────────────────────────────────────────────────────────────────────────
// Sliver Tab Bar Delegate
// ────────────────────────────────────────────────────────────────────────────
class _SliverTabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabDelegate(this.tabBar);

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
  bool shouldRebuild(covariant _SliverTabDelegate old) =>
      tabBar != old.tabBar;
}
