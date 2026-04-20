import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../data/services/tasbih_service.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../widgets/tasbih_dashboard.dart';
import '../widgets/dhikr_carousel.dart';
import '../widgets/counter_with_actions.dart';
import '../widgets/goal_management.dart';
import '../widgets/dhikr_info_card.dart';
import './tasbih_settings_page.dart';

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


    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        title: 'Tasbih',
        isMainScreen: true,
        location: 'Tasbih',
        onSettingsPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TasbihSettingsPage()),
        ),
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
              // Dhikr Horizontal Selector
              DhikrCarousel(service: _service),

              const SizedBox(height: 40),

              // Dynamic Counter with integrated Reset
              CounterWithActions(
                service: _service,
                pulseAnimation: _rippleController,
                onIncrement: _increment,
                onReset: _reset,
              ),

              const SizedBox(height: 40),

              // Goal Management
              GoalManagement(
                service: _service,
                customGoalController: _customGoalController,
                onSetGoal: _setGoal,
              ),

              const SizedBox(height: 32),

              // New Insights Dashboard
              TasbihDashboard(service: _service),

              const SizedBox(height: 32),

              // Descriptive Info Card
              DhikrInfoCard(service: _service),
            ],
          ),
        ),
      ),
    );
  }
}
