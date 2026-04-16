import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/providers/hijri_date_provider.dart';
import '../../../settings/providers/settings_providers.dart';

class BentoTimetable extends StatelessWidget {
  final PrayerTimes prayerTimes;

  const BentoTimetable({
    super.key,
    required this.prayerTimes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Selector Section
        const DateSelector(),

        const SizedBox(height: 24),

        // Prayer List Section
        PrayerBentoList(prayerTimes: prayerTimes),

        const SizedBox(height: 32),

        // Quote Canvas Card
        const QuoteCanvasCard(),
      ],
    );
  }
}

class DateSelector extends StatelessWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prayer Schedule',
                    style: AppTypography.headline.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'DYNAMIC TIMETABLE',
                        style: AppTypography.label.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: AppColors.secondary.withValues(alpha: 0.7),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: AppColors.secondary.withValues(alpha: 0.2)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Calendar',
                      style: AppTypography.label.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: 7,
            itemBuilder: (context, index) {
              final date = now.add(Duration(days: index - 1));
              final isActive = index == 1; // Today
              final isPast = index == 0; // Yesterday

              return _buildDateChip(date, isActive: isActive, isPast: isPast);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateChip(DateTime dateTime,
      {bool isActive = false, bool isPast = false}) {
    final dayName = DateFormat('E').format(dateTime).toUpperCase();
    final dayNum = DateFormat('d').format(dateTime);

    // Determine color theme based on day
    Color themeColor;
    if (dateTime.weekday == DateTime.friday) {
      themeColor = AppColors.fridayEmerald;
    } else if (dateTime.weekday == DateTime.sunday) {
      themeColor = AppColors.sundayCrimson;
    } else {
      themeColor = AppColors.weekdaySlate;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 14),
      width: 60,
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeColor,
                  themeColor.withValues(alpha: 0.7),
                ],
              )
            : null,
        color: isActive
            ? null
            : themeColor.withValues(alpha: isPast ? 0.05 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? Colors.white.withValues(alpha: 0.3)
              : themeColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: themeColor.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayName,
                style: AppTypography.label.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.9)
                      : themeColor.withValues(alpha: isPast ? 0.4 : 0.8),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dayNum,
                style: AppTypography.headline.copyWith(
                  fontSize: isActive ? 26 : 22,
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? Colors.white
                      : AppColors.onSurface
                          .withValues(alpha: isPast ? 0.3 : 0.9),
                  height: 1.0,
                ),
              ),
              if (isActive)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrayerBentoList extends ConsumerWidget {
  final PrayerTimes prayerTimes;

  const PrayerBentoList({
    super.key,
    required this.prayerTimes,
  });

  String _format(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  String _getSubtitle(String prayer) {
    switch (prayer.toLowerCase()) {
      case 'fajr':
        return 'الفجر';
      case 'ishraq':
        return 'الإشراق';
      case 'chast':
        return 'الضحى';
      case 'dhuhr':
        return 'الظهر';
      case 'asr':
        return 'العصر';
      case 'maghrib':
        return 'المغرب';
      case 'isha':
        return 'العشاء';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = prayerTimes.currentPrayer();
    final now = DateTime.now();

    // Helper for sub-window logic (Ishraq/Chast)
    bool isIshraqActive() {
      if (current != Prayer.sunrise) return false;
      final ishraqStart = prayerTimes.sunrise.add(const Duration(minutes: 20));
      final chastStart = prayerTimes.sunrise.add(const Duration(minutes: 60));
      return now.isAfter(ishraqStart) && now.isBefore(chastStart);
    }

    bool isChastActive() {
      if (current != Prayer.sunrise) return false;
      final chastStart = prayerTimes.sunrise.add(const Duration(minutes: 60));
      return now.isAfter(chastStart);
    }

    return Column(
      children: [
        PrayerBentoTile(
          prayer: 'Fajr',
          subtitle: _getSubtitle('Fajr'),
          time: _format(prayerTimes.fajr),
          icon: Icons.wb_twilight,
          iconBg: AppColors.fajr,
          iconColor: AppColors.onPrimaryFixed,
          isActive: current == Prayer.fajr,
          hijriDate: ref.watch(hijriPrayerDateProvider(prayerTimes.fajr)),
        ),
        const SizedBox(height: 12),
        PrayerBentoTile(
          prayer: 'Ishraq',
          subtitle: _getSubtitle('Ishraq'),
          time: _format(prayerTimes.sunrise.add(const Duration(minutes: 20))),
          icon: Icons.wb_sunny_outlined,
          iconBg: AppColors.ishraq,
          iconColor: Colors.white,
          isActive: isIshraqActive(),
        ),
        const SizedBox(height: 12),
        PrayerBentoTile(
          prayer: 'Chast',
          subtitle: _getSubtitle('Chast'),
          time: _format(prayerTimes.sunrise.add(const Duration(minutes: 60))),
          icon: Icons.brightness_low_rounded,
          iconBg: AppColors.chast,
          iconColor: Colors.white,
          isActive: isChastActive(),
        ),
        const SizedBox(height: 12),
        PrayerBentoTile(
          prayer: 'Dhuhr',
          subtitle: _getSubtitle('Dhuhr'),
          time: _format(prayerTimes.dhuhr),
          icon: Icons.sunny,
          iconBg: AppColors.dhuhr,
          iconColor: Colors.white,
          isActive: current == Prayer.dhuhr,
        ),
        const SizedBox(height: 12),
        PrayerBentoTile(
          prayer: 'Asr',
          subtitle: _getSubtitle('Asr'),
          time: _format(prayerTimes.asr),
          icon: Icons.wb_cloudy_outlined,
          iconBg: AppColors.asr,
          iconColor: AppColors.asr,
          isActive: current == Prayer.asr,
        ),
        const SizedBox(height: 12),
        PrayerBentoTile(
          prayer: 'Maghrib',
          subtitle: _getSubtitle('Maghrib'),
          time: _format(prayerTimes.maghrib),
          icon: Icons.wb_twilight,
          iconBg: AppColors.maghrib,
          iconColor: AppColors.onSecondaryFixedVariant,
          isActive: current == Prayer.maghrib,
          hijriDate: ref.watch(hijriPrayerDateProvider(prayerTimes.maghrib)),
        ),
        const SizedBox(height: 12),
        PrayerBentoTile(
          prayer: 'Isha',
          subtitle: _getSubtitle('Isha'),
          time: _format(prayerTimes.isha),
          icon: Icons.dark_mode,
          iconBg: AppColors.isha,
          iconColor: AppColors.onTertiaryFixed,
          isActive: current == Prayer.isha,
        ),
      ],
    );
  }
}

class PrayerBentoTile extends ConsumerWidget {
  final String prayer;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool isActive;
  final bool isDimmed;
  final String? hijriDate;

  const PrayerBentoTile({
    super.key,
    required this.prayer,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.isActive = false,
    this.isDimmed = false,
    this.hijriDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalEnabled = ref.watch(notificationsEnabledProvider);
    final prayerEnabled =
        ref.watch(prayerNotificationsProvider(prayer.toLowerCase()));
    final isEffectivelyEnabled = globalEnabled && prayerEnabled;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(isActive ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [
                  iconBg,
                  iconBg.withValues(alpha: 0.8),
                ]
              : [
                  iconBg.withValues(alpha: 0.08),
                  iconBg.withValues(alpha: 0.03),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? Colors.white.withValues(alpha: 0.2)
              : iconBg.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: iconBg.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.01),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isActive)
            Positioned(
              top: -28,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ACTIVE NOW',
                      style: AppTypography.label.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              // Icon Container with soft glow
              Container(
                width: isActive ? 56 : 48,
                height: isActive ? 56 : 48,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.15)
                      : iconBg.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.3)
                        : iconBg.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: isActive ? Colors.white : iconBg,
                    size: isActive ? 24 : 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Name and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      prayer,
                      style: AppTypography.headline.copyWith(
                        fontSize: isActive ? 22 : 20,
                        color: isActive ? Colors.white : iconBg,
                        fontWeight:
                            isActive ? FontWeight.w800 : FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle.toUpperCase(),
                      style: AppTypography.label.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.8)
                            : AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Time and Hijri Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: AppTypography.title.copyWith(
                      fontSize: isActive ? 24 : 20,
                      fontWeight: isActive ? FontWeight.w300 : FontWeight.w500,
                      color: isActive ? Colors.white : AppColors.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (hijriDate != null)
                    Text(
                      hijriDate!.toUpperCase(),
                      style: AppTypography.label.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.6)
                            : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              // Interactive Toggle Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Check if global settings allow toggling, or if we should alert user
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
                        .read(prayerNotificationsProvider(prayer.toLowerCase())
                            .notifier)
                        .toggle(!prayerEnabled);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isEffectivelyEnabled
                          ? (isActive
                              ? Colors.white.withValues(alpha: 0.2)
                              : iconBg.withValues(alpha: 0.1))
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isEffectivelyEnabled
                            ? (isActive
                                ? Colors.white.withValues(alpha: 0.3)
                                : iconBg.withValues(alpha: 0.2))
                            : (isActive
                                ? Colors.white.withValues(alpha: 0.1)
                                : AppColors.outline.withValues(alpha: 0.1)),
                        width: 1,
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        isEffectivelyEnabled
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_outlined,
                        key: ValueKey(isEffectivelyEnabled),
                        color: isEffectivelyEnabled
                            ? (isActive ? Colors.white : iconBg)
                            : (isActive
                                ? Colors.white.withValues(alpha: 0.3)
                                : AppColors.onSurfaceVariant
                                    .withValues(alpha: 0.3)),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuoteCanvasCard extends StatelessWidget {
  const QuoteCanvasCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tertiary,
            AppColors.tertiary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.tertiary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background icon
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.format_quote_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.tertiaryFixed,
                  size: 20,
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    '"Prayer is a light for the believer."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Noto Serif',
                      fontSize: 19,
                      fontStyle: FontStyle.italic,
                      color: AppColors.tertiaryFixed,
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'HADITH • AL-JAMI\'',
                    style: AppTypography.label.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.onTertiaryContainer,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
