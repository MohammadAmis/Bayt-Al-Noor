import 'dart:ui';
import 'package:flutter/material.dart';
import '../design_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../features/settings/providers/location_providers.dart';
import '../../features/settings/providers/settings_providers.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry? padding;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 12,
    this.color,
    this.borderRadius,
    this.border,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? AppShapes.lgRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ??
                AppColors.surfaceContainerLowest.withValues(alpha: 0.7),
            borderRadius: borderRadius ?? AppShapes.lgRadius,
            border: border ??
                Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.2),
                  width: 1,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class BentoCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;

  const BentoCard({
    super.key,
    required this.child,
    this.color,
    this.elevation,
    this.padding,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: gradient == null
            ? (color ?? AppColors.surfaceContainerLowest)
            : null,
        gradient: gradient,
        borderRadius: AppShapes.lgRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String location;
  final bool isMainScreen;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onProfilePressed;
  final IconData? leadingIcon;
  final String? profileImageUrl;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    required this.location,
    this.isMainScreen = false,
    this.onMenuPressed,
    this.onSettingsPressed,
    this.onProfilePressed,
    this.leadingIcon,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Section
              Expanded(
                child: Row(
                  children: [
                    if (!isMainScreen) ...[
                      IconButton(
                        onPressed: onMenuPressed ??
                            () => Navigator.maybePop(context),
                        icon: Icon(leadingIcon ?? Icons.arrow_back_rounded,
                            color: AppColors.primary, size: 24),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                    ],
                    
                    // Kufic Logo Emblem
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'بيت النور',
                          style: AppTypography.headline.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Context (Location OR Screen Name)
                    Flexible(
                      flex: 2,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 1,
                            height: 16,
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isMainScreen) ...[
                                  const Icon(Icons.location_on_rounded,
                                      size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                ],
                                Flexible(
                                  child: Text(
                                    (isMainScreen ? location : title).toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.label.copyWith(
                                      color: AppColors.primary.withValues(alpha: 0.6),
                                      fontSize: 10,
                                      letterSpacing: 1.1,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Right Section
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onSettingsPressed != null)
                    IconButton(
                      onPressed: onSettingsPressed,
                      icon: const Icon(Icons.settings_outlined,
                      size: 22, 
                      color: AppColors.primary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(width: 12),
                  if (isMainScreen && onProfilePressed != null) ...[
                    GestureDetector(
                      onTap: onProfilePressed,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              width: 1),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(profileImageUrl ??
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBTsguL1thXHygl49n-buglmiegAxbwbxDG_0bz8DyMlY4B9PpbOsKMGjNK9LK1xRQeDx8dUwdqiVdvRz_FYFD5Uqqk2-bY4xdF1eQf9RqHESqq4ypt0k7zaDjDKLW0ELh8RVEnj-u2McOpnuf_39Nx27EZlDnizOq3GYfaQ45eQibevgJ3MnbdMjy0DpTxF_Hrc-tke3MtJ981TVt7wVc1CzSGJ70wPDhNo111GDqA5JnVPqhTyUjwaaGOpXZbKdmE3YxkoveBb4Y'),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

class MainNavigationContainer extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationContainer({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<MainNavigationContainer> createState() =>
      _MainNavigationContainerState();
}

class _MainNavigationContainerState
    extends ConsumerState<MainNavigationContainer> {
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
        if (result == LocationPermission.whileInUse ||
            result == LocationPermission.always) {
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
      body: widget.navigationShell,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 24, top: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceBright.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.mosque, 'Deen', 1),
            _buildNavItem(Icons.explore, 'Qibla', 2),
            _buildNavItem(Icons.add_box, 'Create', 3),
            _buildNavItem(Icons.video_library, 'Shorts', 4),
            _buildNavItem(Icons.hub_outlined, 'Circle', 5),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = widget.navigationShell.currentIndex == index;

    return GestureDetector(
      onTap: () => widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      ),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        padding:
            EdgeInsets.symmetric(horizontal: isActive ? 16 : 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: AppShapes.fullRadius,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? Colors.white
                  : AppColors.primary.withValues(alpha: 0.5),
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
