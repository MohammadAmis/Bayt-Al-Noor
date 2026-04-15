// currently it is not used anywhere in code

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../../../core/utils/location_service.dart';

/// Local data source for GPS and compass sensor data
/// Handles direct interaction with device hardware
class LocalGpsSource {
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
    timeLimit: Duration(seconds: 30),
  );

  /// Stream of location updates from device GPS
  Stream<LocationData> get locationStream {
    return Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).map((position) => LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          altitude: position.altitude,
          heading: position.heading,
          speed: position.speed,
          timestamp: position.timestamp,
        )).handleError((error) {
      // Log error in production
      throw LocalDataSourceException('GPS error: $error');
    });
  }

  /// Stream of compass heading updates (degrees from magnetic north)
  Stream<double> get headingStream {
    final compassStream = FlutterCompass.events;
    
    if (compassStream == null) {
      // Fallback: use GPS heading if compass unavailable
      return Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      )
          .where((event) => event.heading != null)
          .map((event) => event.heading!)
          .handleError((_) => 0.0);
    }
    
    return compassStream
        .map((event) => event.heading ?? 0.0)
        .debounce(const Duration(milliseconds: 100))
        .handleError((error) {
      // Compass may not be available on all devices
      return 0.0;
    });
  }

  /// Get current location once with timeout
  Future<LocationData> getCurrentLocation({Duration? timeout}) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      ).timeout(timeout ?? const Duration(seconds: 15));

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        heading: position.heading,
        speed: position.speed,
        timestamp: position.timestamp,
      );
    } on TimeoutException {
      throw LocalDataSourceException('Location request timed out');
    } on PositionSourceException {
      throw LocalDataSourceException('GPS signal unavailable');
    } catch (error) {
      throw LocalDataSourceException('Failed to get location: $error');
    }
  }

  /// Check if location services are enabled on device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request runtime permissions for location access
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Open device location settings (Android/iOS)
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}

/// Exception class for local data source errors
class LocalDataSourceException implements Exception {
  final String message;
  final dynamic error;

  LocalDataSourceException(this.message, [this.error]);

  @override
  String toString() => 'LocalDataSourceException: $message';
}

/// Extension for debouncing streams (simple implementation)
/// In production, use rxdart package for robust implementation
extension StreamExtensions<T> on Stream<T> {
  Stream<T> debounce(Duration duration) {
    return transform(StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        // Simple debounce: just pass through (replace with rxdart for production)
        sink.add(data);
      },
    ));
  }
}