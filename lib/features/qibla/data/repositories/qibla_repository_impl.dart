import '../../domain/entities/qibla_direction.dart';
import '../../domain/repositories/qibla_repository.dart';
import '../../../../core/utils/qibla_calculator.dart';
import '../../../../core/utils/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Concrete implementation with caching via SharedPreferences
class QiblaRepositoryImpl implements QiblaRepository {
  final LocationService _locationService;
  static const String _cacheKey = 'qibla_cache_v1';

  QiblaRepositoryImpl(this._locationService);

  @override
  Future<QiblaDirection> calculateQibla({
    required double latitude,
    required double longitude,
  }) async {
    // Validate coordinates
    if (!_isValidCoordinate(latitude, longitude)) {
      throw ArgumentError('Invalid coordinates: $latitude, $longitude');
    }

    final degrees = QiblaCalculator.calculate(
      userLat: latitude,
      userLon: longitude,
    );

    return QiblaDirection(
      degrees: degrees,
      cardinal: QiblaCalculator.getCardinalDirection(degrees),
      userLocation: LocationData(
        latitude: latitude,
        longitude: longitude,
      ),
      calculatedAt: DateTime.now(),
    );
  }

  @override
  Future<QiblaDirection?> getCachedQibla() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      
      if (jsonString == null) return null;
      
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final location = LocationData(
        latitude: json['latitude'] as double,
        longitude: json['longitude'] as double,
      );
      
      return QiblaDirection(
        degrees: json['degrees'] as double,
        cardinal: json['cardinal'] as String,
        userLocation: location,
        calculatedAt: DateTime.parse(json['calculatedAt'] as String),
      );
    } catch (_) {
      // Silently fail on cache read errors
      return null;
    }
  }

  @override
  Future<void> cacheQibla(QiblaDirection direction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = {
        'degrees': direction.degrees,
        'cardinal': direction.cardinal,
        'latitude': direction.userLocation.latitude,
        'longitude': direction.userLocation.longitude,
        'calculatedAt': direction.calculatedAt.toIso8601String(),
      };
      
      await prefs.setString(_cacheKey, jsonEncode(json));
    } catch (_) {
      // Silently fail on cache write errors - not critical
    }
  }

  @override
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  bool _isValidCoordinate(double lat, double lon) {
    return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
  }
}