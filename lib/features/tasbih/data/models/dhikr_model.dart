class Dhikr {
  final String arabic;
  final String transliteration;
  final String translation;
  final int defaultGoal;

  const Dhikr({
    required this.arabic,
    required this.transliteration,
    required this.translation,
    this.defaultGoal = 33,
  });

  static List<Dhikr> get defaults => [
        const Dhikr(
          arabic: 'سُبْحَانَ ٱللَّٰهِ',
          transliteration: 'SubhanAllah',
          translation: 'Glory be to Allah',
          defaultGoal: 33,
        ),
        const Dhikr(
          arabic: 'ٱلْحَمْدُ لِلَّٰهِ',
          transliteration: 'Alhamdulillah',
          translation: 'Praise be to Allah',
          defaultGoal: 33,
        ),
        const Dhikr(
          arabic: 'ٱللَّٰهُ أَكْبَرُ',
          transliteration: 'Allahu Akbar',
          translation: 'Allah is Greatest',
          defaultGoal: 34, // Often done 34 to complete 100
        ),
        const Dhikr(
          arabic: 'لَآ إِلَٰهَ إِلَّا ٱللَّٰهُ',
          transliteration: 'La ilaha illallah',
          translation: 'There is no god but Allah',
          defaultGoal: 100,
        ),
        const Dhikr(
          arabic: 'أَسْتَغْفِرُ ٱللَّٰهَ',
          transliteration: 'Astaghfirullah',
          translation: 'I seek forgiveness from Allah',
          defaultGoal: 100,
        ),
      ];
}
