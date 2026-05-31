import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../design_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/settings/providers/location_providers.dart';
import '../../features/settings/providers/settings_providers.dart';
import '../constants/app_svgs.dart';

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
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
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
  final bool isMainScreen;
  final String title;
  final String location;
  final IconData? backIcon;
  final Widget? logo;
  final VoidCallback? onBackCallback;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onProfilePressed;
  final String? profileImageUrl;
  final bool showLogo;
  final bool showSettings;
  final bool showProfile;
  final bool showSearch;
  final VoidCallback? onSearchPressed;
  final List<Widget>? actions;

  const AppTopBar({
    super.key,
    required this.isMainScreen,
    this.title = '',
    this.location = '',
    this.backIcon,
    this.logo,
    this.onBackCallback,
    this.onSettingsPressed,
    this.onProfilePressed,
    this.profileImageUrl,
    this.showLogo = true,
    this.showSettings = true,
    this.showProfile = true,
    this.showSearch = false,
    this.onSearchPressed,
    this.actions,
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
              // Left Section: Logo or Back Button + Title
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMainScreen) ...[
                    IconButton(
                      onPressed: onBackCallback ??
                          () => Navigator.maybePop(context),
                      icon: Icon(backIcon ?? Icons.arrow_back_rounded,
                          color: AppColors.primary, size: 24),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    if (title.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Text(
                        title.toUpperCase(),
                        style: AppTypography.label.copyWith(
                          color: AppColors.primary,
                          fontSize: 12,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ] else if (showLogo) ...[
                    // Logo for Main Screens
                    logo ??
                        SvgPicture.string(
                          AppSvgs.logo,
                          width: 36,
                          height: 36,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                  ],
                ],
              ),

              // Right Section: Settings & Profile
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showSearch && onSearchPressed != null)
                    IconButton(
                      onPressed: onSearchPressed,
                      icon: const Icon(Icons.search_rounded,
                          size: 22, color: AppColors.primary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (showSearch && onSearchPressed != null)
                    const SizedBox(width: 12),
                  if (showSettings && onSettingsPressed != null)
                    IconButton(
                      onPressed: onSettingsPressed,
                      icon: const Icon(Icons.settings_outlined,
                          size: 22, color: AppColors.primary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (isMainScreen && showProfile && onProfilePressed != null) ...[
                    const SizedBox(width: 12),
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
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: profileImageUrl ??
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBTsguL1thXHygl49n-buglmiegAxbwbxDG_0bz8DyMlY4B9PpbOsKMGjNK9LK1xRQeDx8dUwdqiVdvRz_FYFD5Uqqk2-bY4xdF1eQf9RqHESqq4ypt0k7zaDjDKLW0ELh8RVEnj-u2McOpnuf_39Nx27EZlDnizOq3GYfaQ45eQibevgJ3MnbdMjy0DpTxF_Hrc-tke3MtJ981TVt7wVc1CzSGJ70wPDhNo111GDqA5JnVPqhTyUjwaaGOpXZbKdmE3YxkoveBb4Y',
                              placeholder: (context, url) => const Center(
                                child: SizedBox(
                                  width: 12,
                                  height: 12,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.person),
                              fit: BoxFit.cover,
                              width: 36,
                              height: 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (actions != null) ...actions!,
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
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding > 0 ? bottomPadding : 12),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceBright.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: AppColors.surfaceBright.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavItem(Icons.home_filled, 'Home', 0),
                      _buildNavItem(Icons.mosque_rounded, 'Deen', 1),
                      _buildNavItem(Icons.explore_rounded, 'Qibla', 2),
                      _buildNavItem(Icons.group_rounded, 'Community', 3),
                      _buildNavItem(Icons.hub_rounded, 'Circle', 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = widget.navigationShell.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              padding: EdgeInsets.all(isActive ? 10 : 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isActive ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
                    blurRadius: isActive ? 12 : 0,
                    offset: isActive ? const Offset(0, 4) : Offset.zero,
                  )
                ],
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isActive ? 1.0 : 0.0,
              child: Text(
                label,
                style: AppTypography.label.copyWith(
                  color: AppColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
