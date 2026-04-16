import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import 'zakat_input_page.dart';
import 'zakat_education_page.dart';

class ZakatCalculatorPage extends StatelessWidget {
  const ZakatCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: const AppTopBar(
        title: 'Zakat Hub',
        location: 'Deen Hub',
        isMainScreen: false,
      ),
      body: Container(
        color: AppColors.bgLight,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Greeting Section
              _buildGreetingSection(),
              const SizedBox(height: 32),
              
              // Nisab Quick-View Card
              _buildNisabCard(),
              const SizedBox(height: 40),
              
              // Main Actions
              _buildMainActions(context),
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            style: AppTypography.display.copyWith(
              fontSize: 32,
              fontFamily: 'Amiri',
              color: AppColors.primary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Assalamu Alaikum',
          style: AppTypography.display.copyWith(
            fontSize: 28,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Purify your wealth through Zakat',
          style: AppTypography.body.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildNisabCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppShapes.xlRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppShapes.xlRadius,
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.blur_on_rounded,
                size: 150,
                color: AppColors.primary.withValues(alpha: 0.03),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.info_outline_rounded, 
                          color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'NISAB STATUS (SILVER)',
                        style: AppTypography.label.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '₹48,250.00',
                    style: AppTypography.display.copyWith(
                      fontSize: 36,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Zakat is due if your total zakatable wealth exceeds this amount for one full lunar year (Hawl).',
                    style: AppTypography.body.copyWith(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActions(BuildContext context) {
    return Column(
      children: [
        _buildActionBtn(
          context,
          'Add Your Wealth',
          'Start your step-by-step calculation',
          Icons.add_chart_rounded,
          AppColors.fridayEmerald,
          true,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ZakatInputPage()),
          ),
        ),
        const SizedBox(height: 16),
        _buildActionBtn(
          context,
          'Calculate Zakat',
          'Quickly check your obligation',
          Icons.calculate_rounded,
          AppColors.primary,
          false,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ZakatInputPage()),
          ),
        ),
        const SizedBox(height: 16),
        _buildActionBtn(
          context,
          'Learn About Zakat',
          'Understand rulings & guidelines',
          Icons.menu_book_rounded,
          AppColors.secondary,
          false,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ZakatEducationPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn(BuildContext context, String title, String subtitle, 
      IconData icon, Color color, bool isPrimary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.white,
          borderRadius: AppShapes.lgRadius,
          border: isPrimary ? null : Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary ? Colors.white.withValues(alpha: 0.1) : color.withValues(alpha: 0.1),
                borderRadius: AppShapes.mdRadius,
              ),
              child: Icon(icon, color: isPrimary ? Colors.white : color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    title,
                    style: AppTypography.title.copyWith(
                      color: isPrimary ? Colors.white : AppColors.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.label.copyWith(
                      color: isPrimary ? Colors.white70 : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isPrimary ? Colors.white54 : AppColors.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
