import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:adhan/adhan.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final instance = NotificationService._();
  NotificationService._();
  
  FlutterLocalNotificationsPlugin? __plugin;
  FlutterLocalNotificationsPlugin get _plugin {
    if (kIsWeb) throw UnsupportedError('Notifications are not supported on web.');
    return __plugin ??= FlutterLocalNotificationsPlugin();
  }
  bool _initialized = false;

  Future<void> initialize() async {
    if (kIsWeb) return;
    if (_initialized) return;
    
    tz.initializeTimeZones();
    
    // Android settings
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const DarwinInitializationSettings iOSSettings = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iOSSettings),
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap (deep link to prayer details)
      },
    );
    
    // Request exact alarms permission for Android 12+
    if (!kIsWeb && Platform.isAndroid) {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestExactAlarmsPermission();
    }
    
    _initialized = true;
  }

  /// Schedule a prayer alert with timezone-aware timing
  Future<void> schedulePrayerAlert({
    required String prayerName,
    required String arabicName,
    required DateTime prayerTime,
    required int offsetMinutes,
    required int id,
    bool enableSound = true,
  }) async {
    if (kIsWeb) return;
    if (!_initialized) await initialize();
    
    // Convert to local timezone for accurate scheduling
    final localTime = tz.TZDateTime.from(
      prayerTime.isUtc ? prayerTime : prayerTime.toUtc(),
      tz.local,
    );
    
    // Alert with configurable offset
    final alertTime = localTime.subtract(Duration(minutes: offsetMinutes));
    
    // Don't schedule past alerts
    if (alertTime.isBefore(tz.TZDateTime.now(tz.local))) return;
    
    await _plugin.zonedSchedule(
      id,
      '🕌 $prayerName Soon',
      '$arabicName begins in $offsetMinutes minutes. Prepare for prayer.',
      alertTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_alerts', 
          'Prayer Alerts',
          channelDescription: 'Notifications for upcoming prayer times',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: enableSound,
          // 🔔 Using system default sound to avoid crashes if 'notification.wav' is missing in res/raw.
          // To use a custom sound, place 'notification.wav' in android/app/src/main/res/raw/
          sound: null, 
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: enableSound,
          sound: enableSound ? 'default' : null,
          badgeNumber: 1,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Critical for Android 12+
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily if needed
    );
  }

  /// Schedule all prayers for today with configurable offset & sound
  Future<void> scheduleDailyPrayers({
    required PrayerTimes prayerTimes,
    required int offsetMinutes,
    required bool enableSound,
    required Map<String, bool> enabledPrayers,
  }) async {
    if (kIsWeb) return;
    
    await initialize();
    
    // Cancel existing to avoid duplicates
    await cancelAll();
    
    final prayers = [
      (Prayer.fajr, prayerTimes.fajr, 'Fajr', 'الفجر'),
      (Prayer.sunrise, prayerTimes.sunrise, 'Sunrise', 'الشروق'),
      (null, prayerTimes.sunrise.add(const Duration(minutes: 15)), 'Ishraq', 'الإشراق'),
      (null, prayerTimes.sunrise.add(const Duration(minutes: 25)), 'Chast', 'الضحى'),
      (Prayer.dhuhr, prayerTimes.dhuhr, 'Dhuhr', 'الظهر'),
      (Prayer.asr, prayerTimes.asr, 'Asr', 'العصر'),
      (Prayer.maghrib, prayerTimes.maghrib, 'Maghrib', 'المغرب'),
      (Prayer.isha, prayerTimes.isha, 'Isha', 'العشاء'),
    ];
    
    for (final (_, time, name, arabic) in prayers) {
      final isEnabled = enabledPrayers[name.toLowerCase()] ?? true;
      if (!isEnabled) {
        debugPrint('⏭️ Skipping notification for $name (disabled by user)');
        continue;
      }

      final prayerLocal = tz.TZDateTime.from(time, tz.local);
      final alertTime = prayerLocal.subtract(Duration(minutes: offsetMinutes));
      
      if (alertTime.isAfter(tz.TZDateTime.now(tz.local))) {
        await schedulePrayerAlert(
          prayerName: name,
          arabicName: arabic,
          prayerTime: time,
          offsetMinutes: offsetMinutes,
          id: time.millisecondsSinceEpoch ~/ 1000, 
          enableSound: enableSound,
        );
      }
    }
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    if (_initialized) {
      await _plugin.cancelAll();
    }
  }
}
