import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_tokens.dart';
import '../../../prayer_times/domain/entities/active_prayer_window.dart';
import '../../../../core/providers/hijri_date_provider.dart';

class CurrentPrayerHeader extends ConsumerWidget {
  final String date;
  final String prayerName;
  final String time;
  final String amPm;
  final SpiritualWindow windowType;

  const CurrentPrayerHeader({
    super.key,
    required this.date,
    required this.prayerName,
    required this.time,
    required this.amPm,
    this.windowType = SpiritualWindow.regular,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hijriDate = ref.watch(hijriDateDisplayProvider);
    return Stack(
      children: [
        if (windowType == SpiritualWindow.ishraq)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.radialHighlight,
                borderRadius: AppShapes.xlRadius,
              ),
            ),
          ),
        AnimatedContainer(
          duration: AppAnimations.normal,
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: _getGradientForWindow(windowType),
            borderRadius: AppShapes.xlRadius,
            boxShadow: windowType != SpiritualWindow.regular
                ? [
                    BoxShadow(
                        color: AppColors.surfaceTint.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]
                : null,
          ),
          child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        Row(
                          children: [
                            Text(
                              date.toUpperCase(),
                              style: AppTypography.label.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            if (hijriDate != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                hijriDate.toUpperCase(),
                                style: AppTypography.label.copyWith(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              prayerName,
                              style: AppTypography.display.copyWith(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha:0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'CURRENT',
                            style: AppTypography.label.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: AppTypography.display.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      amPm,
                      style: AppTypography.label.copyWith(
                        color: Colors.white.withValues(alpha:0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (windowType != SpiritualWindow.regular && windowType != SpiritualWindow.none)
            Container(
              margin: const EdgeInsets.only(top: 16),
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppShapes.fullRadius,
                ),
                child: Text(
                  windowType == SpiritualWindow.ishraq ? '✨ Ishraq Time' : '⚠️ Zawal (Makruh)',
                  style: AppTypography.label.copyWith(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    ),
    ],
    );
  }

  LinearGradient _getGradientForWindow(SpiritualWindow type) {
    switch (type) {
      case SpiritualWindow.ishraq:
        return const LinearGradient(colors: [Color(0xFFFFB74D), Color(0xFFFF9800)]);
      case SpiritualWindow.zawal:
        return const LinearGradient(colors: [Color(0xFF9E9E9E), Color(0xFF616161)]);
      default:
        // Use default primary color if no gradient is specified
        return const LinearGradient(colors: [AppColors.primary, AppColors.primary]);
    }
  }
}
