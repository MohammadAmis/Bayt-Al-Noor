import 'dart:math' as math;

/// Pure function utility for calculating Qibla direction
/// Uses the great circle method (spherical trigonometry)
class QiblaCalculator {
  /// Kaaba coordinates (Mecca, Saudi Arabia)
  static const double kaabaLat = 21.422524;
  static const double kaabaLon = 39.826189;

  /// Calculate Qibla direction from user location
  /// Returns degrees from true north (0-360, clockwise)
  static double calculate({
    required double userLat,
    required double userLon,
    double? kaabaLat,
    double? kaabaLon,
  }) {
    final kLat = kaabaLat ?? QiblaCalculator.kaabaLat;
    final kLon = kaabaLon ?? QiblaCalculator.kaabaLon;

    // Convert degrees to radians
    final phi1 = _toRadians(userLat);
    final lambda1 = _toRadians(userLon);
    final phi2 = _toRadians(kLat);
    final lambda2 = _toRadians(kLon);

    final deltaLambda = lambda2 - lambda1;

    // Great circle bearing formula
    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
              math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);
    
    var theta = _toDegrees(math.atan2(y, x));
    
    // Normalize to 0-360 range
    return (theta + 360) % 360;
  }

  /// Convert degrees to cardinal direction (8-point compass)
  static String getCardinalDirection(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  /// Helper: Degrees to Radians
  static double _toRadians(double degrees) => degrees * math.pi / 180;
  
  /// Helper: Radians to Degrees  
  static double _toDegrees(double radians) => radians * 180 / math.pi;
}