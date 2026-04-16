import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../../../core/utils/location_service.dart';

/// Local data source for GPS and compass sensor data
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
        )).handleError((error) {
      throw LocalDataSourceException('GPS error: $error');
    });
  }

  /// Stream of compass heading updates
  Stream<double> get headingStream {
    final compassStream = FlutterCompass.events;
    
    if (compassStream == null) {
      return Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      )
          .map((event) => event.heading)
          .handleError((_) => 0.0);
    }
    
    return compassStream
        .map((event) => event.heading ?? 0.0)
        .debounce(const Duration(milliseconds: 100))
        .handleError((error) {
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
      );
    } on TimeoutException {
      throw LocalDataSourceException('Location request timed out');
    } catch (error) {
      throw LocalDataSourceException('Failed to get location: $error');
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}

class LocalDataSourceException implements Exception {
  final String message;
  final dynamic error;

  LocalDataSourceException(this.message, [this.error]);

  @override
  String toString() => 'LocalDataSourceException: $message';
}

extension StreamExtensions<T> on Stream<T> {
  Stream<T> debounce(Duration duration) {
    return transform(StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        sink.add(data);
      },
    ));
  }
}