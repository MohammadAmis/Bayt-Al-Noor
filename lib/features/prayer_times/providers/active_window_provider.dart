import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/active_prayer_window.dart';
import '../../home/domain/prayer_data_provider.dart';

final activePrayerWindowProvider = Provider<ActivePrayerWindow>((ref) {
  final prayerData = ref.watch(prayerDataProvider).value;
  if (prayerData == null) {
    // Fallback
    return ActivePrayerWindow(
      displayName: 'Loading...',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
    );
  }
  
  final now = DateTime.now();
  final currentPrayer = prayerData.prayerTimes.currentPrayer();
  
  return ActivePrayerWindow.fromPrayerTimes(
    prayerTimes: prayerData.prayerTimes,
    now: now,
    currentPrayer: currentPrayer,
  );
});
