import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_providers.dart';

// ============================================================================
// 🗂️ Models
// ============================================================================

/// ✅ Location data with metadata
class AppLocation {
  final double latitude;
  final double longitude;
  final String? address;        // Human-readable (e.g., "London, UK")
  final String? countryCode;    // ISO code (e.g., "GB")
  final DateTime timestamp;     // When this location was obtained
  final LocationSource source;  // How we got this location
  
  const AppLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.countryCode,
    required this.timestamp,
    required this.source,
  });
  
  /// Create from Position (geolocator)
  factory AppLocation.fromPosition(Position position, {String? address}) {
    return AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address,
      timestamp: DateTime.now(),
      source: LocationSource.gps,
    );
  }
  
  /// Create from manual input
  factory AppLocation.fromManual({
    required double latitude,
    required double longitude,
    String? address,
  }) {
    return AppLocation(
      latitude: latitude,
      longitude: longitude,
      address: address,
      timestamp: DateTime.now(),
      source: LocationSource.manual,
    );
  }
  
  /// Check if location is "fresh" (within threshold)
  bool isFresh(Duration threshold) {
    return DateTime.now().difference(timestamp) < threshold;
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLocation &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          source == other.source;
  
  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode ^ source.hashCode;
}

/// ✅ Source of location data
enum LocationSource {
  gps,           // From device GPS
  network,       // From network/WiFi
  manual,        // User-entered
  cached,        // From local storage
  fallback,      // Default/last known
}

// ============================================================================
// 🔄 State Notifier: Location Manager
// ============================================================================

/// ✅ Main location provider - handles permissions, fetching, caching
final locationManagerProvider = StateNotifierProvider<LocationManager, AsyncValue<AppLocation?>>((ref) {
  return LocationManager(
    repository: ref.watch(locationRepositoryProvider),
    useAutoLocation: ref.watch(useAutoLocationProvider),
    manualLocationName: ref.watch(manualLocationNameProvider),
  );
});

class LocationManager extends StateNotifier<AsyncValue<AppLocation?>> {
  final LocationRepository _repository;
  final bool _useAutoLocation;
  final String? _manualLocationName;
  StreamSubscription<Position>? _positionStream;
  
  LocationManager({
    required LocationRepository repository,
    required bool useAutoLocation,
    required String? manualLocationName,
  })  : _repository = repository,
        _useAutoLocation = useAutoLocation,
        _manualLocationName = manualLocationName,
        super(const AsyncValue.loading()) {
    _initialize();
  }
  
  Future<void> _initialize() async {
    if (_useAutoLocation) {
      await _fetchAutoLocation();
      // Optional: Start listening to location updates (battery consideration)
      // _startLocationUpdates();
    } else {
      await _fetchManualLocation();
    }
  }
  
  /// Fetch location using device GPS/network
  Future<void> _fetchAutoLocation() async {
    try {
      state = const AsyncValue.loading();
      
      // Check if we have valid cached location
      final cached = await _repository.getCachedLocation();
      if (cached != null && cached.isFresh(const Duration(hours: 1))) {
        state = AsyncValue.data(cached);
        // Still fetch fresh in background
        unawaited(_fetchFreshAutoLocation());
        return;
      }
      
      // Fetch fresh location
      final fresh = await _fetchFreshAutoLocation();
      if (fresh != null) {
        state = AsyncValue.data(fresh);
      }
    } catch (error, stack) {
      // Fallback to cached if available
      final cached = await _repository.getCachedLocation();
      if (cached != null) {
        state = AsyncValue.data(cached.copyWith(source: LocationSource.fallback));
      } else {
        state = AsyncValue.error(error, stack);
      }
    }
  }
  
  /// Actually fetch from geolocator (separate method for background refresh)
  Future<AppLocation?> _fetchFreshAutoLocation() async {
    // Check permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }
    
    // Get position with reasonable accuracy vs battery tradeoff
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );
    
