import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../settings/providers/settings_providers.dart';
import '../../../settings/providers/location_providers.dart';
import 'home_page.dart';
import '../../../qibla/presentation/pages/qibla_page.dart';
import '../../../tasbih/presentation/pages/tasbih_page.dart';
import '../../../deen/presentation/pages/deen_hub_page.dart';
import '../../../community/presentation/pages/community_page.dart';

class MainNavigationContainer extends ConsumerStatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  ConsumerState<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends ConsumerState<MainNavigationContainer> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(key: PageStorageKey('home')),
    const DeenHubPage(key: PageStorageKey('deen')),
    const QiblaPage(key: PageStorageKey('qibla')),
    const TasbihPage(key: PageStorageKey('tasbih')),
    const CommunityPage(key: PageStorageKey('community')),
  ];

  @override
  void initState() {
    super.initState();
    // Prompt for location permission on first entry if auto-detect is enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationPermissions();
    });
  }

  Future<void> _checkLocationPermissions() async {
    final useAuto = ref.read(useAutoLocationProvider);
    if (!useAuto) return;

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request permission
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.whileInUse || result == LocationPermission.always) {
          // Refresh location if granted
          ref.read(locationManagerProvider.notifier).refresh();
        }
      }
    } catch (e) {
      debugPrint('Error checking location permissions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 24, top: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceBright.withValues(alpha:0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GlassContainer(
        blur: 20,
        color: Colors.transparent,
        border: Border.all(color: Colors.transparent),
        borderRadius: AppShapes.fullRadius,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.auto_awesome_motion, 'Home', 0),
            _buildNavItem(Icons.mosque, 'Deen', 1),
            _buildNavItem(Icons.explore_outlined, 'Qibla', 2),
            _buildNavItem(Icons.fingerprint, 'Tasbih', 3),
            _buildNavItem(Icons.hub_outlined, 'Circle', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12, 
          vertical: 10
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: AppShapes.fullRadius,
          boxShadow: isActive ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha:0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isActive ? Colors.white : AppColors.primary.withValues(alpha:0.5), 
              size: 20,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: AppTypography.label.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
