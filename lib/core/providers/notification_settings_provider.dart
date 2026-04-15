import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  final bool enabled;
  final int alertOffsetMinutes;
  final bool enableSound;
  
  const NotificationSettings({
    this.enabled = true,
    this.alertOffsetMinutes = 10,
    this.enableSound = true,
  });
  
  NotificationSettings copyWith({
    bool? enabled,
    int? alertOffsetMinutes,
    bool? enableSound,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      alertOffsetMinutes: alertOffsetMinutes ?? this.alertOffsetMinutes,
      enableSound: enableSound ?? this.enableSound,
    );
  }
}

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationSettings(
      enabled: prefs.getBool('notifications_enabled') ?? true,
      alertOffsetMinutes: prefs.getInt('notification_offset') ?? 10,
      enableSound: prefs.getBool('notification_sound') ?? true,
    );
  }
  
  Future<void> updateSettings(NotificationSettings newSettings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', newSettings.enabled);
    await prefs.setInt('notification_offset', newSettings.alertOffsetMinutes);
    await prefs.setBool('notification_sound', newSettings.enableSound);
    state = newSettings;
  }
  
  Future<void> toggleEnabled(bool enabled) async {
    await updateSettings(state.copyWith(enabled: enabled));
  }
}
