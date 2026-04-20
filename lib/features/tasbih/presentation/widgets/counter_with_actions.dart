import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../data/services/tasbih_service.dart';
import 'tasbih_counters.dart';

class CounterWithActions extends StatelessWidget {
  final TasbihService service;
  final Animation<double> pulseAnimation;
  final VoidCallback onIncrement;
  final VoidCallback onReset;

  const CounterWithActions({
    super.key,
    required this.service,
    required this.pulseAnimation,
    required this.onIncrement,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: Column(
            children: [
              Tooltip(
                message: 'Series Mode',
                child: GestureDetector(
                  onTap: () => service.toggleSeriesMode(!service.isSeriesMode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: service.isSeriesMode ? AppColors.primary : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: service.isSeriesMode 
                              ? AppColors.primary.withValues(alpha: 0.2) 
                              : AppColors.onSurface.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 20,
                      color: service.isSeriesMode ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'SERIES',
                style: AppTypography.label.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: service.isSeriesMode ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha:0.5),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 48, left: 12, right: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: _buildCounterDisplay(),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Column(
            children: [
              Tooltip(
                message: 'Reset Counter',
                child: GestureDetector(
                  onTap: onReset,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.onSurface.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'RESET',
                style: AppTypography.label.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSurfaceVariant.withValues(alpha:0.5),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounterDisplay() {
    if (service.counterStyle == CounterStyle.beads) {
      return ClassicBeadsCounter(
        count: service.sessionCount,
        goal: service.sessionGoal,
        dhikr: service.selectedDhikr,
        onTap: onIncrement,
      );
    } else {
      return ModernOrbCounter(
        count: service.sessionCount,
        goal: service.sessionGoal,
        dhikr: service.selectedDhikr,
        onTap: onIncrement,
        pulseAnimation: pulseAnimation,
      );
    }
  }
}
