import 'package:bayt_al_noor/features/home/providers/countdown_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/providers/hijri_date_provider.dart';

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
    final hijriDate = ref.watch(hijriPrayerDateProvider(prayerTime));
    final isPrayerTime = countdownAsync.value?.inSeconds == 0;
    final timeStr = DateFormat('h:mm a').format(prayerTime);

    return Semantics(
      label: 'Next prayer: $nextPrayerName in ${_formatCountdownForSemantics(countdownAsync.value)}',
      hint: 'Tap to view prayer details',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppShapes.xlRadius,
          splashColor: Colors.white.withValues(alpha: 0.08),
          child: AnimatedContainer(
            duration: AppAnimations.normal,
            decoration: BoxDecoration(
              gradient: isPrayerTime
                  ? const LinearGradient(
                      colors: [Color(0xFF1B6B52), Color(0xFF0D3D2E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF00342B), Color(0xFF004D40)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: AppShapes.xlRadius,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00342B).withValues(alpha: isPrayerTime ? 0.45 : 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Main body: left info / right countdown ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 16, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── LEFT: label + name + prayer time ──
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // "Next Prayer" pill + alert icon
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    borderRadius: AppShapes.fullRadius,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isPrayerTime ? Icons.star_rounded : Icons.mosque_rounded,
                                        size: 10,
                                        color: Colors.white.withValues(alpha: 0.9),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isPrayerTime ? 'Prayer Time!' : 'Next Prayer',
                                        style: AppTypography.label.copyWith(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (showNotificationToggle) ...[
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.notifications_active_rounded,
                                    size: 13,
                                    color: Colors.white.withValues(alpha: 0.55),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Prayer name
                            Text(
                              nextPrayerName,
                              style: AppTypography.headline.copyWith(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                            ),
                            // Arabic name
                            if (_getArabicName(nextPrayer) != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                _getArabicName(nextPrayer)!,
                                style: AppTypography.headline.copyWith(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            // Prayer clock time
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 13,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeStr,
                                  style: AppTypography.label.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── RIGHT: countdown ──
                      countdownAsync.when(
                        data: (duration) => _buildCountdown(duration, isPrayerTime),
                        loading: _buildCountdownSkeleton,
                        error: (_, __) => _buildCountdownError(),
                      ),
                    ],
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Countdown: "prayer time now" state ──
  Widget _buildPrayerNowBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: AppShapes.lgRadius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
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
      case Prayer.fajr:     return 'الفجر';
      case Prayer.sunrise:  return 'الشروق';
      case Prayer.dhuhr:    return 'الظهر';
      case Prayer.asr:      return 'العصر';
      case Prayer.maghrib:  return 'المغرب';
      case Prayer.isha:     return 'العشاء';
      default:              return null;
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