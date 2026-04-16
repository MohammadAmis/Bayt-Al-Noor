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
    final baseColor = AppColors.getPrayerBaseColor(prayerName);
    final shadow = AppColors.getPrayerShadow(prayerName, isLarge: true);
    final bgIcon = _getBgIcon(prayerName);

    return AnimatedContainer(
      duration: AppAnimations.normal,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: AppShapes.xlRadius,
        boxShadow: [shadow],
      ),
      child: ClipRRect(
        borderRadius: AppShapes.xlRadius,
        child: Stack(
          children: [
            // Immersive Background Icon
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.12,
                child: Icon(
                  bgIcon,
                  size: 160,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date & Hijri
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: AppShapes.defaultRadius,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      date.toUpperCase(),
                                      style: AppTypography.label.copyWith(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    if (hijriDate != null) ...[
                                      const SizedBox(width: 8),
                                      Container(width: 1, height: 10, color: Colors.white24),
                                      const SizedBox(width: 8),
                                      Text(
                                        hijriDate.toUpperCase(),
                                        style: AppTypography.label.copyWith(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Prayer Name
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text(
                                    prayerName,
                                    style: AppTypography.display.copyWith(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: AppShapes.smRadius,
                                    ),
                                    child: const Text(
                                      'CURRENT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Time Display
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            time,
                            style: AppTypography.display.copyWith(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            amPm,
                            style: AppTypography.label.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBgIcon(String prayerName) {
    final name = prayerName.toLowerCase();
    if (name.contains('fajr')) return Icons.nights_stay_rounded;
    if (name.contains('sunrise')) return Icons.wb_sunny_rounded;
    if (name.contains('ishraq') || name.contains('chast')) return Icons.wb_twilight_rounded;
    if (name.contains('dhuhr')) return Icons.wb_sunny_rounded;
    if (name.contains('asr')) return Icons.wb_cloudy_rounded;
    if (name.contains('maghrib')) return Icons.wb_twilight_rounded;
    if (name.contains('isha')) return Icons.nights_stay_rounded;
    return Icons.mosque_rounded;
  }
}
