import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

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

  const QiblaState({
    this.direction,
    this.deviceHeading,
    this.isLoading = false,
    this.error,
    this.isCalibrating = false,
  });

  QiblaState copyWith({
    QiblaDirection? direction,
    double? deviceHeading,
    bool? isLoading,
    String? error,
    bool? isCalibrating,
  }) {
    return QiblaState(
      direction: direction ?? this.direction,
      deviceHeading: deviceHeading ?? this.deviceHeading,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isCalibrating: isCalibrating ?? this.isCalibrating,
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
  final LocationService _locationService = GeolocatorLocationService();

  QiblaNotifier(this._ref) : super(const QiblaState());

  /// Initialize Qibla using your EXISTING AppLocation provider
  Future<void> initialize() async {
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

      // Start compass heading listener for real-time rotation
      _startHeadingListener();
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
    _headingSubscription?.cancel();

    // Compass not reliable on web - use static heading
    if (_isWeb()) {
      state = state.copyWith(deviceHeading: 0.0);
      return;
    }

    _headingSubscription = _locationService.headingStream
        .debounceTime(
            const Duration(milliseconds: 100)) // Throttle for performance
        .listen(
          (heading) => state = state.copyWith(deviceHeading: heading),
          onError: (_) => state = state.copyWith(deviceHeading: 0.0),
        );
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
    super.dispose();
  }
}
