import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';

class ZakatResultPage extends StatelessWidget {
  final double totalAssets;
  final double liabilities;
  final double netWealth;
  final String nisabType;

  const ZakatResultPage({
    super.key,
    required this.totalAssets,
    required this.liabilities,
    required this.netWealth,
    required this.nisabType,
  });

  double get zakatDue => netWealth * 0.025;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: const AppTopBar(
        title: 'Zakat Calculation',
        location: 'Zakat Hub',
        isMainScreen: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildResultHeader(),
            const SizedBox(height: 32),
            _buildChartAndBreakdown(),
            const SizedBox(height: 32),
            _buildRecipientsSection(),
            const SizedBox(height: 32),
            _buildActionButtons(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    return BentoCard(
      padding: const EdgeInsets.all(32),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Zakat Obligation',
            style: AppTypography.label.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${zakatDue.toStringAsFixed(2)}',
            style: AppTypography.display.copyWith(
              fontSize: 48,
              color: AppColors.primary,
              shadows: [
                Shadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'May Allah accept your purification of wealth and grant you barakah.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartAndBreakdown() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildBreakdownDetails(),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: _buildZakatRingChart(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdownDetails() {
    return Column(
      children: [
        _buildBreakdownItem('Total Assets', '₹${totalAssets.toStringAsFixed(2)}', Icons.account_balance_rounded),
        const SizedBox(height: 12),
        _buildBreakdownItem('Liabilities', '-₹${liabilities.toStringAsFixed(2)}', Icons.money_off_rounded, isNegative: true),
        const SizedBox(height: 12),
        _buildBreakdownItem('Net Wealth', '₹${netWealth.toStringAsFixed(2)}', Icons.wallet_rounded, isBold: true),
      ],
    );
  }

  Widget _buildBreakdownItem(String label, String value, IconData icon, {bool isNegative = false, bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppShapes.lgRadius,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isNegative ? AppColors.error : AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTypography.label.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7))),
          ),
          Text(
            value,
            style: AppTypography.title.copyWith(
              fontSize: 14,
              color: isNegative ? AppColors.error : AppColors.onSurface,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZakatRingChart() {
    return Column(
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: 0.025,
                    strokeWidth: 8,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
              Center(
                child: Text(
                  '2.5%',
                  style: AppTypography.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text('Zakat Portion', style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildRecipientsSection() {
    return BentoCard(
      padding: const EdgeInsets.all(24),
      color: AppColors.secondary.withValues(alpha: 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_rounded, color: AppColors.secondary, size: 20),
              const SizedBox(width: 12),
              Text(
                'WHO CAN RECEIVE ZAKAT?',
                style: AppTypography.label.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Zakat refers to eight categories of recipients mentioned in Quran 9:60:',
            style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          _buildRecipientList(),
          const SizedBox(height: 20),
          _buildInfoCard('"Alms are for the poor and the needy, and those employed to administer the (funds)..." - Surah At-Tawbah (9:60)'),
        ],
      ),
    );
  }

  Widget _buildRecipientList() {
    final recipients = ['The Poor', 'The Needy', 'Zakat Administrators', 'New Muslims', 'To Free Slaves', 'Those in Debt', 'In the Cause of Allah', 'The Wayfarer'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: recipients.map((r) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.1)),
        ),
        child: Text(r, style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant)),
      )).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.fridayEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: AppColors.fridayEmerald.withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payment_rounded),
                const SizedBox(width: 12),
                Text('Pay Zakat Now', style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSecondaryBtn(Icons.file_download_outlined, 'Download PDF'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSecondaryBtn(Icons.save_rounded, 'Save Record'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryBtn(IconData icon, String label) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      color: AppColors.secondary.withValues(alpha: 0.02),
      child: Text(
        text,
        style: AppTypography.body.copyWith(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          fontSize: 10,
          fontStyle: FontStyle.italic,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
