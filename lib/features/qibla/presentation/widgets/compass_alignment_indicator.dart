import 'package:flutter/material.dart';
import '../../../../../core/design_tokens.dart';

/// Animated pulse indicator that appears when user faces Qibla
class CompassAlignmentIndicator extends StatefulWidget {
  final AnimationController controller;

  const CompassAlignmentIndicator({
    super.key,
    required this.controller,
  });

  @override
  State<CompassAlignmentIndicator> createState() => _CompassAlignmentIndicatorState();
}

class _CompassAlignmentIndicatorState extends State<CompassAlignmentIndicator> {
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 0.8).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.easeIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.celestialGold.withValues(alpha: 0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.celestialGlow.withValues(alpha: 0.8),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}