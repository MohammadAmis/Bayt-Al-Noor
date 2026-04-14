import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import '../../../../core/design_tokens.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prayer Schedule',
                  style: AppTypography.headline.copyWith(
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'DYNAMIC CALCULATION',
                  style: AppTypography.label.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calendar_month, size: 18),
              label: const Text('Full Calendar'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildDateChip(DateFormat('E').format(DateTime.now().subtract(const Duration(days: 1))), DateFormat('d').format(DateTime.now().subtract(const Duration(days: 1))), isPast: true),
              _buildDateChip(DateFormat('E').format(DateTime.now()), DateFormat('d').format(DateTime.now()), isActive: true),
              _buildDateChip(DateFormat('E').format(DateTime.now().add(const Duration(days: 1))), DateFormat('d').format(DateTime.now().add(const Duration(days: 1)))),
              _buildDateChip(DateFormat('E').format(DateTime.now().add(const Duration(days: 2))), DateFormat('d').format(DateTime.now().add(const Duration(days: 2)))),
              _buildDateChip(DateFormat('E').format(DateTime.now().add(const Duration(days: 3))), DateFormat('d').format(DateTime.now().add(const Duration(days: 3)))),
              _buildDateChip(DateFormat('E').format(DateTime.now().add(const Duration(days: 4))), DateFormat('d').format(DateTime.now().add(const Duration(days: 4)))),
              _buildDateChip(DateFormat('E').format(DateTime.now().add(const Duration(days: 5))), DateFormat('d').format(DateTime.now().add(const Duration(days: 5)))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateChip(String day, String date, {bool isActive = false, bool isPast = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 56,
      height: isActive ? 96 : 80,
      decoration: BoxDecoration(
        gradient: isActive 
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryContainer],
            )
          : null,
        color: isActive ? null : (isPast ? AppColors.surfaceContainer : AppColors.surfaceContainerLow),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isActive ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.toUpperCase(),
            style: AppTypography.label.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.primaryFixed : AppColors.onSurfaceVariant.withValues(alpha:isPast ? 0.5 : 1),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: AppTypography.headline.copyWith(
              fontSize: isActive ? 24 : 18,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : AppColors.onSurface.withValues(alpha:isPast ? 0.5 : 1),
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.secondaryFixed,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class PrayerBentoList extends StatelessWidget {
  final PrayerTimes prayerTimes;

  const PrayerBentoList({
    super.key,
    required this.prayerTimes,
  });

  String _format(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final next = prayerTimes.nextPrayer();

    return Column(
      children: [
        _buildBentoItem(
          'Fajr', 
          'Dawn Prayer', 
          _format(prayerTimes.fajr), 
          Icons.wb_twilight, 
          AppColors.primaryFixed,
          AppColors.onPrimaryFixed,
          isActive: next == Prayer.fajr,
        ),
        const SizedBox(height: 12),
        _buildBentoItem(
          'Sunrise', 
          'Shuruq', 
          _format(prayerTimes.sunrise), 
          Icons.wb_sunny, 
          AppColors.secondaryFixed,
          AppColors.onSecondaryFixed,
          isActive: next == Prayer.sunrise,
          isDimmed: true,
        ),
        const SizedBox(height: 12),
        _buildBentoItem(
          'Dhuhr', 
          'Noon Prayer', 
          _format(prayerTimes.dhuhr), 
          Icons.sunny, 
          AppColors.primary,
          Colors.white,
          isActive: next == Prayer.dhuhr,
        ),
        const SizedBox(height: 12),
        _buildBentoItem(
          'Asr', 
          'Afternoon Prayer', 
          _format(prayerTimes.asr), 
          Icons.wb_cloudy_outlined, 
          AppColors.primaryFixedDim,
          AppColors.onPrimaryFixedVariant,
          isActive: next == Prayer.asr,
        ),
        const SizedBox(height: 12),
        _buildBentoItem(
          'Maghrib', 
          'Sunset Prayer', 
          _format(prayerTimes.maghrib), 
          Icons.wb_twilight, 
          AppColors.secondaryFixedDim,
          AppColors.onSecondaryFixedVariant,
          isActive: next == Prayer.maghrib,
        ),
        const SizedBox(height: 12),
        _buildBentoItem(
          'Isha', 
          'Night Prayer', 
          _format(prayerTimes.isha), 
          Icons.dark_mode, 
          AppColors.tertiaryFixedDim,
          AppColors.onTertiaryFixed,
          isActive: next == Prayer.isha,
        ),
      ],
    );
  }

  Widget _buildBentoItem(
    String name, 
    String subtitle, 
    String time, 
    IconData icon, 
    Color iconBg, 
    Color iconColor,
    {bool isActive = false, bool isDimmed = false}
  ) {
    return Container(
      padding: EdgeInsets.all(isActive ? 20 : 16),
      decoration: BoxDecoration(
        gradient: isActive 
          ? const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.primary, AppColors.primaryContainer],
            )
          : null,
        color: isActive ? null : (isDimmed ? AppColors.surfaceContainerLow : AppColors.surfaceContainerLowest),
        borderRadius: BorderRadius.circular(16),
        border: !isActive ? Border.all(color: AppColors.outlineVariant.withValues(alpha:0.05)) : null,
        boxShadow: isActive ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ] : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isActive)
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.1),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Text(
                  'NEXT',
                  style: AppTypography.label.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          Row(
            children: [
              // Icon Container
              Container(
                width: isActive ? 52 : 44,
                height: isActive ? 52 : 44,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white.withValues(alpha:0.1) : iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isActive ? AppColors.primaryFixed : iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              // Name and Subtitle (The Flexible Core)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: AppTypography.headline.copyWith(
                        fontSize: isActive ? 22 : 18,
                        color: isActive ? Colors.white : AppColors.primary,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle.toUpperCase(),
                      style: AppTypography.label.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isActive ? Colors.white.withValues(alpha:0.6) : AppColors.onSurfaceVariant,
                        letterSpacing: 1.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Time Display
              Text(
                time,
                style: AppTypography.title.copyWith(
                  fontSize: isActive ? 24 : 18,
                  fontWeight: FontWeight.w300,
                  color: isActive ? Colors.white : AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              // Indicator Container
              Container(
                width: isActive ? 40 : 36,
                height: isActive ? 40 : 36,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.secondary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isActive ? Icons.notifications_active : Icons.notifications,
                  color: isActive ? Colors.white : AppColors.primary.withValues(alpha:0.3),
                  size: 18,
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
      constraints: const BoxConstraints(minHeight: 160),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: Text(
                    '"Prayer is a light for the believer."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Noto Serif',
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: AppColors.tertiaryFixed,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'HADITH • AL-JAMI\'',
                  style: AppTypography.label.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: AppColors.onTertiaryContainer,
                    letterSpacing: 2.0,
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
