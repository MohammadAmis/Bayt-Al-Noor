import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/utils/hijri_date_formatter.dart';

class PrayerDetailsDialog extends StatelessWidget {
  final String prayerName;
  final DateTime prayerTime;
  final Prayer prayer;
  
  const PrayerDetailsDialog({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.prayer,
  });

  @override
  Widget build(BuildContext context) {
    final hijri = HijriDateFormatter.format(prayerTime);
    final timeFormatted = DateFormat.jm().format(prayerTime);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.bentoGradient,
          borderRadius: AppShapes.xlRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayerName,
                      style: AppTypography.headline.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                    if (_getArabicName(prayer) != null)
                      Text(
                        _getArabicName(prayer)!,
                        style: AppTypography.body.copyWith(
                          color: Colors.white.withValues(alpha:0.85),
                          fontSize: 18,
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Time & Date Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.1),
                borderRadius: AppShapes.lgRadius,
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Time',
                    value: timeFormatted,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: DateFormat('EEEE, d MMMM y').format(prayerTime),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Hijri',
                    value: hijri,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Show Qibla direction
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.explore_rounded),
                    label: const Text('Qibla Direction'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppShapes.fullRadius,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Set custom reminder
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.alarm_add_rounded),
                    label: const Text('Set Reminder'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha:0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppShapes.fullRadius,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String? _getArabicName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr: return 'الفجر';
      case Prayer.sunrise: return 'الشروق';
      case Prayer.dhuhr: return 'الظهر';
      case Prayer.asr: return 'العصر';
      case Prayer.maghrib: return 'المغرب';
      case Prayer.isha: return 'العشاء';
      default: return null;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha:0.9)),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: AppTypography.label.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTypography.body.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}