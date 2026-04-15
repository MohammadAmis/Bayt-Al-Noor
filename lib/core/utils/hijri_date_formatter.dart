import 'package:hijri/hijri_calendar.dart';

class HijriDateFormatter {
  /// Convert Gregorian to Hijri with English month names
  static String format(DateTime date, {bool short = false}) {
    final hijri = HijriCalendar.fromDate(date);
    
    // English month mapping (package uses Arabic by default)
    const months = [
      'Muharram', 'Safar', 'Rabi\' al-Awwal', 'Rabi\' al-Thani',
      'Jumada al-Ula', 'Jumada al-Thani', 'Rajab', 'Sha\'ban',
      'Ramadan', 'Shawwal', 'Dhu al-Qi\'dah', 'Dhu al-Hijjah'
    ];
    
    final day = hijri.hDay;
    final month = months[(hijri.hMonth - 1) % 12];
    final year = hijri.hYear;
    
    return short ? '$day $month' : '$day $month, $year AH';
  }
  
  /// Format specifically for prayer cards (compact)
  static String formatCompact(DateTime date) {
    return format(date, short: true);
  }
}
