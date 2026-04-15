import '../entities/qibla_direction.dart';

/// Abstract repository interface for Qibla-related operations
/// Follows Dependency Inversion Principle for testability
abstract class QiblaRepository {
  /// Calculate Qibla direction for given coordinates
  /// 
  /// Throws [Exception] if calculation fails
  Future<QiblaDirection> calculateQibla({
    required double latitude,
    required double longitude,
  });

  /// Get cached Qibla direction if available and recent (< 1 hour)
  Future<QiblaDirection?> getCachedQibla();

  /// Cache the calculated direction for offline use
  Future<void> cacheQibla(QiblaDirection direction);

  /// Clear cached direction data
  Future<void> clearCache();
}