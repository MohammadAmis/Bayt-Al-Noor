import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import '../../../../core/design_tokens.dart';

class MilestoneGrid extends StatelessWidget {
  final PrayerTimes prayerTimes;

  const MilestoneGrid({
    super.key,
    required this.prayerTimes,
  });

  String _format(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate width to show exactly 3.5 items
    final itemWidth = (screenWidth - 32) / 3.5; // 32 is standard horizontal padding

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildMilestoneChip(
                itemWidth,
                'SUNRISE',
                _format(prayerTimes.sunrise),
                Icons.wb_sunny_rounded,
                AppColors.sunriseGold,
              ),
              _buildMilestoneChip(
                itemWidth,
                'SUNSET',
                _format(prayerTimes.maghrib),
                Icons.wb_twilight_rounded,
                AppColors.sunsetCrimson,
              ),
              _buildMilestoneChip(
                itemWidth,
                'IFTAR',
                _format(prayerTimes.maghrib),
                Icons.mosque_rounded,
                AppColors.iftarEmerald,
              ),
              _buildMilestoneChip(
                itemWidth,
                'SEHRI',
                _format(prayerTimes.fajr),
                Icons.nightlight_round,
                AppColors.sehriIndigo,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneChip(
    double width,
    String label,
    String time,
    IconData icon,
    Color themeColor,
  ) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: themeColor,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.label.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: themeColor.withValues(alpha: 0.7),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            time,
            style: AppTypography.headline.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
