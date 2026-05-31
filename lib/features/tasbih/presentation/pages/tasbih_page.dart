import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../widgets/tasbih_dashboard.dart';
import '../widgets/dhikr_carousel.dart';
import '../widgets/counter_with_actions.dart';
import '../widgets/goal_management.dart';
import '../widgets/dhikr_info_card.dart';
import './tasbih_settings_page.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/services_provider.dart';

class TasbihPage extends ConsumerStatefulWidget {
  const TasbihPage({super.key});

  @override
  ConsumerState<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends ConsumerState<TasbihPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  final TextEditingController _customGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Initialize service
    Future.microtask(() => ref.read(tasbihServiceProvider).initialize());
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _customGoalController.dispose();
    super.dispose();
  }

  void _increment() {
    ref.read(tasbihServiceProvider).increment();
    _rippleController.forward(from: 0.0);
  }

  void _reset() {
    ref.read(tasbihServiceProvider).resetSession();
  }

  void _setGoal(int goal) {
    ref.read(tasbihServiceProvider).setGoal(goal);
    _customGoalController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(tasbihServiceProvider);

    if (!service.isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        title: 'Tasbih',
        isMainScreen: false,
        location: 'Tasbih',
        onSettingsPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TasbihSettingsPage()),
        ),
        onProfilePressed: () => context.push('/profile'),
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
              // Dhikr Horizontal Selector
              DhikrCarousel(service: service),

              const SizedBox(height: 40),

              // Dynamic Counter with integrated Reset
              CounterWithActions(
                service: service,
                pulseAnimation: _rippleController,
                onIncrement: _increment,
                onReset: _reset,
              ),

              const SizedBox(height: 40),

              // Goal Management
              GoalManagement(
                service: service,
                customGoalController: _customGoalController,
                onSetGoal: _setGoal,
              ),

              const SizedBox(height: 32),

              // New Insights Dashboard
              TasbihDashboard(service: service),

              const SizedBox(height: 32),

              // Descriptive Info Card
              DhikrInfoCard(service: service),
            ],
          ),
        ),
      ),
    );
  }
}
