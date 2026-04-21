import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_tokens.dart';
import '../providers/shorts_provider.dart';

class CreatorProfileScreen extends ConsumerWidget {
  const CreatorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortsAsync = ref.watch(shortsFeedProvider);

    return Scaffold(
      backgroundColor: AppColors.emeraldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu, color: AppColors.emeraldPrimary),
        title: Text(
          'BAYT-AL-NOOR',
          style: AppTypography.title.copyWith(
            color: AppColors.emeraldSecondary,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        actions: const [
          Icon(Icons.settings, color: AppColors.emeraldPrimary),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header
            const _ProfileHeader(),
            const SizedBox(height: 32),
            
            // Tabs
            const _ProfileTabs(),
            
            // Grid
            shortsAsync.when(
              data: (shorts) => Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: shorts.length * 3, // Mock more items
                  itemBuilder: (context, index) {
                    final video = shorts[index % shorts.length];
                    return GestureDetector(
                      onTap: () => context.goNamed('shorts'),
                      child: _VideoThumbnail(
                        imageUrl: video.thumbnailUrl,
                        views: '${(1000 + index * 100)}',
                      ),
                    );
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 110,
          height: 110,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.emeraldSecondary, Colors.transparent],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.emeraldBg, width: 4),
              image: const DecorationImage(
                image: NetworkImage('https://images.pexels.com/photos/1036623/pexels-photo-1036623.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Name & Bio
        Text(
          'Zahra Al-Farsi',
          style: AppTypography.display.copyWith(color: Colors.white, fontSize: 24),
        ),
        const SizedBox(height: 4),
        const Text(
          '@zahra_spiritual',
          style: TextStyle(color: AppColors.emeraldPrimary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Seeking light through sacred geometry and stillness. Capturing the divine in the mundane. 🌙✨',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: AppColors.emeraldOnSurface.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Stats
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatItem(label: 'Posts', value: '142'),
            _StatDivider(),
            _StatItem(label: 'Followers', value: '12.8k'),
            _StatDivider(),
            _StatItem(label: 'Following', value: '432'),
          ],
        ),
        const SizedBox(height: 24),
        
        // Actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: _ProfileButton(
                  label: 'Edit Profile',
                  isPrimary: true,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProfileButton(
                  label: 'Share Profile',
                  isPrimary: false,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.title.copyWith(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.2),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      color: Colors.white10,
      margin: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ProfileButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: isPrimary ? AppColors.emeraldGradient : null,
          border: isPrimary ? null : Border.all(color: AppColors.emeraldPrimary.withValues(alpha: 0.3), width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isPrimary ? AppColors.emeraldOnPrimary : AppColors.emeraldSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _TabItem(icon: Icons.movie_filter, label: 'Reels', isActive: true, onTap: () {}),
          _TabItem(icon: Icons.bookmark_border, label: 'Saved', isActive: false, onTap: () {}),
          _TabItem(icon: Icons.person_pin_outlined, label: 'Tagged', isActive: false, onTap: () {}),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.emeraldPrimary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? AppColors.emeraldPrimary : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: isActive ? AppColors.emeraldPrimary : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  final String imageUrl;
  final String views;

  const _VideoThumbnail({required this.imageUrl, required this.views});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 8,
            left: 8,
            child: Row(
              children: [
                const Icon(Icons.play_arrow, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  views,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
