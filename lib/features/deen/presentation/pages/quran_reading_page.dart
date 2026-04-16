import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/star_painter.dart';

class QuranReadingPage extends StatefulWidget {
  const QuranReadingPage({super.key});

  @override
  State<QuranReadingPage> createState() => _QuranReadingPageState();
}

class _QuranReadingPageState extends State<QuranReadingPage> {
  int? _selectedSurahIndex;
  bool _isAudioPlaying = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _selectSurah(int? index) {
    setState(() {
      _selectedSurahIndex = index;
    });
  }

  void _toggleAudio() {
    setState(() {
      _isAudioPlaying = !_isAudioPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.quranSurface,
      appBar: _buildAppBar(),
      endDrawer: const _QuranQuickToolsDrawer(),
      body: Stack(
        children: [
          _selectedSurahIndex == null
              ? _QuranDashboardView(onSurahSelected: _selectSurah)
              : _QuranReaderView(
                  surahIndex: _selectedSurahIndex!,
                  onBack: () => _selectSurah(null),
                ),
          if (_selectedSurahIndex != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _FloatingAudioManager(
                isPlaying: _isAudioPlaying,
                onToggle: _toggleAudio,
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final title = _selectedSurahIndex == null
        ? "The Noble Qur'an"
        : "${_selectedSurahIndex! + 1}. ${_quranData[_selectedSurahIndex!].englishName}";

    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        color: AppColors.quranSurface,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.quranPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppTypography.title.copyWith(
                      color: AppColors.quranPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_selectedSurahIndex != null) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more_rounded,
                        size: 16, color: AppColors.quranPrimary),
                  ],
                ],
              ),
              IconButton(
                icon: const Icon(Icons.settings,
                    color: AppColors.quranPrimary),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuranDashboardView extends StatelessWidget {
  final Function(int) onSurahSelected;

  const _QuranDashboardView({required this.onSurahSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeHero(),
          const SizedBox(height: 32),
          const _LastReadSection(),
          const SizedBox(height: 32),
          const _TabNavigation(),
          const SizedBox(height: 24),
          _SurahList(onSurahSelected: onSurahSelected),
        ],
      ),
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.quranPrimaryContainer,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.quranPrimary.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Icon(
              Icons.auto_stories_rounded,
              size: 200,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ASSALAMU ALAIKUM',
                style: AppTypography.label.copyWith(
                  color: AppColors.quranSecondaryContainer,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start your daily\nreading',
                style: AppTypography.display.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.menu_book_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Juz 3 • Hizb 6',
                      style: AppTypography.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LastReadSection extends StatelessWidget {
  const _LastReadSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LAST READ',
              style: AppTypography.label.copyWith(
                color: AppColors.quranOnSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                fontSize: 10,
              ),
            ),
            Text(
              'View All',
              style: AppTypography.label.copyWith(
                color: AppColors.quranPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _LastReadCard(
                title: 'Al-Baqarah',
                desc: 'Verse 255 (Ayatul Kursi)',
                time: '2 hours ago',
                color: AppColors.quranSecondaryContainer,
                icon: Icons.bookmark_rounded,
                onSurfaceColor: AppColors.quranOnSecondaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LastReadCard(
                title: 'Al-Mumtahanah',
                desc: 'Verse 4',
                time: 'Yesterday',
                color: AppColors.quranSurfaceLow,
                icon: Icons.history_rounded,
                onSurfaceColor: AppColors.quranOnSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LastReadCard extends StatelessWidget {
  final String title;
  final String desc;
  final String time;
  final Color color;
  final IconData icon;
  final Color onSurfaceColor;

  const _LastReadCard({
    required this.title,
    required this.desc,
    required this.time,
    required this.color,
    required this.icon,
    required this.onSurfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: onSurfaceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: onSurfaceColor, size: 16),
              ),
              Text(
                time.toUpperCase(),
                style: AppTypography.label.copyWith(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: onSurfaceColor.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTypography.title.copyWith(
              color: onSurfaceColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            desc,
            style: AppTypography.label.copyWith(
              color: onSurfaceColor.withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabNavigation extends StatelessWidget {
  const _TabNavigation();

  @override
  Widget build(BuildContext context) {
    final tabs = ['Sura', 'Page', 'Juz', 'Hizb', 'Ruku'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tabs.map((tab) {
          bool isActive = tab == 'Sura';
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: isActive
                    ? AppColors.quranPrimary
                    : AppColors.quranSurfaceLow,
                foregroundColor: isActive ? Colors.white : AppColors.quranOutline,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                tab,
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SurahList extends StatelessWidget {
  final Function(int) onSurahSelected;
  const _SurahList({required this.onSurahSelected});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _quranData.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final surah = _quranData[index];
        return InkWell(
          onTap: () => onSurahSelected(index),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.quranOnSurface.withValues(alpha: 0.03)),
            ),
            child: Row(
              children: [
                IslamicStarDecoration(
                  size: 44,
                  color: AppColors.quranPrimary.withValues(alpha: 0.08),
                  child: Text(
                    '${index + 1}',
                    style: AppTypography.label.copyWith(
                      color: AppColors.quranPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.englishName,
                        style: AppTypography.title.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.quranPrimary,
                        ),
                      ),
                      Text(
                        '${surah.ayahs} VERSES • ${index % 2 == 0 ? "MECCAN" : "MEDINAN"}',
                        style: AppTypography.label.copyWith(
                          color: AppColors.quranOnSurface.withValues(alpha: 0.4),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  surah.arabicName,
                  style: GoogleFonts.amiri(
                    fontSize: 24,
                    color: AppColors.quranPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuranReaderView extends StatelessWidget {
  final int surahIndex;
  final VoidCallback onBack;

  const _QuranReaderView({
    required this.surahIndex,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final surah = _quranData[surahIndex];
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
          child: Column(
            children: [
              _SurahHeroCard(surah: surah),
              const SizedBox(height: 48),
              _BismillahHeader(),
              const SizedBox(height: 32),
              _VerseList(surah: surah),
              const SizedBox(height: 64),
              _NextSurahButton(),
            ],
          ),
        ),
      ],
    );
  }
}

class _SurahHeroCard extends StatelessWidget {
  final Surah surah;
  const _SurahHeroCard({required this.surah});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.quranPrimaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.quranPrimary.withValues(alpha: 0.1),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.mosque_rounded, size: 120, color: Colors.white),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.quranSecondaryContainer,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'MECCAN',
                      style: AppTypography.label.copyWith(
                        color: AppColors.quranOnSecondaryContainer,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${surah.ayahs} VERSES',
                    style: AppTypography.label.copyWith(
                      color: AppColors.quranPrimaryFixedDim,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                surah.englishName,
                style: AppTypography.display.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                surah.meaning,
                style: AppTypography.body.copyWith(
                  color: AppColors.quranPrimaryFixedDim,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Listen Audio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.quranPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BismillahHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
          style: GoogleFonts.amiri(
            fontSize: 18,
            color: AppColors.quranPrimary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 1,
          color: AppColors.quranOutline.withValues(alpha: 0.2),
        ),
      ],
    );
  }
}

class _VerseList extends StatelessWidget {
  final Surah surah;
  const _VerseList({required this.surah});

  @override
  Widget build(BuildContext context) {
    if (surah.verses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Text(
          'Quran Content Loading...',
          style: AppTypography.body.copyWith(color: AppColors.quranOutline),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: surah.verses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 48),
      itemBuilder: (context, index) {
        final verse = surah.verses[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    verse.arabic,
                    style: GoogleFonts.amiri(
                      fontSize: 32,
                      height: 2.0,
                      color: AppColors.quranPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(
                      'VERSE ${index + 1}',
                      style: AppTypography.label.copyWith(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: AppColors.quranOutline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.quranSurfaceLow,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTypography.label.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.quranPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              verse.translation,
              style: AppTypography.body.copyWith(
                fontSize: 16,
                color: AppColors.quranOnSurface.withValues(alpha: 0.8),
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildActionIcon(Icons.play_circle_outline_rounded),
                _buildActionIcon(Icons.menu_book_rounded),
                _buildActionIcon(Icons.bookmark_outline_rounded),
                _buildActionIcon(Icons.share_outlined),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Icon(icon, color: AppColors.quranPrimary, size: 20),
    );
  }
}

class _NextSurahButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {},
        icon: const Text('Next Surah'),
        label: const Icon(Icons.arrow_forward_rounded, size: 16),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.quranPrimary,
          textStyle: AppTypography.label.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}

class _FloatingAudioManager extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onToggle;

  const _FloatingAudioManager({
    required this.isPlaying,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.quranPrimaryContainer,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.quranPrimary.withValues(alpha: 0.3),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.graphic_eq_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOW PLAYING',
                      style: AppTypography.label.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Mishary Rashid Alafasy',
                      style: AppTypography.label.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded,
                        color: Colors.white),
                    onPressed: () {},
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.quranPrimary,
                        ),
                        onPressed: onToggle,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded,
                        color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuranQuickToolsDrawer extends StatelessWidget {
  const _QuranQuickToolsDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 340,
      backgroundColor: AppColors.quranSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Tools',
                  style: AppTypography.headline.copyWith(
                    color: AppColors.quranPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DrawerSection(
                      title: 'NAVIGATION CONTEXT',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _PillButton(label: 'Sura', isActive: true),
                          _PillButton(label: 'Page'),
                          _PillButton(label: 'Juz'),
                          _PillButton(label: 'Hizb'),
                          _PillButton(label: 'Ruku'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _DrawerSection(
                      title: 'DISPLAY PREFERENCES',
                      child: Column(
                        children: [
                          _ToggleItem(
                              label: 'Arabic Script',
                              icon: Icons.auto_stories_rounded,
                              isActive: true),
                          const SizedBox(height: 12),
                          _ToggleItem(
                              label: 'Translation',
                              icon: Icons.translate_rounded,
                              isActive: true),
                          const SizedBox(height: 12),
                          _ToggleItem(
                              label: 'Tafsir',
                              icon: Icons.menu_book_rounded,
                              isActive: false),
                          const SizedBox(height: 12),
                          _ToggleItem(
                              label: 'Word by Word',
                              icon: Icons.rebase_edit,
                              isActive: false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _DrawerSection(
                      title: 'TYPOGRAPHY',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Arabic Font Style',
                            style: AppTypography.label.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.quranOnSurface
                                    .withValues(alpha: 0.6)),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.quranSurfaceLow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: 'Uthmani Script',
                                isExpanded: true,
                                style: AppTypography.label.copyWith(
                                    color: AppColors.quranOnSurface,
                                    fontWeight: FontWeight.bold),
                                items: ['Uthmani Script', 'Indo-Pak']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (_) {},
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _FontSlider(label: 'Arabic Font Size', value: 32),
                          const SizedBox(height: 24),
                          _FontSlider(label: 'Translation Font Size', value: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.save_rounded),
                label: const Text('APPLY SETTINGS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.quranPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _DrawerSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.label.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: AppColors.quranOnSurface.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final bool isActive;
  const _PillButton({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.quranPrimary : AppColors.quranSurfaceLow,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          color: isActive ? Colors.white : AppColors.quranOnSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  const _ToggleItem(
      {required this.label, required this.icon, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.quranSurfaceLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.quranPrimary, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.quranOnSurface,
                ),
              ),
            ],
          ),
          Switch.adaptive(
            value: isActive,
            onChanged: (_) {},
            activeColor: AppColors.quranPrimary,
          ),
        ],
      ),
    );
  }
}

class _FontSlider extends StatelessWidget {
  final String label;
  final double value;
  const _FontSlider({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppTypography.label.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.quranOnSurface.withValues(alpha: 0.6))),
            Text('${value.toInt()}px',
                style: AppTypography.label.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.quranPrimary)),
          ],
        ),
        Slider(
          value: value,
          min: 12,
          max: 64,
          activeColor: AppColors.quranPrimary,
          inactiveColor: AppColors.quranOutline.withValues(alpha: 0.2),
          onChanged: (_) {},
        ),
      ],
    );
  }
}

// Data Models
class Verse {
  final String arabic;
  final String translation;
  final int number;
  Verse(this.arabic, this.translation, this.number);
}

class Surah {
  final String englishName;
  final String arabicName;
  final String meaning;
  final int ayahs;
  final List<Verse> verses;
  Surah(
      this.englishName, this.arabicName, this.meaning, this.ayahs, this.verses);
}

final List<Surah> _quranData = [
  Surah('Al-Fatihah', 'الفاتحة', 'The Opening', 7, [
    Verse('ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ',
        '[All] praise is [due] to Allah, Lord of the worlds –', 1),
    Verse('ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
        'The Entirely Merciful, the Especially Merciful,', 2),
    Verse('مَـٰلِكِ يَوْمِ ٱلدِّينِ', 'Sovereign of the Day of Recompense.', 3),
    Verse('إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
        'It is You we worship and You we ask for help.', 4),
    Verse('ٱهْدينا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ',
        'Guide us to the straight path –', 5),
  ]),
  Surah('Al-Baqarah', 'البقرة', 'The Cow', 286, []),
  Surah('Al-Kahf', 'الكهف', 'The Cave', 110, [
    Verse('الْحَمْدُ لِلَّهِ الَّذِي أَنزَلَ عَلَىٰ عَبْدِهِ الْكِتَابَ وَلَمْ يَجْعَل لَّهُ عِوجًا',
        '[All] praise is [due] to Allah, who has sent down upon His Servant the Book and has not made therein any deviance.', 1),
  ]),
  Surah('Al-Furqan', 'الفرقآن', 'The Criterion', 77, [
    Verse(
        'تَبَارَكَ الَّذِي نَزَّلَ الْفُرْقَانَ عَلَىٰ عَبْدِهِ لِيَكُونَ لِلْعَالَمِينَ نَذِيرًا',
        'Blessed is He who sent down the Criterion upon His Servant that he may be to the worlds a warner -',
        1),
    Verse(
        'الَّذِي لَهُ مُلْكُ السَّمَاوَاتِ وَالْأَرْضِ وَلَمْ يَتَّخِذْ وَلَدًا وَلَمْ يَكُن لَّهُ شَرِيكٌ فِي الْمُلْكِ وَخَلَقَ كُلَّ شَيْءٍ فَقَدَّرَهُ تَقْدِيرًا',
        'He to whom belongs the dominion of the heavens and the earth and who has not taken a son and has not had a partner in dominion and has created each thing and determined it with [precise] determination.',
        2),
  ]),
];
