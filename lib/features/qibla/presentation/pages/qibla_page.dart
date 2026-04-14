import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        title: 'Bayt Al-Noor',
        subtitle: 'بَيْتُ النُّورِ',
        location: 'London, UK',
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                children: [
                  // Section Header
                  Column(
                    children: [
                      Text(
                        'CELESTIAL ALIGNMENT',
                        style: AppTypography.label.copyWith(
                          color: AppColors.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Qibla Direction',
                        style: AppTypography.headline.copyWith(
                          fontSize: 32,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Compass Container
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Celestial Background Ring (Animated Pulse)
                      const _CelestialPulseRing(),

                      // Analog Dial
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha:0.08),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Border
                            Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha:0.05),
                                  width: 1,
                                ),
                              ),
                            ),

                            // Degree Markings
                            const _CompassMarkings(),

                            // Direction Letters
                            const _DirectionLabels(),

                            // Qibla Arrow (Animated)
                            RotationTransition(
                              turns: _animation
                                  .drive(Tween(begin: 0.0, end: 124 / 360)),
                              child: const _QiblaPointer(),
                            ),

                            // Center Point
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.primary, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha:0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Floating Degree Display
                      Positioned(
                        bottom: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: AppShapes.fullRadius,
                            border: Border.all(
                              color: AppColors.outlineVariant.withValues(alpha:0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha:0.05),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '124° NE',
                                style: AppTypography.headline.copyWith(
                                  fontSize: 24,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'DIRECT PATH',
                                style: AppTypography.label.copyWith(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.outline,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 64),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: AppShapes.xlRadius,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on,
                              color: AppColors.primaryFixed),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'YOUR LOCATION',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.outline,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'London, United Kingdom',
                                style: AppTypography.headline.copyWith(
                                  fontSize: 20,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recalibrate Button
                  GestureDetector(
                    onTap: () {
                      _controller.reset();
                      _controller.forward();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: AppShapes.lgRadius,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.sync,
                              size: 20, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            'RECALIBRATE COMPASS',
                            style: AppTypography.label.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CelestialPulseRing extends StatefulWidget {
  const _CelestialPulseRing();

  @override
  State<_CelestialPulseRing> createState() => _CelestialPulseRingState();
}

class _CelestialPulseRingState extends State<_CelestialPulseRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.1, end: 0.3).animate(_pulseController),
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
    );
  }
}

class _CompassMarkings extends StatelessWidget {
  const _CompassMarkings();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(8, (index) {
        return Transform.rotate(
          angle: index * math.pi / 4,
          child: Divider(
            color: AppColors.outlineVariant.withValues(alpha:0.15),
            thickness: 1,
            indent: 0,
            endIndent: 0,
          ),
        );
      }),
    );
  }
}

class _DirectionLabels extends StatelessWidget {
  const _DirectionLabels();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
            top: 24,
            child: Text('N',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900))),
        Positioned(
            right: 24,
            child: Text('E',
                style: TextStyle(
                    color: AppColors.primary.withValues(alpha:0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w900))),
        Positioned(
            bottom: 24,
            child: Text('S',
                style: TextStyle(
                    color: AppColors.primary.withValues(alpha:0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w900))),
        Positioned(
            left: 24,
            child: Text('W',
                style: TextStyle(
                    color: AppColors.primary.withValues(alpha:0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w900))),
      ],
    );
  }
}

class _QiblaPointer extends StatelessWidget {
  const _QiblaPointer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Main Arrow
        SizedBox(
          width: 20,
          height: 200,
          child: Column(
            children: [
              // Arrow Head
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha:0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                transform: Matrix4.rotationZ(math.pi / 4),
              ),
              // Shaft
              Expanded(
                child: Container(
                  width: 2,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary,
                        AppColors.secondary.withValues(alpha:0)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Kaaba/Mosque Icon Anchor
        Positioned(
          top: -48,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppShapes.lgRadius,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha:0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.mosque,
                color: AppColors.secondaryFixed, size: 20),
          ),
        ),
      ],
    );
  }
}
