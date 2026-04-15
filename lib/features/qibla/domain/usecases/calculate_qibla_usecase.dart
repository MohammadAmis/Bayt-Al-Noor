import '../entities/qibla_direction.dart';
import '../repositories/qibla_repository.dart';
import 'dart:math' as math;

/// Use case: Calculate Qibla direction with caching strategy
/// 
/// Business rules:
/// - Use cache if < 1 hour old and location hasn't changed significantly
/// - Recalculate if location changed by > 1km or cache expired
/// - Always return fresh calculation if forceRefresh = true
class CalculateQiblaUseCase {
  final QiblaRepository _repository;
  static const double _locationChangeThreshold = 1.0; // km
  static const Duration _cacheValidity = Duration(hours: 1);

  CalculateQiblaUseCase(this._repository);

  Future<QiblaDirection> call({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _repository.getCachedQibla();
      if (cached != null && _isCacheValid(cached, latitude, longitude)) {
        return cached;
      }
    }

    final direction = await _repository.calculateQibla(
      latitude: latitude,
      longitude: longitude,
    );
    
    await _repository.cacheQibla(direction);
    return direction;
  }

  bool _isCacheValid(
    QiblaDirection cached,
    double newLat,
    double newLon,
  ) {
    // Check time validity
    if (DateTime.now().difference(cached.calculatedAt) > _cacheValidity) {
      return false;
    }
    
    // Check location change using Haversine approximation
    final distance = _calculateDistance(
      cached.userLocation.latitude,
      cached.userLocation.longitude,
      newLat,
      newLon,
    );
    
    return distance <= _locationChangeThreshold;
  }

  /// Approximate distance between two coordinates in kilometers
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    
    final a = 
        _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRad(lat1)) * _cos(_toRad(lat2)) * 
        _sin(dLon / 2) * _sin(dLon / 2);
    
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  // Math helpers for Haversine
  double _toRad(double deg) => deg * math.pi / 180;
  double _sin(double x) => math.sin(x);  // ✅ Use math.sin(x)
  double _cos(double x) => math.cos(x);  // ✅ Use math.cos(x)
  double _atan2(double y, double x) => math.atan2(y, x); // ✅ Use math.atan2
  double _sqrt(double x) => math.sqrt(x); // ✅ Use math.sqrt
}