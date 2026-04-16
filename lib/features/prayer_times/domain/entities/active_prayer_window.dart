import 'package:adhan/adhan.dart';
import 'package:equatable/equatable.dart';

enum SpiritualWindow { none, ishraq, zawal, regular }

class ActivePrayerWindow extends Equatable {
  final String displayName;
  final DateTime startTime;
  final DateTime endTime;
  final SpiritualWindow windowType;
  final bool isCurrent;
  
  const ActivePrayerWindow({
    required this.displayName,
    required this.startTime,
    required this.endTime,
    this.windowType = SpiritualWindow.regular,
    this.isCurrent = false,
  });
  
  /// ✅ Factory: Calculate active window from PrayerTimes + current time
  factory ActivePrayerWindow.fromPrayerTimes({
    required PrayerTimes prayerTimes,
    required DateTime now,
    required Prayer currentPrayer,
  }) {
    // 🌙 Pre-Fajr check: adhan returns Prayer.isha after midnight,
    //    but if we're still before today's Fajr it's the night window.
    if (currentPrayer == Prayer.isha && now.isBefore(prayerTimes.fajr)) {
      final tomorrowFajr = prayerTimes.fajr.add(const Duration(days: 1));
      return ActivePrayerWindow(
        displayName: 'Fajr Preparations',
        startTime: prayerTimes.isha,
        endTime: tomorrowFajr,
        windowType: SpiritualWindow.none,
        isCurrent: true,
      );
    }

    // Regular prayer logic
    if (currentPrayer != Prayer.sunrise && currentPrayer != Prayer.none) {
      final startTime = prayerTimes.timeForPrayer(currentPrayer)!;
      return ActivePrayerWindow(
        displayName: _prayerToName(currentPrayer),
        startTime: startTime,
        endTime: _getNextPrayerTime(prayerTimes, currentPrayer),
        isCurrent: now.isAfter(startTime) && now.isBefore(_getNextPrayerTime(prayerTimes, currentPrayer)),
      );
    }
    
    // 🌅 Unified Ishraq/Chasht (Duha) logic
    if (currentPrayer == Prayer.sunrise) {
      final sunrise = prayerTimes.sunrise;
      final dhuhr = prayerTimes.dhuhr;
      
      final restrictionEnd = sunrise.add(const Duration(minutes: 20)); // Hanafi buffer
      final zawalStart = dhuhr.subtract(const Duration(minutes: 15)); // Zawal buffer
      
      if (now.isBefore(restrictionEnd)) {
        return ActivePrayerWindow(
          displayName: 'Sunrise',
          startTime: sunrise,
          endTime: restrictionEnd,
          windowType: SpiritualWindow.none, // Restricted
          isCurrent: true,
        );
      }
      
      if (now.isBefore(zawalStart)) {
        return ActivePrayerWindow(
          displayName: 'Duha',
          startTime: restrictionEnd,
          endTime: zawalStart,
          windowType: SpiritualWindow.ishraq,
          isCurrent: true,
        );
      }
      
      return ActivePrayerWindow(
        displayName: 'Zawal (Makruh)',
        startTime: zawalStart,
        endTime: dhuhr,
        windowType: SpiritualWindow.zawal,
        isCurrent: true,
      );
    }
    
    // 🌙 Post-Isha / Pre-Fajr — night window before next day's Fajr
    final tomorrowFajr = prayerTimes.fajr.add(const Duration(days: 1));
    return ActivePrayerWindow(
      displayName: 'Fajr Preparations',
      startTime: prayerTimes.isha,
      endTime: tomorrowFajr,
      windowType: SpiritualWindow.none,
      isCurrent: true,
    );
  }
  
  static String _prayerToName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr: return 'Fajr';
      case Prayer.sunrise: return 'Sunrise';
      case Prayer.dhuhr: return 'Dhuhr';
      case Prayer.asr: return 'Asr';
      case Prayer.maghrib: return 'Maghrib';
      case Prayer.isha: return 'Isha';
      default: return 'Fajr Preparations';
    }
  }
  
  static DateTime _getNextPrayerTime(PrayerTimes times, Prayer current) {
    // Simplified: return next prayer time or tomorrow's Fajr
    final prayers = [
      (Prayer.fajr, times.fajr),
      (Prayer.sunrise, times.sunrise),
      (Prayer.dhuhr, times.dhuhr),
      (Prayer.asr, times.asr),
      (Prayer.maghrib, times.maghrib),
      (Prayer.isha, times.isha),
    ];
    
    final currentIndex = prayers.indexWhere((p) => p.$1 == current);
    if (currentIndex < prayers.length - 1) {
      return prayers[currentIndex + 1].$2;
    }
    // Tomorrow's Fajr (simplified)
    return times.fajr.add(const Duration(days: 1));
  }
  
  @override
  List<Object?> get props => [displayName, startTime, endTime, windowType, isCurrent];
}
