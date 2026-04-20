class Dhikr {
  final String arabic;
  final String transliteration;
  final String translation;
  final int defaultGoal;
  final String? benefit;
  final String? hadith;

  const Dhikr({
    required this.arabic,
    required this.transliteration,
    required this.translation,
    this.defaultGoal = 33,
    this.benefit,
    this.hadith,
  });

  static List<Dhikr> get defaults => [
        const Dhikr(
          arabic: 'سُبْحَانَ ٱللَّٰهِ',
          transliteration: 'SubhanAllah',
          translation: 'Glory be to Allah',
          defaultGoal: 33,
          benefit: 'Light on the tongue, heavy in the scales, and beloved to the Most Merciful.',
          hadith: '"Two words are light on the tongue, heavy in the balance, and beloved to the Most Merciful: Subhan-Allah wa bihamdihi, Subhan-Allahil-Azim." (Bukhari)',
        ),
        const Dhikr(
          arabic: 'ٱلْحَمْدُ لِلَّٰهِ',
          transliteration: 'Alhamdulillah',
          translation: 'Praise be to Allah',
          defaultGoal: 33,
          benefit: 'Fills the scales with reward and is described as the best form of supplication.',
          hadith: '"The best of remembrance is \'La ilaha illallah\' and the best of supplication is \'Al-hamdu lillah\'." (Tirmidhi)',
        ),
        const Dhikr(
          arabic: 'ٱللَّٰهُ أَكْبَرُ',
          transliteration: 'Allahu Akbar',
          translation: 'Allah is Greatest',
          defaultGoal: 34,
          benefit: 'Declares the absolute superiority of Allah; more precious than everything under the sun.',
          hadith: '"To say \'Subhan-Allah, Alhamdulillah, La ilaha illallah, and Allahu Akbar\' is dearer to me than everything over which the sun rises." (Muslim)',
        ),
        const Dhikr(
          arabic: 'لَآ إِلَٰهَ إِلَّا ٱللَّٰهُ',
          transliteration: 'La ilaha illallah',
          translation: 'There is no god but Allah',
          defaultGoal: 100,
          benefit: 'The key to Paradise and the weightiest declaration a believer can make.',
          hadith: '"The best of Dhikr is \'La ilaha illallah\'." (Tirmidhi)',
        ),
        const Dhikr(
          arabic: 'أَسْتَغْفِرُ ٱللَّٰهَ',
          transliteration: 'Astaghfirullah',
          translation: 'I seek forgiveness from Allah',
          defaultGoal: 100,
          benefit: 'Provides relief from every anxiety, distress, and opens doors of unexpected sustenance.',
          hadith: '"If anyone constantly seeks pardon, Allah will appoint for him a way out of every distress and a relief from every anxiety." (Abu Dawud)',
        ),
      ];
}
