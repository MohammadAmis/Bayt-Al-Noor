import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

/// Abstraction for location and compass sensor access
/// Enables testing via dependency injection
abstract class LocationService {
  /// Stream of location updates with configurable accuracy
  Stream<LocationData> get locationStream;
  
  /// Stream of device heading (compass) in degrees from magnetic north
  Stream<double> get headingStream;
  
  /// Request runtime permissions for location access
  Future<bool> requestPermissions();
  
  /// Get current location once (with timeout)
  Future<LocationData?> getCurrentLocation({Duration? timeout});
  
  /// Check if location services are enabled on device
  Future<bool> isLocationServiceEnabled();
}

/// Implementation using geolocator + flutter_compass packages
class GeolocatorLocationService implements LocationService {
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Only update if moved 10+ meters
  );

  @override
  Stream<LocationData> get locationStream =>
      Geolocator.getPositionStream(locationSettings: _locationSettings)
          .map((position) => LocationData(
                latitude: position.latitude,
                longitude: position.longitude,
                accuracy: position.accuracy,
              ));

  @override
  Stream<double> get headingStream => FlutterCompass.events
          ?.map((event) => event.heading ?? 0.0)
          .handleError((_) => 0.0) ??
      Stream.value(0.0); // Fallback if compass unavailable

  @override
  Future<bool> requestPermissions() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.whileInUse ||
           permission == LocationPermission.always;
  }

  @override
  Future<LocationData?> getCurrentLocation({Duration? timeout}) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      ).timeout(timeout ?? const Duration(seconds: 15));
      
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}

/// Immutable location data model
class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy; // in meters

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });

  LocationData copyWith({double? latitude, double? longitude, double? accuracy}) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationData &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}