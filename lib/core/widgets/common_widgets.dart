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
    this.onMenuPressed,
    this.onSettingsPressed,
    this.onProfilePressed,
    this.leadingIcon,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 20,
      borderRadius: BorderRadius.zero,
      color: AppColors.surfaceContainerLow.withValues(alpha: 0.9),
      border: Border(
        bottom: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 84,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Section: Profile Avatar OR Back Button
              SizedBox(
                width: 48,
                child: (onProfilePressed != null && leadingIcon == null)
                    ? GestureDetector(
                        onTap: onProfilePressed,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                width: 1.5),
                          ),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(profileImageUrl ??
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuBTsguL1thXHygl49n-buglmiegAxbwbxDG_0bz8DyMlY4B9PpbOsKMGjNK9LK1xRQeDx8dUwdqiVdvRz_FYFD5Uqqk2-bY4xdF1eQf9RqHESqq4ypt0k7zaDjDKLW0ELh8RVEnj-u2McOpnuf_39Nx27EZlDnizOq3GYfaQ45eQibevgJ3MnbdMjy0DpTxF_Hrc-tke3MtJ981TVt7wVc1CzSGJ70wPDhNo111GDqA5JnVPqhTyUjwaaGOpXZbKdmE3YxkoveBb4Y'),
                          ),
                        ),
                      )
                    : (Navigator.canPop(context) || leadingIcon != null)
                        ? IconButton(
                            onPressed: onMenuPressed ??
                                () => Navigator.maybePop(context),
                            icon: Icon(leadingIcon ?? Icons.arrow_back,
                                color: AppColors.primary),
                          )
                        : const SizedBox.shrink(),
              ),

              // Middle Section: Centered Title & Location
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: title,
                            style: AppTypography.display.copyWith(
                              color: AppColors.primaryContainer,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (subtitle != null)
                            TextSpan(
                              text: ' ($subtitle)',
                              style: const TextStyle(
                                fontFamily: 'Noto Serif',
                                color: AppColors.primaryContainer,
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on,
                            size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          location.toUpperCase(),
                          style: AppTypography.label.copyWith(
                            color: AppColors.primary.withValues(alpha: 0.6),
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right Section: Search & Optional Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onSettingsPressed != null)
                    IconButton(
                      onPressed: onSettingsPressed,
                      icon: const Icon(Icons.settings_outlined,
                          size: 22, color: AppColors.primary),
                    ),
                  if (onSettingsPressed == null &&
                      onProfilePressed != null &&
                      Navigator.canPop(context))
                    // If we are nested, we can still show a small profile button or keep it clean
                    const SizedBox(width: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}
