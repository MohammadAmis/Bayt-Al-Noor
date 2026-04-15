import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../services/notification_scheduler.dart';
import '../../features/settings/providers/settings_providers.dart';
import '../../features/settings/providers/location_providers.dart';
import '../../features/settings/domain/entities/calculation_method.dart';
import 'notification_schedule_status_provider.dart';
import '../providers/services_provider.dart';

/// ✅ Singleton scheduler provider
final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  final scheduler = NotificationScheduler(ref.read(notificationServiceProvider));
  ref.onDispose(() => scheduler.dispose());
  return scheduler;
});

/// ✅ Orchestrator: Listens to all relevant settings & triggers rescheduling
final notificationOrchestratorProvider = Provider<void>((ref) {
  final scheduler = ref.watch(notificationSchedulerProvider);
  final statusNotifier = ref.read(notificationScheduleStatusProvider.notifier);

  /// Helper: Read current values & trigger scheduling
  void triggerSchedule() {
    final locationAsync = ref.read(locationProvider);
    final location = locationAsync.value;
    if (location == null) {
      debugPrint('⏸️ Skipping notification schedule: Location not ready');
      return;
    }

    final method = ref.read(calculationMethodProvider);
    final enabled = ref.read(notificationsEnabledProvider);
    final offset = ref.read(notificationOffsetProvider);
    final sound = ref.read(notificationSoundProvider);
    
    // ✅ Signal scheduling start
    statusNotifier.start();

    scheduler.reschedule(
      location: location,
      method: method,
      enabled: enabled,
      offsetMinutes: offset,
      enableSound: sound,
      onComplete: () => statusNotifier.complete(),
      onError: (e) => statusNotifier.fail(e),
    );
  }

  // 🔍 Listen to setting changes
  ref.listen<AsyncValue<AppLocation?>>(locationProvider, (_, __) => triggerSchedule());
  ref.listen<CalculationMethodOption>(calculationMethodProvider, (_, __) => triggerSchedule());
  ref.listen<bool>(notificationsEnabledProvider, (_, __) => triggerSchedule());
  ref.listen<int>(notificationOffsetProvider, (_, __) => triggerSchedule());
  ref.listen<bool>(notificationSoundProvider, (_, __) => triggerSchedule());

  // 🚀 Initial schedule on app start
  triggerSchedule();
});