import 'dart:ui';
import 'package:flutter/material.dart';
import '../design_tokens.dart';

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
                    // Image.asset(
                    //   'assets/logo_2.png',
                    //   height: 32,
                    //   fit: BoxFit.contain,
                    // ),
                    Text(
                      'بيت النور',
                      style: AppTypography.headline.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Context (Location OR Screen Name)
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 1,
                            height: 16,
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                if (isMainScreen) ...[
                                  const Icon(Icons.location_on_rounded,
                                      size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                ],
                                Expanded(
                                  child: Text(
                                    (isMainScreen ? location : title).toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.label.copyWith(
                                      color: AppColors.primary.withValues(alpha: 0.6),
                                      fontSize: 11,
                                      letterSpacing: 1.2,
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
                          size: 24, color: AppColors.primary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
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
                          radius: 20,
                          backgroundImage: NetworkImage(profileImageUrl ??
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBTsguL1thXHygl49n-buglmiegAxbwbxDG_0bz8DyMlY4B9PpbOsKMGjNK9LK1xRQeDx8dUwdqiVdvRz_FYFD5Uqqk2-bY4xdF1eQf9RqHESqq4ypt0k7zaDjDKLW0ELh8RVEnj-u2McOpnuf_39Nx27EZlDnizOq3GYfaQ45eQibevgJ3MnbdMjy0DpTxF_Hrc-tke3MtJ981TVt7wVc1CzSGJ70wPDhNo111GDqA5JnVPqhTyUjwaaGOpXZbKdmE3YxkoveBb4Y'),
                        ),
                      ),
                    ),
                    // const SizedBox(width: 8),
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
  Size get preferredSize => const Size.fromHeight(100);
}
