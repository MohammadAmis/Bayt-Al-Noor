import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/entities/calculation_method.dart';

/// ✅ Repository provider (singleton)
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SharedPreferencesSettingsRepository();
});

/// ✅ Notifications enabled
final notificationsEnabledProvider = StateNotifierProvider<NotificationsEnabledNotifier, bool>((ref) {
  return NotificationsEnabledNotifier(ref.read(settingsRepositoryProvider));
});

class NotificationsEnabledNotifier extends StateNotifier<bool> {
  final SettingsRepository _repo;
  
  NotificationsEnabledNotifier(this._repo) : super(true) {
    _load();
  }
  
  Future<void> _load() async {
    state = await _repo.getNotificationsEnabled();
  }
  
  Future<void> toggle(bool enabled) async {
    await _repo.setNotificationsEnabled(enabled);
    state = enabled;
  }
}

/// ✅ Notification offset (minutes before prayer)
final notificationOffsetProvider = StateNotifierProvider<NotificationOffsetNotifier, int>((ref) {
  return NotificationOffsetNotifier(ref.read(settingsRepositoryProvider));
});

class NotificationOffsetNotifier extends StateNotifier<int> {
  final SettingsRepository _repo;
  
  NotificationOffsetNotifier(this._repo) : super(10) {
    _load();
  }
  
  Future<void> _load() async {
    state = await _repo.getNotificationOffsetMinutes();
  }
  
  Future<void> update(int minutes) async {
    if (minutes < 0 || minutes > 60) return; // Validate range
    await _repo.setNotificationOffsetMinutes(minutes);
    state = minutes;
  }
}

/// ✅ Notification sound enabled
final notificationSoundProvider = StateNotifierProvider<NotificationSoundNotifier, bool>((ref) {
  return NotificationSoundNotifier(ref.read(settingsRepositoryProvider));
});

class NotificationSoundNotifier extends StateNotifier<bool> {
  final SettingsRepository _repo;
  
  NotificationSoundNotifier(this._repo) : super(true) {
    _load();
  }
  
  Future<void> _load() async {
    state = await _repo.getNotificationSoundEnabled();
  }
  
  Future<void> toggle(bool enabled) async {
    await _repo.setNotificationSoundEnabled(enabled);
    state = enabled;
  }
}

/// ✅ Calculation method
final calculationMethodProvider = StateNotifierProvider<CalculationMethodNotifier, CalculationMethodOption>((ref) {
  return CalculationMethodNotifier(ref.read(settingsRepositoryProvider));
});

class CalculationMethodNotifier extends StateNotifier<CalculationMethodOption> {
  final SettingsRepository _repo;
  
  CalculationMethodNotifier(this._repo) : super(CalculationMethodOption.muslimWorldLeague) {
    _load();
  }
  
  Future<void> _load() async {
    state = await _repo.getCalculationMethod();
  }
  
  Future<void> update(CalculationMethodOption method) async {
    await _repo.setCalculationMethod(method);
    state = method;
  }
}

/// ✅ Use auto location vs manual
final useAutoLocationProvider = StateNotifierProvider<UseAutoLocationNotifier, bool>((ref) {
  return UseAutoLocationNotifier(ref.read(settingsRepositoryProvider));
});

class UseAutoLocationNotifier extends StateNotifier<bool> {
  final SettingsRepository _repo;
  
  UseAutoLocationNotifier(this._repo) : super(true) {
    _load();
  }
  
  Future<void> _load() async {
    state = await _repo.getUseAutoLocation();
  }
  
  Future<void> toggle(bool useAuto) async {
    await _repo.setUseAutoLocation(useAuto);
    state = useAuto;
  }
}

/// ✅ Manual location name (display only)
final manualLocationNameProvider = StateNotifierProvider<ManualLocationNameNotifier, String?>((ref) {
  return ManualLocationNameNotifier(ref.read(settingsRepositoryProvider));
});

class ManualLocationNameNotifier extends StateNotifier<String?> {
  final SettingsRepository _repo;
  
  ManualLocationNameNotifier(this._repo) : super(null) {
    _load();
  }
  
  Future<void> _load() async {
    state = await _repo.getManualLocationName();
  }
  
  Future<void> update(String? name) async {
    await _repo.setManualLocationName(name);
    state = name;
  }
}

/// ✅ Madhab preference (Hanafi vs Shafi/Default)
final isHanafiProvider = StateNotifierProvider<IsHanafiNotifier, bool>((ref) {
  return IsHanafiNotifier(ref.read(settingsRepositoryProvider));
});

class IsHanafiNotifier extends StateNotifier<bool> {
  final SettingsRepository _repo;
  
  IsHanafiNotifier(this._repo) : super(false) {
    _load();
  }
  
  Future<void> _load() async {
    state = await _repo.getIsHanafi();
  }
  
  Future<void> toggle(bool isHanafi) async {
    await _repo.setIsHanafi(isHanafi);
    state = isHanafi;
  }
}