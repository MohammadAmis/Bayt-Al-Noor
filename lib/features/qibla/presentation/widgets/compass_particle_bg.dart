import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/design_tokens.dart';

/// Subtle animated star/particle background for celestial theme
class CompassParticleBg extends StatefulWidget {
  final double size;

  const CompassParticleBg({super.key, required this.size});

  @override
  State<CompassParticleBg> createState() => _CompassParticleBgState();
}

class _CompassParticleBgState extends State<CompassParticleBg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  static const int _particleCount = 12;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.pulseAnimation,
    )..repeat(reverse: true);
    
    _initParticles();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initParticles() {
    final random = math.Random(42); // Fixed seed for consistent appearance
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(_Particle(
        angle: random.nextDouble() * 2 * math.pi,
        distance: 0.4 + random.nextDouble() * 0.4, // 40-80% of radius
        size: 1 + random.nextDouble() * 2,
        delay: random.nextDouble() * 2,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: _particles.map((particle) {
              final progress = (_controller.value + particle.delay) % 1;
              final opacity = 0.2 + 0.4 * math.sin(progress * math.pi);
              final scale = 0.8 + 0.4 * math.sin(progress * math.pi * 2);
              
              return Positioned(
                left: widget.size / 2 + 
                    particle.distance * widget.size / 2 * math.cos(particle.angle) - particle.size / 2,
                top: widget.size / 2 + 
                    particle.distance * widget.size / 2 * math.sin(particle.angle) - particle.size / 2,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: particle.size,
                      height: particle.size,
                      decoration: BoxDecoration(
                        color: AppColors.celestialGoldLight,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.celestialGlow.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// Internal particle model
class _Particle {
  final double angle; // Position angle in radians
  final double distance; // Distance from center (0.0-1.0)
  final double size; // Particle size in pixels
  final double delay; // Animation delay (0.0-1.0)

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
  });
}