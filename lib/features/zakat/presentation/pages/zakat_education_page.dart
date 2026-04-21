import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';

class ZakatEducationPage extends StatelessWidget {
  const ZakatEducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: const AppTopBar(
        title: 'Zakat Education',
        location: 'Zakat Hub',
        isMainScreen: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroHeader(),
            const SizedBox(height: 32),
            _buildEducationSection(
              'What is Zakat?',
              'الزكاة',
              'Zakat is one of the Five Pillars of Islam. It is a mandatory religious obligation for Muslims to give 2.5% of their qualifying wealth annually to those in need. The word literally means "purification" and "growth."',
              Icons.menu_book_rounded,
            ),
            _buildEducationSection(
              'Nisab Explained',
              'النصاب',
              'Nisab is the minimum threshold of wealth a Muslim must own before Zakat becomes obligatory. \n\n• Gold: 87.48 grams\n• Silver: 612.36 grams\n\nIf your total zakatable wealth is above this amount, you must pay Zakat.',
              Icons.auto_awesome_rounded,
            ),
            _buildEducationSection(
              'Hawl (1 Year Rule)',
              'الحول',
              'Once your wealth reaches the Nisab, it must remain above that threshold for one full lunar year (approx. 354 days). This period is known as "Hawl."',
              Icons.update_rounded,
            ),
            _buildEducationSection(
              'Zakatable Assets',
              'الأموال الزكوية',
              'Zakat is due on specific types of wealth, including:\n\n• Cash and bank savings\n• Gold and Silver assets\n• Investment portfolios and stocks\n• Business stock for trade\n• Profits from rentals/assets.',
              Icons.account_balance_rounded,
            ),
            _buildEducationSection(
              'Scholar Differences',
              'اختلاف العلماء',
              'There are minor differences in application among schools of thought. For example:\n\n• Hanafi: Zakat is due on all gold and silver jewelry.\n• Shafi\'i & Maliki: Zakat is not due on jewelry used for personal adornment within reasonable limits.',
              Icons.gavel_rounded,
            ),
            const SizedBox(height: 40),
            _buildExternalResources(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Knowledge is the Path',
          style: AppTypography.display.copyWith(fontSize: 28, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          'Explore the essential rulings (Fiqh) of Zakat clarified by experts for a spiritually sound fulfilling life.',
          style: AppTypography.body.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildEducationSection(String title, String arabicTitle, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: BentoCard(
        padding: EdgeInsets.zero,
        color: Colors.white,
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(title, style: AppTypography.title.copyWith(fontSize: 16)),
          subtitle: Text(
            arabicTitle,
            style: const TextStyle(fontFamily: 'Amiri', color: AppColors.primary, fontSize: 16),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Text(
                content,
                style: AppTypography.body.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.7,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExternalResources() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deepen Your Understanding',
          style: AppTypography.title.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        _buildResourceBtn('Study the Fiqh Manual'),
        const SizedBox(height: 12),
        _buildResourceBtn('Consult a Local Imam'),
      ],
    );
  }

  Widget _buildResourceBtn(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppShapes.lgRadius,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.label.copyWith(color: AppColors.onSurface)),
          const Icon(Icons.arrow_right_alt_rounded, color: AppColors.primary),
        ],
      ),
    );
  }
}