    // Reverse geocode for address (optional, non-blocking)
    String? address;
    String? countryCode;
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude,
      ).timeout(const Duration(seconds: 5));
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address = [place.locality, place.administrativeArea, place.country]
            .where((s) => s?.isNotEmpty == true)
            .join(', ');
        countryCode = place.isoCountryCode;
      }
    } catch (_) {
      // Address is optional - don't fail if geocoding times out
    }
    
    final location = AppLocation.fromPosition(position, address: address)
        .copyWith(countryCode: countryCode);
    
    // Cache the result
    await _repository.cacheLocation(location);
    
    return location;
  }
  
  /// Fetch location based on manual input
  Future<void> _fetchManualLocation() async {
    try {
      state = const AsyncValue.loading();
      
      // If user entered coordinates directly
      if (_manualLocationName != null && _isCoordinates(_manualLocationName)) {
        final coords = _parseCoordinates(_manualLocationName);
        final location = AppLocation.fromManual(
          latitude: coords.$1,
          longitude: coords.$2,
          address: _manualLocationName,
        );
        await _repository.cacheLocation(location);
        state = AsyncValue.data(location);
        return;
      }
      
      // If user entered city name, geocode it
      if (_manualLocationName != null && _manualLocationName.isNotEmpty) {
        final locations = await locationFromAddress(_manualLocationName)
            .timeout(const Duration(seconds: 10));
        
        if (locations.isNotEmpty) {
          final location = locations.first;
          final appLocation = AppLocation.fromManual(
            latitude: location.latitude,
            longitude: location.longitude,
            address: _manualLocationName,
          );
          await _repository.cacheLocation(appLocation);
          state = AsyncValue.data(appLocation);
          return;
        }
      }
      
      // Fallback: try to get last known location
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        final location = AppLocation.fromPosition(lastKnown)
            .copyWith(source: LocationSource.fallback);
        state = AsyncValue.data(location);
        return;
      }
      
      // Ultimate fallback: default to Makkah
      final defaultLocation = AppLocation(
        latitude: 21.4225,
        longitude: 39.8262,
        address: 'Makkah, Saudi Arabia',
        countryCode: 'SA',
        timestamp: DateTime.now(),
        source: LocationSource.fallback,
      );
      state = AsyncValue.data(defaultLocation);
      
    } catch (error) {
      // Fallback to default
      final defaultLocation = AppLocation(
        latitude: 21.4225,
        longitude: 39.8262,
        address: 'Makkah, Saudi Arabia',
        countryCode: 'SA',
        timestamp: DateTime.now(),
        source: LocationSource.fallback,
      );
      state = AsyncValue.data(defaultLocation);
    }
  }
  
  /// Refresh location (called by pull-to-refresh)
  Future<void> refresh() async {
    if (_useAutoLocation) {
      await _fetchFreshAutoLocation();
    } else {
      await _fetchManualLocation();
    }
  }
  
  /// Check if string looks like coordinates: "51.5074, -0.1278"
  bool _isCoordinates(String input) {
    final pattern = RegExp(r'^-?\d+\.?\d*,\s*-?\d+\.?\d*$');
    return pattern.hasMatch(input.trim());
  }
  
  /// Parse "lat, lng" string to tuple
  (double, double) _parseCoordinates(String input) {
    final parts = input.split(',').map((s) => double.parse(s.trim())).toList();
    return (parts[0], parts[1]);
  }
  
  /// Update manual location name (triggers recalculation)
  Future<void> updateManualLocation(String? name) async {
    // This would be called from settings UI
    // Invalidate to trigger rebuild with new manual location
    state = const AsyncValue.loading();
    await _fetchManualLocation();
  }
  
  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}

// ============================================================================
// 🗄️ Repository: Location Persistence
// ============================================================================

/// ✅ Abstract repository for location data
abstract class LocationRepository {
  /// Get cached location (if any)
  Future<AppLocation?> getCachedLocation();
  
  /// Cache a location for later use
  Future<void> cacheLocation(AppLocation location);
  
  /// Clear cached location
  Future<void> clearCachedLocation();
  
  /// Get user's preferred location source setting
  Future<bool> getUseAutoLocation();
  
  /// Get manual location name (if set)
  Future<String?> getManualLocationName();
}

/// ✅ SharedPreferences implementation
class SharedPreferencesLocationRepository implements LocationRepository {
  static const _prefix = 'location_';
  
