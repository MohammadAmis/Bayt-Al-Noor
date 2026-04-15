import '../../../../core/utils/location_service.dart';

/// Business entity representing calculated Qibla direction
class QiblaDirection {
  /// Direction in degrees from true north (0-360)
  final double degrees;
  
  /// Human-readable cardinal direction (N, NE, E, etc.)
  final String cardinal;
  
  /// Location where calculation was performed
  final LocationData userLocation;
  
  /// Timestamp of calculation
  final DateTime calculatedAt;

  QiblaDirection({
    required this.degrees,
    required this.cardinal,
    required this.userLocation,
    required this.calculatedAt,
  });

  /// Formatted string for display: "124.5° NE"
  String get formatted => '${degrees.toStringAsFixed(1)}° $cardinal';

  /// Check if direction is "close enough" to another (within threshold)
  bool isCloseTo(QiblaDirection other, {double thresholdDegrees = 2.0}) {
    final diff = (degrees - other.degrees).abs();
    // Handle wraparound at 360/0 boundary
    final normalizedDiff = diff > 180 ? 360 - diff : diff;
    return normalizedDiff <= thresholdDegrees;
  }

  QiblaDirection copyWith({
    double? degrees,
    String? cardinal,
    LocationData? userLocation,
    DateTime? calculatedAt,
  }) {
    return QiblaDirection(
      degrees: degrees ?? this.degrees,
      cardinal: cardinal ?? this.cardinal,
      userLocation: userLocation ?? this.userLocation,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  String toString() => 'QiblaDirection($formatted at $calculatedAt)';
}