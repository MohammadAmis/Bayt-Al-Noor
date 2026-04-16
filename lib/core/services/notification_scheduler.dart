import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart' as adhan;
import '../services/notification_service.dart';
import '../../features/settings/providers/location_providers.dart';
import '../../features/settings/domain/entities/calculation_method.dart';

/// ✅ Orchestrates notification scheduling with debouncing & error handling
class NotificationScheduler {
  final NotificationService _notificationService;
  Timer? _debounceTimer;
  bool _isRescheduling = false;

  NotificationScheduler(this._notificationService);

  /// Reschedules all prayer notifications based on current settings
  Future<void> reschedule({
    required AppLocation location,
    required CalculationMethodOption method,
    required bool enabled,
    required int offsetMinutes,
    required bool enableSound,
    required Map<String, bool> enabledPrayers,
    VoidCallback? onComplete,
    void Function(String error)? onError,
  }) async {
    // Debounce rapid setting changes (e.g., user dragging slider)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () async {
      if (_isRescheduling) return;
      _isRescheduling = true;
      
      try {
        if (!enabled) {
          await _notificationService.cancelAll();
          debugPrint('🔕 Notifications disabled - cleared all scheduled alerts');
          onComplete?.call();
          return;
        }

        // Calculate prayer times using adhan
        final coordinates = adhan.Coordinates(location.latitude, location.longitude);
        final calculationParams = method.toAdhan().getParameters();
        final prayerTimes = adhan.PrayerTimes.today(coordinates, calculationParams);

        // Schedule notifications
        await _notificationService.scheduleDailyPrayers(
          prayerTimes: prayerTimes,
          offsetMinutes: offsetMinutes,
          enableSound: enableSound,
          enabledPrayers: enabledPrayers,
        );
        
        debugPrint('✅ Notifications rescheduled for ${location.displayAddress} '
                   'using ${method.displayName}');
        onComplete?.call();
      } catch (e, stack) {
        debugPrint('❌ Notification scheduling failed: $e\n$stack');
        onError?.call(e.toString());
        // Fallback: cancel to avoid stale notifications
        await _notificationService.cancelAll();
      } finally {
        _isRescheduling = false;
      }
    });
  }

  /// Force immediate reschedule (skip debounce)
  Future<void> forceReschedule({
    required AppLocation location,
    required CalculationMethodOption method,
    required bool enabled,
    required int offsetMinutes,
    required bool enableSound,
    required Map<String, bool> enabledPrayers,
    VoidCallback? onComplete,
    void Function(String error)? onError,
  }) async {
    _debounceTimer?.cancel();
    await reschedule(
      location: location,
      method: method,
      enabled: enabled,
      offsetMinutes: offsetMinutes,
      enableSound: enableSound,
      enabledPrayers: enabledPrayers,
      onComplete: onComplete,
      onError: onError,
    );
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}