import 'package:adhan/adhan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/prayer_data_provider.dart';

/// ✅ Stream that emits remaining duration every second
final countdownStreamProvider = StreamProvider.family<Duration, Prayer>((ref, nextPrayer) {
  // Get prayer times from existing provider
  final prayerData = ref.watch(prayerDataProvider).value;
  if (prayerData == null || nextPrayer == Prayer.none) {
    return Stream.value(Duration.zero);
  }
  
  final nextTime = prayerData.prayerTimes.timeForPrayer(nextPrayer)!;
  
  // Emit updated duration every second
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now())
      .map((now) => nextTime.difference(now))
      .takeWhile((duration) => duration.inSeconds > 0); // Stop when prayer time arrives
});