import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';

class QuranReadingPage extends StatefulWidget {
  const QuranReadingPage({super.key});

  @override
  State<QuranReadingPage> createState() => _QuranReadingPageState();
}

class _QuranReadingPageState extends State<QuranReadingPage> {
  int _selectedSurahIndex = 0;
  bool _showSidebar = true;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectSurah(int index) {
    setState(() {
      _selectedSurahIndex = index;
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _toggleSidebar() {
    setState(() {
      _showSidebar = !_showSidebar;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width <= 768;
    final selectedSurah = _quranData[_selectedSurahIndex];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        title: 'Bayt Al-Noor',
        subtitle: 'بَيْتُ النُّورِ',
        location: 'London, UK',
        onSearchPressed: () {},
        onMenuPressed: () => Navigator.pop(context),
        leadingIcon: Icons.arrow_back,
      ),
      drawer: isMobile
          ? Drawer(
              width: MediaQuery.of(context).size.width * 0.85,
              child: _SurahSidebar(
                selectedIndex: _selectedSurahIndex,
                onSelect: (idx) {
                  _selectSurah(idx);
                  Navigator.pop(context);
                },
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isMobile) {
            _scaffoldKey.currentState?.openDrawer();
          } else {
            _toggleSidebar();
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.menu_book),
        label: const Text('Surahs'),
      ),
      body: Row(
        children: [
          // 1. Animated Sidebar (Collapsible)
          if (!isMobile)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _showSidebar ? 340 : 0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  width: 340,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _SurahSidebar(
                      selectedIndex: _selectedSurahIndex,
                      onSelect: _selectSurah,
                      onToggle: _toggleSidebar, // Passes toggle callback
                    ),
                  ),
                ),
              ),
            ),

          // 2. Main Reading Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 40, 24, isMobile ? 16 : 40, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Noble Quran',
                    style: AppTypography.display.copyWith(
                      fontSize: isMobile ? 32 : 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ReadingCanvas(surah: selectedSurah),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;
  final VoidCallback? onToggle; // Added toggle callback

  const _SurahSidebar({
    required this.selectedIndex,
    required this.onSelect,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width <= 768;

    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Surah Directory',
                        style: AppTypography.headline.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onToggle != null && !isMobile)
                      IconButton(
                        onPressed: onToggle,
                        icon: const Icon(Icons.menu_open,
                            color: AppColors.primary),
                        tooltip: 'Collapse Directory',
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _quranData.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final surah = _quranData[index];
                      bool isActive = selectedIndex == index;

                      return GestureDetector(
                        onTap: () => onSelect(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: isActive
                                ? const Border(
                                    left: BorderSide(
                                        color: AppColors.primary, width: 4))
                                : null,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color:
                                          AppColors.primary.withValues(alpha:0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.outlineVariant
                                          .withValues(alpha:0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.white
                                          : AppColors.onSurfaceVariant,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                      style: AppTypography.headline.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${surah.meaning.toUpperCase()} • ${surah.ayahs} AYAHS',
                                      style: AppTypography.label.copyWith(
                                        fontSize: 8,
                                        color: AppColors.onSurfaceVariant,
                                        letterSpacing: 0.8,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                surah.arabicName,
                                style: GoogleFonts.amiri(
                                  fontSize: 20,
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.onSurfaceVariant,
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Last Read Card
        Container(
          width: double.infinity,
          height: 160,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            image: const DecorationImage(
              image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuD0BLT85FIkEoiL0nBR3ZTecMJYm3iEUHly6azssaoJPhWPavGiiUc4FyvBA0458_5WEyKKHi-qF8fqIspzgr0t4FdwHS7zw5rlKGfd2N_jY6nS8ji9CfugjbiiJFE_0HYGYDjuy20hQBjd8qwhONHdgIAQNflnZD_BBsC6KGkYBqUbmfLgMHPlWOgCYqmlBEDTn5pVqUOeEra0AACVTvVcp-Pz3IbcmHDP4_QRttCx_alUzhyODbiD6BHfdMDRxMFqvuPaAZwd2Cs'),
              fit: BoxFit.cover,
              opacity: 0.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'LAST READ',
                style: AppTypography.label.copyWith(
                  color: AppColors.secondaryFixed,
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Al-Baqarah, Ayah 255',
                style: AppTypography.headline.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  value: 0.42,
                  minHeight: 4,
                  backgroundColor: Colors.white10,
                  color: AppColors.secondaryFixed,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadingCanvas extends StatelessWidget {
  final Surah surah;

  const _ReadingCanvas({required this.surah});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width <= 768;

    return CustomPaint(
      painter: _ParchmentTexturePainter(),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 48, vertical: isMobile ? 32 : 64),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFAF3).withValues(alpha:0.9),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha:0.15)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha:0.04),
              blurRadius: 40,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.flare, color: AppColors.secondary, size: 40),
            const SizedBox(height: 24),
            _buildBismillah(isMobile),
            const SizedBox(height: 12),
            Text(
              'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
              style: AppTypography.headline.copyWith(
                color: AppColors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            const Divider(height: 1, color: AppColors.outlineVariant),
            const SizedBox(height: 40),
            if (surah.verses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: Text(
                  'Quran Content Loading...',
                  style: AppTypography.body.copyWith(color: AppColors.outline),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: surah.verses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 64),
                itemBuilder: (context, index) {
                  final verse = surah.verses[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Arabic Text (Top)
                      Text(
                        verse.arabic,
                        style: GoogleFonts.amiri(
                          fontSize: isMobile ? 32 : 44,
                          height: 2.0,
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 24),

                      // 2. English Translation (Middle)
                      Text(
                        verse.translation,
                        style: AppTypography.headline.copyWith(
                          fontSize: 16,
                          color: AppColors.onSurfaceVariant.withValues(alpha:0.9),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 3. Footer Row: Actions (Left) & Verse Number (Right)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildActionBtn(Icons.play_arrow),
                              _buildActionBtn(Icons.bookmark_outline),
                              _buildActionBtn(Icons.share_outlined),
                            ],
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha:0.05),
                              border: Border.all(
                                  color: AppColors.primary.withValues(alpha:0.15)),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${verse.number}',
                                style: GoogleFonts.amiri(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 80),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next Surah: Al-Baqarah'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                textStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBismillah(bool isMobile) {
    return Text(
      'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
      style: GoogleFonts.amiri(
        fontSize: isMobile ? 36 : 48,
        color: AppColors.primary,
        height: 1.8,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionBtn(IconData icon) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon, size: 20),
      color: AppColors.outline.withValues(alpha:0.8),
      splashRadius: 24,
    );
  }
}

class _ParchmentTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha:0.15)
      ..strokeWidth = 0.5;

    const double gap = 24.0;
    for (double i = 0; i < size.width; i += gap) {
      for (double j = 0; j < size.height; j += gap) {
        canvas.drawCircle(Offset(i, j), 0.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

// Full 114 Surah Data (Mocked for Demo)
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
  Surah('Al-Imran', 'آل عمران', 'Family of Imran', 200, []),
  Surah('An-Nisa', 'النساء', 'The Women', 176, []),
  Surah('Al-Ma\'idah', 'المائدة', 'The Table Spread', 120, []),
  Surah('Al-An\'am', 'الأنعام', 'The Cattle', 165, []),
  Surah('Al-A\'raf', 'الأعراف', 'The Heights', 206, []),
  Surah('Al-Anfal', 'الأنفال', 'The Spoils of War', 75, []),
  Surah('At-Tawbah', 'التوبة', 'The Repentance', 129, []),
  Surah('Yunus', 'يونس', 'Jonah', 109, []),
  Surah('Hud', 'هود', 'Hud', 123, []),
  Surah('Yusuf', 'يوسف', 'Joseph', 111, []),
  Surah('Ar-Ra\'d', 'الرعد', 'The Thunder', 43, []),
  Surah('Ibrahim', 'إبراهيم', 'Abraham', 52, []),
  Surah('Al-Hijr', 'الحجر', 'The Rocky Tract', 99, []),
  Surah('An-Nahl', 'النحل', 'The Bee', 128, []),
  Surah('Al-Isra', 'الإسراء', 'The Night Journey', 111, []),
  Surah('Al-Kahf', 'الكهف', 'The Cave', 110, []),
  Surah('Maryam', 'مريم', 'Mary', 98, []),
  Surah('Ta-Ha', 'طه', 'Ta-Ha', 135, []),
  Surah('Al-Anbiya', 'الأنبياء', 'The Prophets', 112, []),
  Surah('Al-Hajj', 'الحج', 'The Pilgrimage', 78, []),
  Surah('Al-Mu\'minun', 'المؤمنون', 'The Believers', 118, []),
  Surah('An-Nur', 'النور', 'The Light', 64, []),
  Surah('Al-Furqan', 'الفرقآن', 'The Criterion', 77, []),
  Surah('Ash-Shu\'ara', 'الشعراء', 'The Poets', 227, []),
  Surah('An-Naml', 'النمل', 'The Ant', 93, []),
  Surah('Al-Qasas', 'القصص', 'The Stories', 88, []),
  Surah('Al-Ankabut', 'العنكبوت', 'The Spider', 69, []),
  Surah('Ar-Rum', 'الروم', 'The Romans', 60, []),
  Surah('Luqman', 'لقمان', 'Luqman', 34, []),
  Surah('As-Sajdah', 'السجدة', 'The Prostration', 30, []),
  Surah('Al-Ahzab', 'الأحزاب', 'The Confederates', 73, []),
  Surah('Saba', 'سبأ', 'Sheba', 54, []),
  Surah('Fatir', 'فاطر', 'The Creator', 45, []),
  Surah('Ya-Sin', 'يس', 'Ya-Sin', 83, []),
  Surah('As-Saffat', 'الصافات', 'Those Ranged in Ranks', 182, []),
  Surah('Sad', 'ص', 'Sad', 88, []),
  Surah('Az-Zumar', 'الزمر', 'The Groups', 75, []),
  Surah('Ghafir', 'غافر', 'The Forgiver', 85, []),
  Surah('Fussilat', 'فصلت', 'Explained in Detail', 54, []),
  Surah('Ash-Shura', 'الشورى', 'The Consultation', 53, []),
  Surah('Az-Zukhruf', 'الزخرف', 'The Ornaments of Gold', 89, []),
  Surah('Ad-Dukhan', 'الدخان', 'The Smoke', 59, []),
  Surah('Al-Jathiyah', 'الجاثية', 'The Kneeling', 37, []),
  Surah('Al-Ahqaf', 'الأحقاف', 'The Wind-Curved Sandhills', 35, []),
  Surah('Muhammad', 'محمد', 'Muhammad', 38, []),
  Surah('Al-Fath', 'الفتح', 'The Victory', 29, []),
  Surah('Al-Hujurat', 'الحجرات', 'The Private Apartments', 18, []),
  Surah('Qaf', 'ق', 'Qaf', 45, []),
  Surah('Ad-Dhariyat', 'الذاريات', 'The Winnowing Winds', 60, []),
  Surah('At-Tur', 'الطور', 'The Mount', 49, []),
  Surah('An-Najm', 'النجم', 'The Star', 62, []),
  Surah('Al-Qamar', 'القمر', 'The Moon', 55, []),
  Surah('Ar-Rahman', 'الرحمن', 'The Most Gracious', 78, []),
  Surah('Al-Waqi\'ah', 'الواقعة', 'The Inevitable', 96, []),
  Surah('Al-Hadid', 'الحديد', 'The Iron', 29, []),
  Surah('Al-Mujadilah', 'المجادلة', 'The Pleading Woman', 22, []),
  Surah('Al-Hashr', 'الحشر', 'The Gathering', 24, []),
  Surah('Al-Mumtahanah', 'المؤمنة', 'The Tested Woman', 13, []),
  Surah('As-Saff', 'الصف', 'The Ranks', 14, []),
  Surah('Al-Jumu\'ah', 'الجمعة', 'Friday', 11, []),
  Surah('Al-Munafiqun', 'المنافقون', 'The Hypocrites', 11, []),
  Surah('At-Taghabun', 'التغابن', 'The Mutual Disillusion', 18, []),
  Surah('At-Talaq', 'الطلاق', 'The Divorce', 12, []),
  Surah('At-Tahrim', 'التحريم', 'The Prohibition', 12, []),
  Surah('Al-Mulk', 'الملك', 'The Sovereignty', 30, []),
  Surah('Al-Qalam', 'القلم', 'The Pen', 52, []),
  Surah('Al-Haqqah', 'الحاقة', 'The Reality', 52, []),
  Surah('Al-Ma\'arij', 'المعارج', 'The Ascending Stairways', 44, []),
  Surah('Nuh', 'نوح', 'Noah', 28, []),
  Surah('Al-Jinn', 'الجن', 'The Jinn', 28, []),
  Surah('Al-Muzzammil', 'المزمل', 'The Enshrouded', 20, []),
  Surah('Al-Muddaththir', 'المدثر', 'The Cloaked One', 56, []),
  Surah('Al-Qiyamah', 'القيامة', 'The Resurrection', 40, []),
  Surah('Al-Insan', 'الإنسان', 'The Man', 31, []),
  Surah('Al-Mursalat', 'المرسلات', 'The Emissaries', 50, []),
  Surah('An-Naba', 'النبأ', 'The Announcement', 40, []),
  Surah('An-Nazi\'at', 'النازعات', 'Those Who Drag Forth', 46, []),
  Surah('\'Abasa', 'عبس', 'He Frowned', 42, []),
  Surah('At-Takwir', 'التكوير', 'The Overthrowing', 29, []),
  Surah('Al-Infitar', 'الإنفطار', 'The Cleaving', 19, []),
  Surah('Al-Mutaffifin', 'المطففين', 'The Defrauding', 36, []),
  Surah('Al-Inshiqaq', 'الانشقاق', 'The Splitting Open', 25, []),
  Surah('Al-Buruj', 'البروج', 'The Constellations', 22, []),
  Surah('At-Tariq', 'الطارق', 'The Morning Star', 17, []),
  Surah('Al-A\'la', 'الأعلى', 'The Most High', 19, []),
  Surah('Al-Ghashiyah', 'الغاشية', 'The Overwhelming', 26, []),
  Surah('Al-Fajr', 'الفجر', 'The Dawn', 30, []),
  Surah('Al-Balad', 'البلد', 'The City', 20, []),
  Surah('Ash-Shums', 'الشمس', 'The Sun', 15, []),
  Surah('Al-Layl', 'الليل', 'The Night', 21, []),
  Surah('Ad-Duha', 'الضحى', 'The Morning Hours', 11, []),
  Surah('Ash-Sharh', 'الشرح', 'The Relief', 8, []),
  Surah('At-Tin', 'التين', 'The Fig', 8, []),
  Surah('Al-\'Alaq', 'العلق', 'The Clot', 19, []),
  Surah('Al-Qadr', 'القدر', 'The Power', 5, []),
  Surah('Al-Bayyinah', 'البينة', 'The Clear Proof', 8, []),
  Surah('Az-Zalzalah', 'الزلزلة', 'The Earthquake', 8, []),
  Surah('Al-\'Adiyat', 'العاديات', 'The Courser', 11, []),
  Surah('Al-Qari\'ah', 'القارعة', 'The Calamity', 11, []),
  Surah('At-Takathur', 'التكاثر', 'The Rivalry in Worldly Increase', 8, []),
  Surah('Al-\'Asr', 'العصر', 'The Declining Day', 3, []),
  Surah('Al-Humazah', 'الهمزة', 'The Traducer', 9, []),
  Surah('Al-Fil', 'الفيل', 'The Elephant', 5, []),
  Surah('Quraysh', 'قريش', 'Quraysh', 4, []),
  Surah('Al-Ma\'un', 'الماعون', 'The Small Kindness', 7, []),
  Surah('Al-Kawthar', 'الكوثر', 'The Abundance', 3, []),
  Surah('Al-Kafirun', 'الكافرون', 'The Disbelievers', 6, []),
  Surah('An-Nasr', 'النصر', 'The Divine Support', 3, []),
  Surah('Al-Masad', 'المسد', 'The Palm Fiber', 5, []),
  Surah('Al-Ikhlas', 'الإخلاص', 'The Sincerity', 4, [
    Verse('قُلْ هُوَ اللَّهُ أَحَدٌ', 'Say, "He is Allah, [who is] One,', 1),
    Verse('اللَّهُ الصَّمَدُ', 'Allah, the Eternal Refuge.', 2),
    Verse('لَمْ يَلِدْ وَلَمْ يُولَدْ', 'He neither begets nor is born,', 3),
    Verse('وَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
        'Nor is there to Him any equivalent."', 4),
  ]),
  Surah('Al-Falaq', 'الفلق', 'The Daybreak', 5, [
    Verse('قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
        'Say, "I seek refuge in the Lord of daybreak', 1),
    Verse('مِن شَرِّ مَا خَلَقَ', 'From the evil of that which He created', 2),
  ]),
  Surah('An-Naas', 'الناس', 'Mankind', 6, [
    Verse('قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
        'Say, "I seek refuge in the Lord of mankind,', 1),
    Verse('مَلِكِ النَّاسِ', 'The Sovereign of mankind,', 2),
  ]),
];
