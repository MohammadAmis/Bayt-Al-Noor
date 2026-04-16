import 'package:shared_preferences/shared_preferences.dart';
import '../entities/calculation_method.dart';

/// ✅ Repository pattern for settings persistence
abstract class SettingsRepository {
  Future<bool> getNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool enabled);
  
  Future<int> getNotificationOffsetMinutes();
  Future<void> setNotificationOffsetMinutes(int minutes);
  
  Future<bool> getNotificationSoundEnabled();
  Future<void> setNotificationSoundEnabled(bool enabled);
  
  Future<CalculationMethodOption> getCalculationMethod();
  Future<void> setCalculationMethod(CalculationMethodOption method);
  
  Future<String?> getManualLocationName();
  Future<void> setManualLocationName(String? name);
  
  Future<bool> getUseAutoLocation();
  Future<void> setUseAutoLocation(bool useAuto);
  
  Future<bool> getIsHanafi();
  Future<void> setIsHanafi(bool isHanafi);

  Future<bool> getPrayerNotificationEnabled(String prayerName);
  Future<void> setPrayerNotificationEnabled(String prayerName, bool enabled);
  
  Future<void> clearAll();
}

class SharedPreferencesSettingsRepository implements SettingsRepository {
  static const _prefix = 'settings_';
  
  @override
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_prefix}notifications_enabled') ?? true;
  }
  
  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefix}notifications_enabled', enabled);
  }
  
  @override
  Future<int> getNotificationOffsetMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${_prefix}notification_offset') ?? 10;
  }
  
  @override
  Future<void> setNotificationOffsetMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_prefix}notification_offset', minutes);
  }
  
  @override
  Future<bool> getNotificationSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_prefix}notification_sound') ?? true;
  }
  
  @override
  Future<void> setNotificationSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefix}notification_sound', enabled);
  }
  
  @override
  Future<CalculationMethodOption> getCalculationMethod() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('${_prefix}calculation_method');
    if (code == null) return CalculationMethodOption.muslimWorldLeague;
    
    return CalculationMethodOption.values.firstWhere(
      (m) => m.code == code,
      orElse: () => CalculationMethodOption.muslimWorldLeague,
    );
  }
  
  @override
  Future<void> setCalculationMethod(CalculationMethodOption method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefix}calculation_method', method.code);
  }
  
  @override
  Future<String?> getManualLocationName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${_prefix}manual_location_name');
  }
  
  @override
  Future<void> setManualLocationName(String? name) async {
    final prefs = await SharedPreferences.getInstance();
    if (name == null) {
      await prefs.remove('${_prefix}manual_location_name');
    } else {
      await prefs.setString('${_prefix}manual_location_name', name);
    }
  }
  
  @override
  Future<bool> getUseAutoLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_prefix}use_auto_location') ?? true;
  }
  
  @override
  Future<void> setUseAutoLocation(bool useAuto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefix}use_auto_location', useAuto);
  }
  
  @override
  Future<bool> getIsHanafi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_prefix}is_hanafi') ?? false;
  }
  
  @override
  Future<void> setIsHanafi(bool isHanafi) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefix}is_hanafi', isHanafi);
  }
  
  @override
  Future<bool> getPrayerNotificationEnabled(String prayerName) async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true for all except sunrise, ishraq, and chast
    final name = prayerName.toLowerCase();
    final defaultValue = !(name == 'sunrise' || name == 'ishraq' || name == 'chast');
    return prefs.getBool('${_prefix}prayer_notify_$prayerName') ?? defaultValue;
  }

  @override
  Future<void> setPrayerNotificationEnabled(String prayerName, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefix}prayer_notify_$prayerName', enabled);
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}