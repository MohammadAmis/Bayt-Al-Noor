import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/services/prayer_service.dart';

class MilestoneGrid extends StatelessWidget {
  final PrayerTimes prayerTimes;
  
  const MilestoneGrid({
    super.key,
    required this.prayerTimes,
  });

  String _format(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final prayerService = PrayerService.instance;

    // Logic for Dynamic Swapping
    final hasSunRisen = now.isAfter(prayerTimes.sunrise);

    // Slot 1: Sehri Ends OR Ishraq
    final slot1Label = hasSunRisen ? 'Ishraq' : 'Sehri Ends';
    final slot1Time = hasSunRisen 
        ? _format(prayerService.getIshraqTime(prayerTimes.sunrise))
        : _format(prayerTimes.fajr);
    final slot1Icon = hasSunRisen ? Icons.wb_twilight : Icons.brightness_3;
    final slot1Color = hasSunRisen ? AppColors.primary : AppColors.secondary;

    // Slot 2: Sunrise OR Zawal
    // We show Zawal once we are approaching Dhuhr (e.g., after 11 AM)
    final isApproachZawal = now.hour >= 11 && now.isBefore(prayerTimes.dhuhr);
    final slot2Label = isApproachZawal ? 'Zawal (Start)' : 'Sunrise';
    final slot2Time = isApproachZawal 
        ? _format(prayerService.getZawalTime(prayerTimes.dhuhr))
        : _format(prayerTimes.sunrise);
    final slot2Icon = isApproachZawal ? Icons.timer_outlined : Icons.wb_sunny;

    return BentoCard(
      padding: const EdgeInsets.all(20),
      color: AppColors.surfaceContainerLowest,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMilestoneItem(
                  slot1Label,
                  slot1Time,
                  slot1Icon,
                  slot1Color.withValues(alpha:0.1),
                  slot1Color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMilestoneItem(
                  slot2Label,
                  slot2Time,
                  slot2Icon,
                  AppColors.primary.withValues(alpha:0.1),
                  AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMilestoneItem(
                  'Iftar Starts',
                  _format(prayerTimes.maghrib),
                  Icons.nights_stay,
                  AppColors.tertiary.withValues(alpha:0.1),
                  AppColors.tertiary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMilestoneItem(
                  'Sunset',
                  _format(prayerTimes.maghrib), // adhan sunset is maghrib
                  Icons.wb_twilight,
                  AppColors.outline.withValues(alpha:0.1),
                  AppColors.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(
    String label,
    String time,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTypography.label.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                time,
                style: AppTypography.headline.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
