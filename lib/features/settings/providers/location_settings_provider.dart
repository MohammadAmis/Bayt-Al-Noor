import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

/// ✅ User preference: Auto vs Manual location
final useAutoLocationProvider = StateNotifierProvider<UseAutoLocationNotifier, bool>((ref) {
  return UseAutoLocationNotifier();
});

class UseAutoLocationNotifier extends StateNotifier<bool> {
  UseAutoLocationNotifier() : super(true) {
    _load();
  }
  
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('settings_use_auto_location') ?? true;
  }
  
  Future<void> toggle(bool useAuto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_use_auto_location', useAuto);
    state = useAuto;
  }
}

/// ✅ Manual location name (city or coordinates)
final manualLocationNameProvider = StateNotifierProvider<ManualLocationNameNotifier, String?>((ref) {
  return ManualLocationNameNotifier();
});

class ManualLocationNameNotifier extends StateNotifier<String?> {
  ManualLocationNameNotifier() : super(null) {
    _load();
  }
  
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('settings_manual_location_name');
  }
  
  Future<void> update(String? name) async {
    final prefs = await SharedPreferences.getInstance();
    if (name == null || name.isEmpty) {
      await prefs.remove('settings_manual_location_name');
    } else {
      await prefs.setString('settings_manual_location_name', name);
    }
    state = name?.isEmpty == true ? null : name;
  }
}

/// ✅ Location accuracy preference (for battery vs precision tradeoff)
enum LocationAccuracyPreference {
  low,      // ~100m accuracy, best battery
  medium,   // ~10m accuracy, balanced (default)
  high,     // ~1m accuracy, highest battery use
}

final locationAccuracyProvider = StateNotifierProvider<LocationAccuracyNotifier, LocationAccuracyPreference>((ref) {
  return LocationAccuracyNotifier();
});

class LocationAccuracyNotifier extends StateNotifier<LocationAccuracyPreference> {
  LocationAccuracyNotifier() : super(LocationAccuracyPreference.medium) {
    _load();
  }
  
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('settings_location_accuracy') ?? LocationAccuracyPreference.medium.index;
    state = LocationAccuracyPreference.values[index];
  }
  
  Future<void> update(LocationAccuracyPreference accuracy) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('settings_location_accuracy', accuracy.index);
    state = accuracy;
  }
  
  /// Convert to geolocator's LocationAccuracy
  LocationAccuracy toGeolocatorAccuracy() {
    switch (state) {
      case LocationAccuracyPreference.low:
        return LocationAccuracy.low;
      case LocationAccuracyPreference.medium:
        return LocationAccuracy.medium;
      case LocationAccuracyPreference.high:
        return LocationAccuracy.high;
    }
  }
}