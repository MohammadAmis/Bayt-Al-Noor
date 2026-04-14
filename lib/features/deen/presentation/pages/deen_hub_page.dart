import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import 'quran_reading_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class DeenHubPage extends StatelessWidget {
  const DeenHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        title: 'Bayt Al-Noor',
        subtitle: 'بَيْتُ النُّورِ',
        location: 'London, UK',
        onSettingsPressed: () => Navigator.pushNamed(context, '/settings'),
        onProfilePressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserProfilePage(
              name: 'Fatima Al-Sayed',
              avatarUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBTsguL1thXHygl49n-buglmiegAxbwbxDG_0bz8DyMlY4B9PpbOsKMGjNK9LK1xRQeDx8dUwdqiVdvRz_FYFD5Uqqk2-bY4xdF1eQf9RqHESqq4ypt0k7zaDjDKLW0ELh8RVEnj-u2McOpnuf_39Nx27EZlDnizOq3GYfaQ45eQibevgJ3MnbdMjy0DpTxF_Hrc-tke3MtJ981TVt7wVc1CzSGJ70wPDhNo111GDqA5JnVPqhTyUjwaaGOpXZbKdmE3YxkoveBb4Y',
              bio: 'Seeking tranquility through reflection and prayer.',
            ),
          ),
        ),
      ),
      body: const SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _DeenSearchBar(),
            ),
            SizedBox(height: 32),
            _FeaturedHero(),
            SizedBox(height: 40),
            _ContinueJourney(),
            SizedBox(height: 40),
            _EssentialPillars(),
            SizedBox(height: 40),
            _DailyInsightsBento(),
            SizedBox(height: 40),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.outline, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Quran, Hadith, or Duas...',
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.outline,
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedHero extends StatelessWidget {
  const _FeaturedHero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          image: const DecorationImage(
            image: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDb6fvK6ItA3fNqH3mDp-MKEMbWqoRwvJdI5sARJjmCWE_0WbtBiVkh9HeZS5znBUkbJNRxjcjS6YILuaoIrvT_a1R6whNhM8uwiqanVz39XY40R7mnM6VpvAUPe0H4E6Lh5KcpXIvi7y5UxeJCYzUoHN9RoTznhVY7FrDLyk82qeYHcYsCMzY5VRkJT93W8x0NafcBbyKIv41FYRabMdN6gNrH7RbITgpmI2OpCPo7KUnplgyyY6abt6qBqOV9YrlPJ4P2Vc9DKTc'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.9),
                AppColors.primary.withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  'FEATURED INSIGHT',
                  style: AppTypography.label.copyWith(
                    color: AppColors.onSecondaryFixed,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The Excellence of Ramadan',
                style: AppTypography.headline.copyWith(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Discover the spiritual depths of the holiest month.',
                style: AppTypography.body.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text('Read More'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  foregroundColor: AppColors.onPrimaryFixed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueJourney extends StatelessWidget {
  const _ContinueJourney();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continue Journey',
            style: AppTypography.headline.copyWith(
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.menu_book,
                      color: AppColors.primaryFixed, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Surah Ar-Rahman',
                            style: AppTypography.title.copyWith(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '65%',
                            style: AppTypography.label.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: 0.65,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceContainerHighest,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Last read Ayah 42 • 3 mins ago',
                        style: AppTypography.label.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow,
                      color: AppColors.primary, size: 20),
                ),
              ],
            ),
          ),
        ],
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
          Text(
            'Essential Pillars',
            style: AppTypography.headline.copyWith(
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildPillarCard(context, 'Quran', 'Divine scripture',
                  Icons.auto_stories, AppColors.primary),
              _buildPillarCard(context, 'Hadith', 'Prophetic traditions',
                  Icons.history_edu, AppColors.secondary),
              _buildPillarCard(context, 'Tashbih', 'Dhikr', Icons.fingerprint,
                  AppColors.onTertiaryContainer),
              _buildPillarCard(context, 'Dua', 'Islamic',
                  Icons.waving_hand_rounded, AppColors.onPrimaryColorContainer),
              _buildPillarCard(context, 'Fatwas', 'Religious rulings',
                  Icons.gavel, AppColors.secondary),
              _buildPillarCard(context, 'Books', 'Islamic books', Icons.book,
                  AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillarCard(BuildContext context, String title, String desc,
      IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        if (title == 'Quran') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuranReadingPage()),
          );
        }
      },
      // onTap: () {
      //   if (title == 'Tashbih') {
      //     Navigator.push(context,
      //         MaterialPageRoute(builder: (context) => const TasbihPage()));
      //   }
      // },

      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.title
                  .copyWith(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: AppTypography.label
                  .copyWith(fontSize: 9, color: AppColors.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
          // Daily Ayah
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(32),
              image: const DecorationImage(
                image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDvBS3AAUStiBKU6uJCaz62fCU3Ud2ofcUjHJHhXljbWwXU69McM5aTF98dUVADYumcWMzsElARz-31mN1ApF6hNv-OBqEoArqwy1Td4YbwEuDi2W-E7XyIKRmdH1GP31_tsPK25TShQRKh8S7c4Yq0YWKZ3l77Y6kP2_TWr-gG1eCbzY8ql9p7jRtKJhhjZ9J16DcWnZ8kQA6l4sSd7_qbqNLQZYqgsILJcLuuZzisx5EnSWXrnzpJTxC-qKvtvt4olJXXjemLKeQ'),
                fit: BoxFit.cover,
                opacity: 0.05,
              ),
            ),
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
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        'DAILY AYAH',
                        style: AppTypography.label.copyWith(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5),
                      ),
                    ),
                    const Icon(Icons.bookmark_outline,
                        color: AppColors.secondaryFixed, size: 20),
                  ],
                ),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
                    style: TextStyle(
                      fontFamily: 'Noto Serif',
                      fontSize: 24,
                      color: Colors.white,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),
                Text(
                  '"So remember Me; I will remember you. And be grateful to Me and do not deny Me."',
                  style: AppTypography.body.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Surah Al-Baqarah 2:152',
                  style: AppTypography.label
                      .copyWith(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Daily Hadith
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(32),
            ),
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
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        'DAILY HADITH',
                        style: AppTypography.label.copyWith(
                            color: AppColors.onSecondaryFixed,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5),
                      ),
                    ),
                    const Icon(Icons.share_outlined,
                        color: AppColors.primary, size: 18),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'الدِّينُ النَّصِيحَةُ',
                    style: AppTypography.headline.copyWith(
                        color: AppColors.primary, fontSize: 20, height: 1.8),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.black12),
                const SizedBox(height: 16),
                Text(
                  '"The religion is sincere advice."',
                  style: AppTypography.title.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sahih Muslim',
                  style: AppTypography.label.copyWith(
                      color: AppColors.onSurfaceVariant, fontSize: 11),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Recently Viewed',
                style: AppTypography.headline
                    .copyWith(fontSize: 18, color: AppColors.primary),
              ),
              Text(
                'Clear All',
                style: AppTypography.label.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecentItem('The Importance of Niyyah', 'Article • 2 hours ago',
              Icons.schedule),
          const SizedBox(height: 12),
          _buildRecentItem(
              'Surah Al-Kahf', 'Quran • Yesterday', Icons.menu_book),
        ],
      ),
    );
  }

  Widget _buildRecentItem(String title, String meta, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title
                      .copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  meta,
                  style: AppTypography.label.copyWith(
                      fontSize: 10, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.outlineVariant, size: 18),
        ],
      ),
    );
  }
}
