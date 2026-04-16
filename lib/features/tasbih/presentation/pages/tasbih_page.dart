import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../data/services/tasbih_service.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage>
    with SingleTickerProviderStateMixin {
  final TasbihService _service = TasbihService.instance;
  late AnimationController _rippleController;
  final TextEditingController _customGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    // Initialize service and listen for changes
    _service.initialize();
    _service.addListener(_onServiceUpdate);
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    _rippleController.dispose();
    _customGoalController.dispose();
    super.dispose();
  }

  void _increment() {
    _service.increment();
    _rippleController.forward(from: 0.0);
  }

  void _reset() {
    _service.resetSession();
  }

  void _setGoal(int goal) {
    _service.setGoal(goal);
    _customGoalController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (!_service.isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double progress = (_service.sessionCount / _service.sessionGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        title: 'Tasbih',
        isMainScreen: true,
        location: 'Tasbih',
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
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          child: Column(
            children: [

              // Dhikr Selector
              _buildDhikrSelector(),

              const SizedBox(height: 32),

              // Series Mode Toggle
              _buildSeriesModeToggle(),

              const SizedBox(height: 40),

              // Central Counter Section
              _buildCounterSection(progress),

              const SizedBox(height: 48),

              // Goal Management
              _buildGoalManagement(),

              const SizedBox(height: 32),

              // Stats
              _buildStatsGrid(),

              const SizedBox(height: 32),

              // Reset Button
              _buildResetButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDhikrSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT DHIKR',
          style: AppTypography.label.copyWith(
            color: AppColors.secondary,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _service.dhikrs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final dhikr = _service.dhikrs[index];
              final isSelected = _service.selectedDhikrIndex == index;
              return GestureDetector(
                onTap: () => _service.selectDhikr(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.outlineVariant.withValues(alpha:0.1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dhikr.arabic,
                      style: AppTypography.label.copyWith(
                        color: isSelected ? Colors.white : AppColors.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeriesModeToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SERIES MODE',
                    style: AppTypography.label.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Auto-switch every 33 counts',
                    style: AppTypography.body.copyWith(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant.withValues(alpha:0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch.adaptive(
            value: _service.isSeriesMode,
            onChanged: (val) => _service.toggleSeriesMode(val),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterSection(double progress) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Circular Progress Ring
            SizedBox(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: ProgressRingPainter(
                  progress: progress,
                  color: AppColors.secondary,
                  backgroundColor: AppColors.surfaceContainerHighest,
                ),
              ),
            ),

            // Central Tap Button
            GestureDetector(
              onTap: _increment,
              child: AnimatedBuilder(
                animation: _rippleController,
                builder: (context, child) {
                  return Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha:0.08),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Arabic Display
                        Text(
                          _service.selectedDhikr.arabic,
                          style: AppTypography.headline.copyWith(
                            fontSize: 24,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${_service.sessionCount}',
                          style: AppTypography.headline.copyWith(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'OF ${_service.sessionGoal}',
                          style: AppTypography.label.copyWith(
                            color: AppColors.secondary.withValues(alpha:0.6),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Session Goal Summary Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).toInt()}% of goal reached',
                style: AppTypography.label.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Set Session Goal',
              style: AppTypography.title.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'PRESETS',
              style: AppTypography.label.copyWith(
                color: AppColors.secondary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Preset Buttons
        Row(
          children: [
            _buildPresetButton(33),
            const SizedBox(width: 12),
            _buildPresetButton(99),
            const SizedBox(width: 12),
            _buildPresetButton(100),
          ],
        ),

        const SizedBox(height: 24),

        // Custom Goal
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_note, color: AppColors.outlineVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _customGoalController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          _service.setGoal(int.tryParse(val) ?? _service.sessionGoal);
                        }
                      },
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter target number...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                            color: AppColors.outlineVariant, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: AppColors.surface,
                child: Text(
                  'CUSTOM GOAL',
                  style: AppTypography.label.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetButton(int value) {
    bool isSelected = _service.sessionGoal == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setGoal(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha:0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '$value',
              style: AppTypography.headline.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard('LIFETIME', '${(_service.lifetimeTotal / 1000).toStringAsFixed(1)}k'),
        const SizedBox(width: 16),
        _buildStatCard('STREAK', '${_service.streak} Days'),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha:0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.label.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.secondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.display.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: _reset,
        icon: const Icon(Icons.restart_alt),
        label: const Text('RESET SESSION'),
        style: TextButton.styleFrom(
          backgroundColor: AppColors.surfaceContainerHighest,
          foregroundColor: AppColors.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: AppTypography.label.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 12,
          ),
        ).copyWith(
          overlayColor:
              WidgetStateProperty.all(AppColors.error.withValues(alpha:0.1)),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) return AppColors.error;
            return AppColors.onSurface;
          }),
        ),
      ),
    );
  }
}


class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
