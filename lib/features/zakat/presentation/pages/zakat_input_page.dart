import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import 'zakat_result_page.dart';

class ZakatInputPage extends StatefulWidget {
  const ZakatInputPage({super.key});

  @override
  State<ZakatInputPage> createState() => _ZakatInputPageState();
}

class _ZakatInputPageState extends State<ZakatInputPage> {
  int _currentStep = 0;
  
  // Logic states
  final Map<String, TextEditingController> _controllers = {
    'Cash': TextEditingController(),
    'Gold': TextEditingController(),
    'Silver': TextEditingController(),
    'Investments': TextEditingController(),
    'Business': TextEditingController(),
    'Debts': TextEditingController(),
  };

  bool _isInvestmentTrading = true;
  String _nisabType = 'Silver';
  
  final Map<int, bool> _expandedSections = {0: true, 1: false, 2: false, 3: false};

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _navigateToResult();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _navigateToResult() {
    // Basic logic mapping
    double parse(String t) => double.tryParse(t) ?? 0.0;
    
    double cash = parse(_controllers['Cash']!.text);
    double gold = parse(_controllers['Gold']!.text);
    double silver = parse(_controllers['Silver']!.text);
    double business = parse(_controllers['Business']!.text);
    double debts = parse(_controllers['Debts']!.text);
    
    // Investment Logic: 100% for Trading, 40% for Long-term
    double rawInvest = parse(_controllers['Investments']!.text);
    double zakatableInvest = _isInvestmentTrading ? rawInvest : rawInvest * 0.4;
    
    double totalAssets = cash + gold + silver + business + zakatableInvest;
    double netWealth = totalAssets - debts;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZakatResultPage(
          totalAssets: totalAssets,
          liabilities: debts,
          netWealth: netWealth,
          nisabType: _nisabType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: const AppTopBar(
        title: 'Wealth Declaration',
        location: 'Zakat Hub',
        isMainScreen: false,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: _buildCurrentStepView(),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: Colors.white,
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCurrent 
                      ? Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      : Icon(isActive ? Icons.check : Icons.circle, size: 14, color: isActive ? Colors.white : AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
                  ),
                ),
                if (index < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: index < _currentStep ? AppColors.primary : AppColors.surfaceContainerHigh,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0: return _buildAssetsStep();
      case 1: return _buildLiabilitiesStep();
      case 2: return _buildThresholdStep();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildAssetsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Step 1: Declare Assets', 'Include all wealth that has been in your possession for one lunar year.'),
        const SizedBox(height: 24),
        _buildAccordionSection(0, 'Cash & Savings', Icons.account_balance_wallet_rounded, 
          [_buildInputField('Cash', 'Bank balance & cash on hand', Icons.payments_rounded)]),
        const SizedBox(height: 16),
        _buildAccordionSection(1, 'Gold & Silver', Icons.tonality_rounded, [
          _buildInputField('Gold', 'Value of gold jewelry/coins', Icons.auto_awesome_rounded),
          _buildInputField('Silver', 'Value of silver assets', Icons.blur_on_rounded),
        ]),
        const SizedBox(height: 16),
        _buildAccordionSection(2, 'Investments', Icons.trending_up_rounded, [
          _buildInvestmentToggle(),
          _buildInputField('Investments', 'Stocks, shares, bonds', Icons.show_chart_rounded),
        ]),
        const SizedBox(height: 16),
        _buildAccordionSection(3, 'Business Assets', Icons.storefront_rounded, 
          [_buildInputField('Business', 'Stock for trade, business cash', Icons.business_center_rounded)]),
      ],
    );
  }

  Widget _buildLiabilitiesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Step 2: Liabilities', 'Deduct immediate debts and short-term liabilities.'),
        const SizedBox(height: 24),
        _buildInputField('Debts', 'Loans, unpaid bills, installments', Icons.money_off_rounded, isDebt: true),
        const SizedBox(height: 16),
        _buildInfoCard('Only deduct debts that are due now or within the next lunar month. Do not deduct the full value of a long-term mortgage.'),
      ],
    );
  }

  Widget _buildThresholdStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Step 3: Threshold', 'Select the Nisab threshold type.'),
        const SizedBox(height: 24),
        _buildNisabSelector(),
        const SizedBox(height: 32),
        _buildInfoCard('Silver Nisab is recommended as it benefits the poor more, while Gold Nisab is often used for higher wealth stability.'),
      ],
    );
  }

  Widget _buildStepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.headline.copyWith(fontSize: 24, color: AppColors.primary)),
        const SizedBox(height: 8),
        Text(subtitle, style: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 13)),
      ],
    );
  }

  Widget _buildAccordionSection(int id, String title, IconData icon, List<Widget> children) {
    bool isExpanded = _expandedSections[id] ?? false;
    return BentoCard(
      padding: EdgeInsets.zero,
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _expandedSections[id] = !isExpanded),
            leading: Icon(icon, color: AppColors.primary),
            title: Text(title, style: AppTypography.title.copyWith(fontSize: 15)),
            trailing: Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(String key, String hint, IconData icon, {bool isDebt = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: _controllers[key],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18, color: isDebt ? AppColors.error : AppColors.primary),
          hintText: hint,
          labelText: key,
          labelStyle: AppTypography.label.copyWith(color: isDebt ? AppColors.error : AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
          filled: true,
          fillColor: AppColors.bgLight.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildInvestmentToggle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildToggleItem('Trading', _isInvestmentTrading, () => setState(() => _isInvestmentTrading = true)),
          _buildToggleItem('Long-term', !_isInvestmentTrading, () => setState(() => _isInvestmentTrading = false)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8), boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null),
          child: Center(child: Text(label, style: AppTypography.label.copyWith(color: active ? AppColors.primary : AppColors.onSurfaceVariant, fontWeight: active ? FontWeight.bold : FontWeight.normal))),
        ),
      ),
    );
  }

  Widget _buildNisabSelector() {
    return Row(
      children: [
        _buildNisabBtn('Silver', Icons.blur_on_rounded),
        const SizedBox(width: 16),
        _buildNisabBtn('Gold', Icons.auto_awesome_rounded),
      ],
    );
  }

  Widget _buildNisabBtn(String type, IconData icon) {
    bool active = _nisabType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _nisabType = type),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: active ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
            borderRadius: AppShapes.lgRadius,
            border: Border.all(color: active ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 32),
              const SizedBox(height: 12),
              Text(type, style: AppTypography.title.copyWith(color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      color: AppColors.secondary.withValues(alpha: 0.05),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.secondary, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTypography.label.copyWith(color: AppColors.onSurfaceVariant, fontSize: 11, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, -4))]),
      child: Row(
        children: [
          if (_currentStep > 0)
            IconButton(onPressed: _previousStep, icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(_currentStep == 2 ? 'Calculate Zakat' : 'Continue', style: AppTypography.title.copyWith(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
