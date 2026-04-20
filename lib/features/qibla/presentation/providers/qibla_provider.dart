import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;

// ✅ Domain
import '../../domain/entities/qibla_direction.dart';

// ✅ Core utilities
import '../../../../core/utils/qibla_calculator.dart';
import '../../../../core/utils/location_service.dart'; // For LocationData

// ✅ Your EXISTING location provider (AppLocation)
import '../../../settings/providers/location_providers.dart';

/// Immutable state for Qibla feature UI
class QiblaState {
  final QiblaDirection? direction;
  final double? deviceHeading;
  final bool isLoading;
  final String? error;
  final bool isCalibrating;
  final bool isTilted; // Add tilt state

  const QiblaState({
    this.direction,
    this.deviceHeading,
    this.isLoading = false,
    this.error,
    this.isCalibrating = false,
    this.isTilted = false,
  });

  QiblaState copyWith({
    QiblaDirection? direction,
    double? deviceHeading,
    bool? isLoading,
    String? error,
    bool? isCalibrating,
    bool? isTilted,
  }) {
    return QiblaState(
      direction: direction ?? this.direction,
      deviceHeading: deviceHeading ?? this.deviceHeading,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isCalibrating: isCalibrating ?? this.isCalibrating,
      isTilted: isTilted ?? this.isTilted,
    );
  }
}

/// Provider for Qibla state management
final qiblaProvider = StateNotifierProvider<QiblaNotifier, QiblaState>((ref) {
  return QiblaNotifier(ref);
});

/// State notifier handling Qibla logic using your AppLocation
class QiblaNotifier extends StateNotifier<QiblaState> {
  final Ref _ref;
  StreamSubscription<double>? _headingSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final LocationService _locationService = GeolocatorLocationService();

  QiblaNotifier(this._ref) : super(const QiblaState());

  /// Initialize Qibla using your EXISTING AppLocation provider
  Future<void> initialize({bool force = false}) async {
    // Prevent redundant initialization if already loaded/loading
    if (!force && state.direction != null && !state.isLoading) {
      _startHeadingListener(); // Just ensure listener is running
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // ✅ Read your existing provider: Provider<AsyncValue<AppLocation?>>
      final locationAsync = _ref.read(locationProvider);

      // ✅ Extract AppLocation? from AsyncValue
      final appLocation = locationAsync.value;

      if (appLocation == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location not available. Please enable GPS on Home page.',
        );
        return;
      }

      // ✅ Calculate Qibla using AppLocation fields
      final degrees = QiblaCalculator.calculate(
        userLat: appLocation.latitude,
        userLon: appLocation.longitude,
      );

      // ✅ Convert AppLocation → LocationData for QiblaDirection
      final locationData = LocationData(
        latitude: appLocation.latitude,
        longitude: appLocation.longitude,
        // Add accuracy if needed: appLocation.source == LocationSource.gps ? 10.0 : null
      );

      state = state.copyWith(
        direction: QiblaDirection(
          degrees: degrees,
          cardinal: QiblaCalculator.getCardinalDirection(degrees),
          userLocation: locationData,
          calculatedAt: DateTime.now(),
        ),
        isLoading: false,
        error: null,
      );

      // Start sensors for real-time interaction
      _startHeadingListener();
      _startTiltListener();
    } catch (e) {
      // In production: log to FirebaseCrashlytics
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to calculate Qibla: ${e.toString()}',
      );
    }
  }

  /// Listen to compass heading for real-time needle rotation
  void _startHeadingListener() {
    if (_headingSubscription != null) return; // Already listening

    // Compass not reliable on web - use static heading
    if (_isWeb()) {
      state = state.copyWith(deviceHeading: 0.0);
      return;
    }

    _headingSubscription = _locationService.headingStream
        .scan<Map<String, double>>((acc, heading, _) {
          // Trigonometric smoothing to handle circular wrap-around (0/360)
          const double alpha = 0.15; // Smoothing factor (lower = smoother)
          final double rad = heading * math.pi / 180;
          
          final double sin = (acc['sin'] ?? math.sin(rad)) * (1 - alpha) + math.sin(rad) * alpha;
          final double cos = (acc['cos'] ?? math.cos(rad)) * (1 - alpha) + math.cos(rad) * alpha;
          
          return {'sin': sin, 'cos': cos};
        }, {})
        .map((acc) {
          final double heading = math.atan2(acc['sin']!, acc['cos']!) * 180 / math.pi;
          return (heading + 360) % 360;
        })
        .listen(
          (smoothedHeading) => state = state.copyWith(deviceHeading: smoothedHeading),
          onError: (_) => state = state.copyWith(deviceHeading: 0.0),
        );
  }

  /// Listen to accelerometer to detect if device is held flat
  void _startTiltListener() {
    _accelerometerSubscription?.cancel();
    
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      // Calculate tilt angle from gravity vector
      // When flat, Z is ~9.8. When vertical, Z is ~0.
      final double x = event.x;
      final double y = event.y;
      final double z = event.z;
      
      // Calculate overall tilt in degrees
      final double g = math.sqrt(x * x + y * y + z * z);
      if (g == 0) return;
      
      final double cosTilt = z / g;
      final double tiltDegrees = math.acos(cosTilt.clamp(-1.0, 1.0)) * 180 / math.pi;
      
      // We consider it "tilted" if more than 25 degrees from horizontal
      final bool isTiltedNow = tiltDegrees > 25.0;
      
      if (state.isTilted != isTiltedNow) {
        state = state.copyWith(isTilted: isTiltedNow);
      }
    });
  }

  /// Manual recalibration (user tapped refresh)
  Future<void> recalibrate() async {
    state = state.copyWith(isCalibrating: true, error: null);

    try {
      // Small delay for UI feedback
      await Future.delayed(const Duration(milliseconds: 200));

      // Re-read location (in case user moved)
      await _ref.read(locationManagerProvider.notifier).refresh();

      // Re-initialize with fresh location
      await initialize();
    } catch (e) {
      state = state.copyWith(
        error: 'Recalibration failed: ${e.toString()}',
      );
    } finally {
      state = state.copyWith(isCalibrating: false);
    }
  }

  /// Use manually entered location (web fallback)
  Future<void> useManualLocation(double latitude, double longitude,
      {String? address}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final appLocation = AppLocation.fromManual(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );

      final degrees = QiblaCalculator.calculate(
        userLat: appLocation.latitude,
        userLon: appLocation.longitude,
      );

      final locationData = LocationData(
        latitude: appLocation.latitude,
        longitude: appLocation.longitude,
      );

      state = state.copyWith(
        direction: QiblaDirection(
          degrees: degrees,
          cardinal: QiblaCalculator.getCardinalDirection(degrees),
          userLocation: locationData,
          calculatedAt: DateTime.now(),
        ),
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid coordinates: ${e.toString()}',
      );
    }
  }

  /// Check if running on web (for conditional logic)
  bool _isWeb() {
    return const bool.fromEnvironment('dart.library.js_util');
  }

  /// Cleanup: Cancel sensor subscriptions
  @override
  void dispose() {
    _headingSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }
}
