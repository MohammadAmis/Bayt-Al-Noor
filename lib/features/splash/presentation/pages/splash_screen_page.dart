import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/design_tokens.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_svgs.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _contentController;

  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;

  @override
  void initState() {
    super.initState();

    // Rotation for the ring
    _rotationController = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
      ..repeat();

    // Pulse for the logo
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);

    // Fade and slide for content
    _contentController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    ));

    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
    ));

    _subtitleOpacity =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    ));

    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
    ));

    _contentController.forward();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    // 1. Maintain the aesthetic delay for the splash animation
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    // 2. Check for an existing Supabase session
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // User is logged in, navigate to Home
      context.go('/home');
    } else {
      // User is not logged in, navigate to Login
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // 1. Immersive Gradient Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    AppColors.primaryContainer.withValues(alpha:0.8),
                    AppColors.primary,
                  ],
                ),
              ),
            ),
          ),

          // 2. Subtle Geometric Pattern (Painter)
          Positioned.fill(
            child: CustomPaint(
              painter: GeometricPatternPainter(
                color: AppColors.secondary.withValues(alpha:0.05),
              ),
            ),
          ),

          // 3. Central Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Multi-layered Logo
                _buildAnimatedLogo(),
                const SizedBox(height: 64),

                // Text Content
                FadeTransition(
                  opacity: _titleOpacity,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: Text(
                      'Bayt Al-Noor',
                      style: AppTypography.display.copyWith(
                        color: Colors.white,
                        fontSize: 40,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha:0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _subtitleOpacity,
                  child: SlideTransition(
                    position: _subtitleSlide,
                    child: Text(
                      'بَيْتُ النُّورِ',
                      style: AppTypography.headline.copyWith(
                        color: AppColors.secondaryFixedDim,
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Bottom Journey Accent
          Positioned(
            bottom: 64,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _subtitleOpacity,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'SANCTUARY OF LIGHT',
                      style: AppTypography.label.copyWith(
                        color: Colors.white.withValues(alpha:0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 40,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withValues(alpha:0.1),
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.secondary),
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Glowing Aura
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 180 + (20 * _pulseController.value),
              height: 180 + (20 * _pulseController.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha:0.15 * (1 - _pulseController.value)),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
        ),

        // Rotating Geometric Ring (Star/Octagon)
        RotationTransition(
          turns: _rotationController,
          child: CustomPaint(
            size: const Size(200, 200),
            painter: GeometricRingPainter(
              color: AppColors.secondary.withValues(alpha:0.2),
            ),
          ),
        ),

        // Central Kufic Logo
        ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.05).animate(
            CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
          ),
          child: Container(
            width: 140,
            height: 140,
            padding: const EdgeInsets.all(20), // Add padding so it doesn't hit edges
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha:0.1),
                width: 1,
              ),
            ),
            child: SvgPicture.string(
              AppSvgs.logo,
              width: 80,
              height: 80,
              colorFilter: const ColorFilter.mode(
                AppColors.secondary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GeometricRingPainter extends CustomPainter {
  final Color color;
  GeometricRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw an 8-pointed star/geometric ring
    final path = Path();
    for (int i = 0; i < 16; i++) {
        double angle = (i * math.pi / 8);
        double currentRadius = (i % 2 == 0) ? radius : radius * 0.85;
        double x = center.dx + currentRadius * math.cos(angle);
        double y = center.dy + currentRadius * math.sin(angle);
        if (i == 0) {
            path.moveTo(x, y);
        } else {
            path.lineTo(x, y);
        }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Some inner dots for detail
    for (int i = 0; i < 8; i++) {
        double angle = (i * math.pi / 4);
        double x = center.dx + (radius * 0.7) * math.cos(angle);
        double y = center.dy + (radius * 0.7) * math.sin(angle);
        canvas.drawCircle(Offset(x, y), 2, paint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GeometricPatternPainter extends CustomPainter {
  final Color color;
  GeometricPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    double spacing = 60;
    for (double i = -spacing; i < size.width + spacing; i += spacing) {
      for (double j = -spacing; j < size.height + spacing; j += spacing) {
        _drawIslamicStar(canvas, Offset(i, j), 20, paint);
      }
    }
  }

  void _drawIslamicStar(Canvas canvas, Offset center, double radius, Paint paint) {
      final path = Path();
      for (int i = 0; i < 8; i++) {
          double angle = (i * math.pi / 4);
          double x = center.dx + radius * math.cos(angle);
          double y = center.dy + radius * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
          
          double innerAngle = angle + (math.pi / 8);
          double innerX = center.dx + (radius * 0.7) * math.cos(innerAngle);
          double innerY = center.dy + (radius * 0.7) * math.sin(innerAngle);
          path.lineTo(innerX, innerY);
      }
      path.close();
      canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
