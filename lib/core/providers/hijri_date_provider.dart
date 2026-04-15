import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/hijri_date_formatter.dart';
import 'app_preferences_provider.dart';

/// ✅ Returns formatted Hijri date if enabled, else null
final hijriDateDisplayProvider = Provider<String?>((ref) {
  final showHijri = ref.watch(showHijriDateProvider);
  if (!showHijri) return null;
  return HijriDateFormatter.format(DateTime.now());
});

/// ✅ For individual prayer times
final hijriPrayerDateProvider = Provider.family<String?, DateTime>((ref, prayerTime) {
  final showHijri = ref.watch(showHijriDateProvider);
  if (!showHijri) return null;
  return HijriDateFormatter.formatCompact(prayerTime);
});
