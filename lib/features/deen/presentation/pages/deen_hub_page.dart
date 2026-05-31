import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../quran/presentation/pages/quran_reading_page.dart';
import '../../../zakat/presentation/pages/zakat_calculator_page.dart';
import '../../../tasbih/presentation/pages/tasbih_page.dart';

class DeenHubPage extends ConsumerWidget {
  const DeenHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        title: 'Deen Hub',
        isMainScreen: true,
        location: 'Deen Hub',
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
      body: const SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _DeenSearchBar(),
            ),
            SizedBox(height: 16),
            _EssentialPillars(),
            SizedBox(height: 16),
            _DailyInsightsBento(),
            SizedBox(height: 16),
            _RecentlyViewed(),
          ],
        ),
      ),
    );
  }
}


class _DeenSearchBar extends StatelessWidget {
  const _DeenSearchBar();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 15,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      borderRadius: BorderRadius.circular(24),
      color: AppColors.surfaceContainerLowest.withValues(alpha: 0.4),
      border: Border.all(
        color: AppColors.primary.withValues(alpha: 0.1),
        width: 1,
      ),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            const Icon(Icons.search_rounded,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                style: AppTypography.body.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Search Quran, Hadith, or Duas...',
                  hintStyle: AppTypography.body.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: AppColors.primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _EssentialPillars extends StatelessWidget {
  const _EssentialPillars();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Essential Pillars',
            onSeeAll: () {},
          ),
          const SizedBox(height: 16),
          // Row 1: Quran (Large) & Hadith
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _PillarCard(
                  title: 'Quran',
                  desc: 'Divine Revelation',
                  icon: Icons.menu_book_rounded,
                  accentColor: AppColors.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QuranReadingPage()),
                  ),
                  isFeatured: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: _PillarCard(
                  title: 'Hadith',
                  desc: 'Prophetic Wisdom',
                  icon: Icons.history_edu_rounded,
                  accentColor: AppColors.secondary,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: Dhikr & Dua & Zakat
          Row(
            children: [
              Expanded(
                child: _PillarCard(
                  title: 'Tasbih',
                  desc: 'Remembrance',
                  icon: Icons.fingerprint_rounded,
                  accentColor: AppColors.taupe,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TasbihPage()),
                  ),
                  isFeatured: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PillarCard(
                  title: 'Dua',
                  desc: 'Supplication',
                  icon: Icons.volunteer_activism_rounded,
                  accentColor: AppColors.sand,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 3: Zakat & Hajj
          Row(
            children: [
              Expanded(
                child: _PillarCard(
                  title: 'Zakat',
                  desc: 'Purification',
                  icon: Icons.calculate_rounded,
                  accentColor: AppColors.sage,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ZakatCalculatorPage()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _PillarCard(
                  title: 'Hajj Guide',
                  desc: 'The Holy Journey of Faith',
                  icon: Icons.mosque_rounded,
                  accentColor: AppColors.mutedGold,
                  onTap: () {},
                  isFeatured: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 4: Books & Fatwas
          Row(
            children: [
              Expanded(
                child: _PillarCard(
                  title: 'Library',
                  desc: 'Knowledge Base',
                  icon: Icons.library_books_rounded,
                  accentColor: AppColors.grayGreen,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PillarCard(
                  title: 'Fatwas',
                  desc: 'Guideline',
                  icon: Icons.gavel_rounded,
                  accentColor: AppColors.taupe,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillarCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isFeatured;

  const _PillarCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BentoCard(
        padding: EdgeInsets.zero,
        color: Colors.white,
        child: ClipRRect(
          borderRadius: AppShapes.lgRadius,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: isFeatured
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.center,
              mainAxisAlignment: isFeatured
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: isFeatured ? 32 : 24,
                  ),
                ),
                if (!isFeatured) const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: isFeatured
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headline.copyWith(
                        fontSize: isFeatured ? 18 : 14,
                        color: AppColors.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: AppTypography.label.copyWith(
                        fontSize: isFeatured ? 11 : 9,
                        color:
                            AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyInsightsBento extends StatelessWidget {
  const _DailyInsightsBento();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _SectionHeader(title: 'Daily Insights', onSeeAll: () {}),
          const SizedBox(height: 16),
          // Ayah Card
          BentoCard(
            padding: EdgeInsets.zero,
            color: AppColors.primary,
            child: Stack(
              children: [
                Positioned(
                  top: -20,
                  right: -20,
                  child: Icon(
                    Icons.format_quote_rounded,
                    size: 150,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              'DAILY AYAH',
                              style: AppTypography.label.copyWith(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const Icon(Icons.bookmark_border_rounded,
                              color: Colors.white70, size: 22),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 28,
                            color: Colors.white,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 1,
                        width: 40,
                        color: Colors.white30,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '"So remember Me; I will remember you. And be grateful to Me and do not deny Me."',
                        style: AppTypography.body.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Surah Al-Baqarah 2:152',
                        style: AppTypography.label.copyWith(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Hadith Card
          BentoCard(
            padding: const EdgeInsets.all(28),
            color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        'DAILY HADITH',
                        style: AppTypography.label.copyWith(
                          color: AppColors.secondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const Icon(Icons.share_rounded,
                        color: AppColors.primary, size: 20),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'الدِّينُ النَّصِيحَةُ',
                  style: AppTypography.headline.copyWith(
                    color: AppColors.primary,
                    fontSize: 22,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 20),
                Text(
                  '"The religion is sincere advice."',
                  style: AppTypography.title.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Reported by Tamim ad-Dari • Sahih Muslim',
                  style: AppTypography.label.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentlyViewed extends StatelessWidget {
  const _RecentlyViewed();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Recently Viewed',
            actionTitle: 'Clear All',
            onSeeAll: () {},
          ),
          const SizedBox(height: 16),
          _buildRecentItem(
            'The Importance of Niyyah',
            'Article • 2 hours ago',
            Icons.history_rounded,
          ),
          const SizedBox(height: 12),
          _buildRecentItem(
            'Surah Al-Kahf',
            'Quran • Yesterday',
            Icons.menu_book_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItem(String title, String meta, IconData icon) {
    return BentoCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: AppTypography.label.copyWith(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
              size: 20),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionTitle;
  final VoidCallback onSeeAll;

  const _SectionHeader({
    required this.title,
    this.actionTitle,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: AppTypography.headline.copyWith(
            fontSize: 22,
            color: AppColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
