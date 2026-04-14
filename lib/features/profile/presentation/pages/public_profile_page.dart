import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';

class PublicProfilePage extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final String bio;
  final List<String> badges;
  final int reflectionsCount;
  final int followersCount;
  final int followingCount;

  const PublicProfilePage({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.bio,
    this.badges = const [],
    this.reflectionsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  bool get _isMobile => MediaQuery.of(context).size.width <= 768;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppTopBar(
          title: 'User Profile',
          location: 'Community Hub',
          leadingIcon: Icons.arrow_back,
          onMenuPressed: () => Navigator.pop(context),
        ),
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: _buildProfileHeader(),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  child: Container(
                    color: AppColors.surface.withValues(alpha:0.9),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: AppShapes.defaultRadius,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.onSurfaceVariant,
                      labelStyle: AppTypography.title.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                      unselectedLabelStyle: AppTypography.title.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                      tabs: const [
                        Tab(text: 'Reflections'),
                        Tab(text: 'Saved Verses'),
                        Tab(text: 'Badges'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              children: [
                _buildReflectionsTab(),
                _buildSavedVersesTab(),
                _buildBadgesTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar with Glow
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
                      color: AppColors.secondaryFixed.withValues(alpha:0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: _isMobile ? 60 : 80,
                backgroundColor: AppColors.surfaceContainerHigh,
                backgroundImage: NetworkImage(widget.avatarUrl),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Name & Bio
          Text(
            widget.name,
            style: AppTypography.display.copyWith(
              fontSize: _isMobile ? 32 : 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.bio,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildBadge(Icons.stars, 'Community Guide', AppColors.primaryFixed, AppColors.onPrimaryFixed),
              _buildBadge(Icons.military_tech, 'Top Contributor', AppColors.secondaryContainer, AppColors.onSecondaryFixed),
            ],
          ),
          const SizedBox(height: 24),
          
          // Interaction Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: AppShapes.lgRadius),
                    elevation: 4,
                  ),
                  child: Text('Message', style: AppTypography.title.copyWith(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    side: const BorderSide(color: AppColors.outlineVariant, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: AppShapes.lgRadius),
                  ),
                  child: Text('Follow', style: AppTypography.title.copyWith(color: AppColors.primary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Stats Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppShapes.xlRadius,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Reflections', widget.reflectionsCount.toString()),
                _buildStatItem('Followers', widget.followersCount.toString()),
                _buildStatItem('Following', widget.followingCount.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppShapes.fullRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: AppTypography.display.copyWith(fontSize: 24, color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: AppTypography.label.copyWith(
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildReflectionsTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildReflectionCard(
          title: 'The Importance of Niyyah',
          preview: '"Action is but by intention..." This hadith has been weighing heavily on my heart lately. How often do we move through our rituals without centering our purpose? Every breath, every small act of kindness...',
          time: '2 days ago',
          likes: 42,
          comments: 8,
        ),
        const SizedBox(height: 16),
        _buildReflectionCard(
          title: 'Reflections on Surah Al-Kahf',
          preview: 'A reminder that patience is the key to understanding the seemingly chaotic movements of the world. The story of Musa (AS) and Khidr (AS) teaches us that our sight is limited...',
          time: '1 week ago',
          likes: 128,
          comments: 15,
        ),
      ],
    );
  }

  Widget _buildReflectionCard({
    required String title,
    required String preview,
    required String time,
    required int likes,
    required int comments,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppShapes.xlRadius,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha:0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.display.copyWith(fontSize: 18, color: AppColors.primary),
                ),
              ),
              Text(
                time,
                style: AppTypography.label.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            preview,
            style: AppTypography.body.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha:0.8),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.surfaceContainer, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInteractionItem(Icons.favorite_outline, likes.toString()),
              const SizedBox(width: 24),
              _buildInteractionItem(Icons.chat_bubble_outline, comments.toString()),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined, size: 20),
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionItem(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          count,
          style: AppTypography.label.copyWith(fontSize: 14, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildSavedVersesTab() {
    return Center(
      child: Text(
        'Verses shared with the community will appear here.',
        style: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant),
      ),
    );
  }

  Widget _buildBadgesTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildDetailedBadge(
          Icons.stars, 
          'Community Guide', 
          'Awarded for consistent and helpful contributions to the community discussions.',
          AppColors.primaryFixed,
        ),
        const SizedBox(height: 16),
        _buildDetailedBadge(
          Icons.military_tech, 
          'Top Contributor', 
          'Ranked among the most active members during the Ramadan 2024 period.',
          AppColors.secondaryContainer,
        ),
      ],
    );
  }

  Widget _buildDetailedBadge(IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: AppShapes.lgRadius,
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.title.copyWith(fontSize: 16, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
