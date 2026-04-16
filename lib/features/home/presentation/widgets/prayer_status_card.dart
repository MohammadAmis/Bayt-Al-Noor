import 'package:bayt_al_noor/features/home/providers/countdown_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_tokens.dart';
import '../../../settings/providers/settings_providers.dart';

class PrayerStatusCard extends ConsumerWidget {
  final String nextPrayerName;
  final Prayer nextPrayer;
  final DateTime prayerTime;
  final VoidCallback? onTap;
  final bool showNotificationToggle;

  const PrayerStatusCard({
    super.key,
    required this.nextPrayerName,
    required this.nextPrayer,
    required this.prayerTime,
    this.onTap,
    this.showNotificationToggle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdownAsync = ref.watch(countdownStreamProvider(nextPrayer));
    final isPrayerTime = countdownAsync.value?.inSeconds == 0;
    final timeStr = DateFormat('h:mm a').format(prayerTime);

    // Notification State Sync
    final globalEnabled = ref.watch(notificationsEnabledProvider);
    final prayerEnabled =
        ref.watch(prayerNotificationsProvider(nextPrayerName.toLowerCase()));
    final isEffectivelyEnabled = globalEnabled && prayerEnabled;

    final prayerBaseColor = AppColors.getPrayerBaseColor(nextPrayerName);
    final prayerShadow = AppColors.getPrayerShadow(nextPrayerName, isLarge: false);

    return Semantics(
      label: 'Next prayer: $nextPrayerName in ${_formatCountdownForSemantics(countdownAsync.value)}',
      hint: 'Tap to view prayer details',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppShapes.lgRadius,
          child: AnimatedContainer(
            duration: AppAnimations.normal,
            decoration: BoxDecoration(
              color: prayerBaseColor,
              borderRadius: AppShapes.lgRadius,
              boxShadow: [
                prayerShadow.copyWith(
                  color: prayerShadow.color.withValues(alpha: isPrayerTime ? 0.3 : 0.15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: AppShapes.lgRadius,
              child: Stack(
                children: [
                  // Subtle Pattern
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        _getIcon(nextPrayerName),
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  
                  // Main Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text(
                                    nextPrayerName,
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
                                      'UPCOMING',
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
                              const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_filled_rounded, size: 12, color: Colors.white.withValues(alpha: 0.6)),
                                      const SizedBox(width: 4),
                                      Text(
                                        timeStr,
                                        style: AppTypography.label.copyWith(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (showNotificationToggle) ...[
                                        const SizedBox(width: 12),
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              if (!globalEnabled) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Global notifications are turned off in settings.'),
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                                return;
                                              }
                                              ref
                                                  .read(prayerNotificationsProvider(
                                                          nextPrayerName.toLowerCase())
                                                      .notifier)
                                                  .toggle(!prayerEnabled);
                                            },
                                            borderRadius: BorderRadius.circular(20),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: isEffectivelyEnabled
                                                    ? Colors.white.withValues(alpha: 0.15)
                                                    : Colors.transparent,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isEffectivelyEnabled
                                                      ? Colors.white.withValues(alpha: 0.3)
                                                      : Colors.white.withValues(alpha: 0.1),
                                                  width: 1,
                                                ),
                                              ),
                                              child: AnimatedSwitcher(
                                                duration: const Duration(milliseconds: 300),
                                                child: Icon(
                                                  isEffectivelyEnabled
                                                      ? Icons.notifications_active_rounded
                                                      : Icons.notifications_off_outlined,
                                                  key: ValueKey(isEffectivelyEnabled),
                                                  color: isEffectivelyEnabled
                                                      ? Colors.white
                                                      : Colors.white.withValues(alpha: 0.5),
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                            ],
                          ),
                        ),
                        
                        // Right: Countdown
                        countdownAsync.when(
                          data: (duration) => _buildCompactCountdown(duration, isPrayerTime),
                          loading: () => const SizedBox(width: 60, height: 40),
                          error: (_, __) => const Icon(Icons.error_outline, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCountdown(Duration duration, bool isPrayerTime) {
    if (isPrayerTime) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: AppShapes.defaultRadius,
          border: Border.all(color: Colors.white24),
        ),
        child: const Text(
          'NOW',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
        ),
      );
    }

    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: AppShapes.defaultRadius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}',
            style: AppTypography.display.copyWith(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'REMAINING',
            style: AppTypography.label.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String prayerName) {
    final name = prayerName.toLowerCase();
    if (name.contains('fajr')) return Icons.nights_stay_rounded;
    if (name.contains('sunrise')) return Icons.wb_sunny_rounded;
    if (name.contains('dhuhr')) return Icons.wb_sunny_rounded;
    if (name.contains('asr')) return Icons.wb_cloudy_rounded;
    if (name.contains('maghrib')) return Icons.wb_twilight_rounded;
    if (name.contains('isha')) return Icons.nights_stay_rounded;
    return Icons.mosque_rounded;
  }

  // ── Countdown: "prayer time now" state ──
  Widget _buildPrayerNowBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: AppShapes.lgRadius,
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(
            'Now',
            style: AppTypography.label.copyWith(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Main countdown display ──
  Widget _buildCountdown(Duration duration, bool isPrayerTime) {
    if (isPrayerTime || duration.inSeconds <= 0) {
      return _buildPrayerNowBadge();
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: AppShapes.lgRadius,
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Big time display: HH:MM
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: hours.toString().padLeft(2, '0'),
                  style: AppTypography.display.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
                TextSpan(
                  text: ':',
                  style: AppTypography.display.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    height: 1.0,
                  ),
                ),
                TextSpan(
                  text: minutes.toString().padLeft(2, '0'),
                  style: AppTypography.display.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Seconds underneath, smaller
          Text(
            ':${seconds.toString().padLeft(2, '0')}',
            style: AppTypography.label.copyWith(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'remaining',
            style: AppTypography.label.copyWith(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownError() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: AppShapes.lgRadius,
      ),
      child: Text(
        '--:--',
        style: AppTypography.display.copyWith(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _buildCountdownSkeleton() {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: AppShapes.lgRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 28,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: AppShapes.defaultRadius,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 10,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: AppShapes.defaultRadius,
            ),
          ),
        ],
      ),
    );
  }

  String? _getArabicName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      default:
        return null;
    }
  }

  String _formatCountdownForSemantics(Duration? duration) {
    if (duration == null) return 'calculating';
    if (duration.inSeconds <= 0) return 'now';
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    return h > 0 ? '$h hours $m minutes' : '$m minutes';
  }
}