  @override
  Future<AppLocation?> getCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    
    final lat = prefs.getDouble('${_prefix}latitude');
    final lng = prefs.getDouble('${_prefix}longitude');
    final address = prefs.getString('${_prefix}address');
    final countryCode = prefs.getString('${_prefix}countryCode');
    final timestampMs = prefs.getInt('${_prefix}timestamp');
    final sourceIndex = prefs.getInt('${_prefix}source');
    
    if (lat == null || lng == null || timestampMs == null || sourceIndex == null) {
      return null;
    }
    
    return AppLocation(
      latitude: lat,
      longitude: lng,
      address: address,
      countryCode: countryCode,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
      source: LocationSource.values[sourceIndex],
    );
  }
  
  @override
  Future<void> cacheLocation(AppLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('${_prefix}latitude', location.latitude);
    await prefs.setDouble('${_prefix}longitude', location.longitude);
    if (location.address != null) {
      await prefs.setString('${_prefix}address', location.address!);
    }
    if (location.countryCode != null) {
      await prefs.setString('${_prefix}countryCode', location.countryCode!);
    }
    await prefs.setInt('${_prefix}timestamp', location.timestamp.millisecondsSinceEpoch);
    await prefs.setInt('${_prefix}source', location.source.index);
  }
  
  @override
  Future<void> clearCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_prefix}latitude');
    await prefs.remove('${_prefix}longitude');
    await prefs.remove('${_prefix}address');
    await prefs.remove('${_prefix}countryCode');
    await prefs.remove('${_prefix}timestamp');
    await prefs.remove('${_prefix}source');
  }
  
  @override
  Future<bool> getUseAutoLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_prefix}use_auto') ?? true;
  }
  
  @override
  Future<String?> getManualLocationName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${_prefix}manual_name');
  }
}

/// ✅ Repository provider
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return SharedPreferencesLocationRepository();
});

// ============================================================================
// 🎯 Simplified Providers for UI Consumption
// ============================================================================

/// ✅ Current location (simplified - just the AppLocation or null)
final locationProvider = Provider<AsyncValue<AppLocation?>>((ref) {
  return ref.watch(locationManagerProvider);
});

/// ✅ Location refresh trigger (for pull-to-refresh)
final refreshLocationProvider = Provider<Future<void> Function()>((ref) {
  return () => ref.read(locationManagerProvider.notifier).refresh();
});

/// ✅ Permission status provider
final locationPermissionProvider = FutureProvider<LocationPermission>((ref) {
  return Geolocator.checkPermission();
});

/// ✅ Helper: Check if location services are enabled
final locationServicesEnabledProvider = FutureProvider<bool>((ref) async {
  return await Geolocator.isLocationServiceEnabled();
});

/// ✅ Helper: Request location permission (returns result)
final requestLocationPermissionProvider = FutureProvider<LocationPermission>((ref) async {
  return await Geolocator.requestPermission();
});

// ============================================================================
// 🔄 Extensions for Easy Usage
// ============================================================================

extension AppLocationX on AppLocation {
  /// Create a copy with updated fields
  AppLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? countryCode,
    DateTime? timestamp,
    LocationSource? source,
  }) {
    return AppLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      countryCode: countryCode ?? this.countryCode,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
    );
  }
  
  /// Format coordinates for display: "51.5074°N, 0.1278°W"
  String get formattedCoordinates {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lngDir = longitude >= 0 ? 'E' : 'W';
    return '${latitude.abs().toStringAsFixed(4)}°$latDir, ${longitude.abs().toStringAsFixed(4)}°$lngDir';
  }
  
  /// Get short address for UI display
  String get displayAddress {
    return address ?? formattedCoordinates;
  }
}

// ============================================================================
// 🧪 Testing Helper: Mock Location for Development
// ============================================================================

/// ✅ Override provider for testing/demo mode
final mockLocationProvider = Provider<AppLocation?>((ref) => null);

/// ✅ Combined provider that uses mock if set, otherwise real location
final effectiveLocationProvider = Provider<AsyncValue<AppLocation?>>((ref) {
  final mock = ref.watch(mockLocationProvider);
  if (mock != null) {
    return AsyncValue.data(mock);
  }
  return ref.watch(locationProvider);
});