import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan/adhan.dart';
import '../../../../core/services/prayer_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../settings/providers/settings_providers.dart';
import '../../settings/providers/location_providers.dart';

class PrayerData {
  final PrayerTimes prayerTimes;
  final String cityName;

  PrayerData({required this.prayerTimes, required this.cityName});
}

class PrayerDataNotifier extends AsyncNotifier<PrayerData> {
  final _prayerService = PrayerService.instance;
  final _supabaseService = SupabaseService.instance;

  @override
  Future<PrayerData> build() async {
    // 1. Watch settings & location - any change here triggers a re-calculate!
    final methodOption = ref.watch(calculationMethodProvider);
    final isHanafi = ref.watch(isHanafiProvider);
    final locationAsync = ref.watch(effectiveLocationProvider);

    // 2. Handle location state
    return locationAsync.when(
      loading: () => _handleLoading(),
      error: (err, stack) => Future.error(err, stack),
      data: (location) async {
        // location will always be non-null thanks to Mumbai fallback in LocationManager
        final activeLocation = location!;

        return _calculatePrayerData(
          lat: activeLocation.latitude,
          lon: activeLocation.longitude,
          method: methodOption.toAdhan(),
          madhab: isHanafi ? Madhab.hanafi : Madhab.shafi,
          cityName: activeLocation.displayAddress,
        );
      },
    );
  }

  /// Helper to keep the notifier in loading state while location is loading
  Future<PrayerData> _handleLoading() {
    // Return a future that won't complete until the next state update from ref.watch
    // Riverpod handles this automatically if we return a Future that doesn't complete,
    // but a cleaner way is to let the AsyncNotifier transition naturally.
    return Completer<PrayerData>().future; 
  }

  Future<PrayerData> _calculatePrayerData({
    required double lat,
    required double lon,
    required CalculationMethod method,
    required Madhab madhab,
    required String cityName,
  }) async {
    final user = _supabaseService.currentUser;
    
    // 1. Calculate Times
    final times = await _prayerService.getPrayerTimes(
      latitude: lat,
      longitude: lon,
      method: method,
      madhab: madhab,
    );

    // 2. Optional: Sync location to profile (background)
    if (user != null) {
      _supabaseService.updateUserProfile(
        userId: user.id,
        latitude: lat,
        longitude: lon,
      ).ignore();
    }

    // Note: Notifications are now managed by NotificationOrchestrator
    // which watches for location/settings changes and reschedules automatically.

    return PrayerData(prayerTimes: times, cityName: cityName);
  }
}

final prayerDataProvider = AsyncNotifierProvider<PrayerDataNotifier, PrayerData>(() {
  return PrayerDataNotifier();
});
