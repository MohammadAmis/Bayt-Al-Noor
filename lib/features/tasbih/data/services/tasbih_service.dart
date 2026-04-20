import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/dhikr_model.dart';

enum CounterStyle { beads, orb }

enum LanguageMode { arabic, english }

class TasbihService with ChangeNotifier {
  static final TasbihService instance = TasbihService._internal();
  factory TasbihService() => instance;
  TasbihService._internal() {
    _initAudio();
  }

  final Map<String, AudioPlayer> _audioPlayers = {};

  // State
  int _sessionCount = 0;
  int _sessionGoal = 33;
  int _lifetimeTotal = 0;
  int _streak = 0;
  DateTime? _lastTasbihDate;
  bool _isInitialized = false;
  Map<String, int> _history = {}; // Daily history: {"2024-04-19": 500}

  // Dhikr State
  final List<Dhikr> dhikrs = Dhikr.defaults;
  int _selectedDhikrIndex = 0;
  bool _isSeriesMode = true;
  CounterStyle _counterStyle = CounterStyle.orb;
  bool _isSoundEnabled = true;
  String _selectedSoundProfile = 'Click';

  // Customization State
  LanguageMode _languageMode = LanguageMode.arabic;
  bool _isArabicVisible = true;
  bool _isTransliterationVisible = true;
  bool _isTranslationVisible = true;
  double _hapticIntensity = 0.5;

  // Sync State
  bool _syncEnabled = true;


  // Getters
  int get sessionCount => _sessionCount;
  int get sessionGoal => _sessionGoal;
  int get lifetimeTotal => _lifetimeTotal;
  int get streak => _streak;
  bool get isInitialized => _isInitialized;
  int get selectedDhikrIndex => _selectedDhikrIndex;
  Dhikr get selectedDhikr => dhikrs[_selectedDhikrIndex];
  bool get isSeriesMode => _isSeriesMode;
  CounterStyle get counterStyle => _counterStyle;
  bool get isSoundEnabled => _isSoundEnabled;
  String get selectedSoundProfile => _selectedSoundProfile;
  LanguageMode get languageMode => _languageMode;
  bool get isArabicVisible => _isArabicVisible;
  bool get isTransliterationVisible => _isTransliterationVisible;
  bool get isTranslationVisible => _isTranslationVisible;
  double get hapticIntensity => _hapticIntensity;
  Map<String, int> get history => _history;

  // Keys for Local Storage
  static const String _keySessionCount = 'tasbih_session_count';
  static const String _keySessionGoal = 'tasbih_session_goal';
  static const String _keyLifetimeTotal = 'tasbih_lifetime_total';
  static const String _keyStreak = 'tasbih_streak';
  static const String _keyLastDate = 'tasbih_last_date';
  static const String _keyDhikrIndex = 'tasbih_dhikr_index';
  static const String _keySeriesMode = 'tasbih_series_mode';
  static const String _keyCounterStyle = 'tasbih_counter_style';
  static const String _keySoundEnabled = 'tasbih_sound_enabled';
  static const String _keySoundProfile = 'tasbih_sound_profile';
  static const String _keyLanguageMode = 'tasbih_language_mode';
  static const String _keyArabicVis = 'tasbih_arabic_vis';
  static const String _keyTransliterationVis = 'tasbih_transliteration_vis';
  static const String _keyTranslationVis = 'tasbih_translation_vis';
  static const String _keyHapticIntensity = 'tasbih_haptic_intensity';
  static const String _keyHistory = 'tasbih_history';

  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    // 1. Load from Local Storage
    _sessionCount = prefs.getInt(_keySessionCount) ?? 0;
    _sessionGoal = prefs.getInt(_keySessionGoal) ?? 33;
    _lifetimeTotal = prefs.getInt(_keyLifetimeTotal) ?? 0;
    _streak = prefs.getInt(_keyStreak) ?? 0;
    _selectedDhikrIndex = prefs.getInt(_keyDhikrIndex) ?? 0;
    _isSeriesMode = prefs.getBool(_keySeriesMode) ?? true;
    _counterStyle = CounterStyle
        .values[prefs.getInt(_keyCounterStyle) ?? 1]; // Default to Orb (1)
    _isSoundEnabled = prefs.getBool(_keySoundEnabled) ?? true;
    _selectedSoundProfile = prefs.getString(_keySoundProfile) ?? 'Click';
    _languageMode = LanguageMode.values[prefs.getInt(_keyLanguageMode) ?? 0];
    _isArabicVisible = prefs.getBool(_keyArabicVis) ?? true;
    _isTranslationVisible = prefs.getBool(_keyTranslationVis) ?? true;
    _hapticIntensity = prefs.getDouble(_keyHapticIntensity) ?? 0.5;

    // Trigger lazy loading of sounds
    _loadSounds();

    final lastDateStr = prefs.getString(_keyLastDate);
    if (lastDateStr != null) {
      _lastTasbihDate = DateTime.parse(lastDateStr);
    }

    // Use a clean initialization for history
    _loadHistoryFromPrefs(prefs);

    // 2. Load from Supabase (if online/logged in)
    await _syncFromSupabase();

    _isInitialized = true;
    notifyListeners();
  }

  void _loadHistoryFromPrefs(SharedPreferences prefs) {
    final historyStr = prefs.getString(_keyHistory);
    if (historyStr != null) {
      try {
        // We'll store it as comma separated key:value pairs for simplicity if we don't want to import convert
        // "2024-04-19:500,2024-04-20:300"
        final map = <String, int>{};
        final pairs = historyStr.split(',');
        for (var pair in pairs) {
          final parts = pair.split(':');
          if (parts.length == 2) {
            map[parts[0]] = int.tryParse(parts[1]) ?? 0;
          }
        }
        _history = map;
      } catch (e) {
        _history = {};
      }
    }
  }

  Future<void> _syncFromSupabase() async {
    if (!_syncEnabled) return;

    final user = SupabaseService.instance.currentUser;
    if (user != null) {
      try {
        final profile = await SupabaseService.instance.getUserProfile(user.id);
        if (profile != null) {
          _lifetimeTotal = profile.tasbihTotal > _lifetimeTotal
              ? profile.tasbihTotal
              : _lifetimeTotal;
          _streak =
              profile.tasbihStreak > _streak ? profile.tasbihStreak : _streak;

          if (profile.lastTasbihDate != null) {
            _lastTasbihDate = profile.lastTasbihDate;
          }

          // Merge history
          if (profile.tasbihHistory.isNotEmpty) {
            profile.tasbihHistory.forEach((key, value) {
              if (value > (_history[key] ?? 0)) {
                _history[key] = value;
              }
            });
          }

          await _saveLocally();
        }
      } catch (e) {
        _handleSyncError(e);
      }
    }
  }

  void _handleSyncError(Object e) {
    if (e is PostgrestException && e.code == 'PGRST204') {
      debugPrint(
          'Supabase Sync Disabled: Profiles table missing Tasbih columns.');
      _syncEnabled = false;
    } else {
      debugPrint('Supabase Sync Error: $e');
    }
  }

  Future<void> increment() async {
    _sessionCount++;
    _lifetimeTotal++;

    // Log to history
    final today = _getTodayKey();
    _history[today] = (_history[today] ?? 0) + 1;

    _updateStreak();

    // Haptics & Series Logic
    if (_sessionCount >= _sessionGoal) {
      _triggerGoalHaptic();
      if (_isSeriesMode) {
        _switchToNextDhikr();
      }
    } else {
      _triggerRegularHaptic();
    }

    notifyListeners();
    await _saveLocally();
    _triggerSync();
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  // --- Aggregation Logic ---

  List<int> getWeeklyData() {
    final data = <int>[];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      data.add(_history[key] ?? 0);
    }
    return data;
  }

  int getWeeklyTotal() {
    return getWeeklyData().reduce((a, b) => a + b);
  }

  int getMonthlyTotal() {
    int total = 0;
    final now = DateTime.now();
    final monthPrefix = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    _history.forEach((key, value) {
      if (key.startsWith(monthPrefix)) {
        total += value;
      }
    });
    return total;
  }

  int getYearlyTotal() {
    int total = 0;
    final now = DateTime.now();
    final yearPrefix = "${now.year}-";
    _history.forEach((key, value) {
      if (key.startsWith(yearPrefix)) {
        total += value;
      }
    });
    return total;
  }

  List<int> getMonthlyData() {
    final data = List.filled(5, 0); // Up to 5 weeks
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    _history.forEach((key, value) {
      if (key.startsWith("$year-${month.toString().padLeft(2, '0')}")) {
        final day = int.tryParse(key.split('-').last) ?? 0;
        if (day > 0) {
          final weekIndex = ((day - 1) / 7).floor();
          if (weekIndex < 5) data[weekIndex] += value;
        }
      }
    });
    return data;
  }

  List<int> getYearlyData() {
    final data = List.filled(12, 0);
    final year = DateTime.now().year;

    _history.forEach((key, value) {
      if (key.startsWith("$year-")) {
        final monthStr = key.split('-')[1];
        final month = int.tryParse(monthStr) ?? 0;
        if (month > 0 && month <= 12) {
          data[month - 1] += value;
        }
      }
    });
    return data;
  }

  void _switchToNextDhikr() {
    _sessionCount = 0;
    _selectedDhikrIndex = (_selectedDhikrIndex + 1) % dhikrs.length;
  }

  void selectDhikr(int index) {
    if (index >= 0 && index < dhikrs.length) {
      _selectedDhikrIndex = index;
      _sessionCount = 0;
      
      notifyListeners();
      _saveLocally();
    }
  }

  void toggleSeriesMode(bool value) {
    _isSeriesMode = value;
    notifyListeners();
    _saveLocally();
  }

  void setCounterStyle(CounterStyle style) {
    _counterStyle = style;
    notifyListeners();
    _saveLocally();
  }

  void toggleSound(bool value) {
    _isSoundEnabled = value;
    notifyListeners();
    _saveLocally();
  }

  void setSoundProfile(String profile) {
    _selectedSoundProfile = profile;
    notifyListeners();
    _saveLocally();
  }

  void toggleArabic(bool value) {
    _isArabicVisible = value;
    notifyListeners();
    _saveLocally();
  }

  void toggleTransliteration(bool value) {
    _isTransliterationVisible = value;
    notifyListeners();
    _saveLocally();
  }

  void toggleTranslation(bool value) {
    _isTranslationVisible = value;
    notifyListeners();
    _saveLocally();
  }

  void setHapticIntensity(double value) {
    _hapticIntensity = value;
    notifyListeners();
    _saveLocally();
  }

  void setLanguageMode(LanguageMode mode) {
    _languageMode = mode;
    notifyListeners();
    _saveLocally();
  }

  void _updateStreak() {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    if (_lastTasbihDate == null) {
      _streak = 1;
      _lastTasbihDate = todayDate;
    } else {
      final lastDate = DateTime(
          _lastTasbihDate!.year, _lastTasbihDate!.month, _lastTasbihDate!.day);
      final difference = todayDate.difference(lastDate).inDays;

      if (difference == 1) {
        _streak++;
        _lastTasbihDate = todayDate;
      } else if (difference > 1) {
        _streak = 1;
        _lastTasbihDate = todayDate;
      }
    }
  }

  Future<void> resetSession() async {
    _sessionCount = 0;
    notifyListeners();
    await _saveLocally();
    _triggerSync();
  }

  Future<void> setGoal(int goal) async {
    _sessionGoal = goal;
    notifyListeners();
    await _saveLocally();
  }

  Future<void> _saveLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySessionCount, _sessionCount);
    await prefs.setInt(_keySessionGoal, _sessionGoal);
    await prefs.setInt(_keyLifetimeTotal, _lifetimeTotal);
    await prefs.setInt(_keyStreak, _streak);
    await prefs.setInt(_keyDhikrIndex, _selectedDhikrIndex);
    await prefs.setBool(_keySeriesMode, _isSeriesMode);
    await prefs.setInt(_keyCounterStyle, _counterStyle.index);
    await prefs.setBool(_keySoundEnabled, _isSoundEnabled);
    await prefs.setString(_keySoundProfile, _selectedSoundProfile);
    await prefs.setInt(_keyLanguageMode, _languageMode.index);
    await prefs.setBool(_keyArabicVis, _isArabicVisible);
    await prefs.setBool(_keyTransliterationVis, _isTransliterationVisible);
    await prefs.setBool(_keyTranslationVis, _isTranslationVisible);
    await prefs.setDouble(_keyHapticIntensity, _hapticIntensity);

    // Save history string
    final historyStr =
        _history.entries.map((e) => "${e.key}:${e.value}").join(',');
    await prefs.setString(_keyHistory, historyStr);

    if (_lastTasbihDate != null) {
      await prefs.setString(_keyLastDate, _lastTasbihDate!.toIso8601String());
    }
  }

  void _triggerSync() {
    _syncToSupabase();
  }

  Future<void> _syncToSupabase() async {
    if (!_syncEnabled) return;

    final user = SupabaseService.instance.currentUser;
    if (user != null) {
      try {
        await SupabaseService.instance.updateUserProfile(
          userId: user.id,
          tasbihTotal: _lifetimeTotal,
          tasbihStreak: _streak,
          lastTasbihDate: _lastTasbihDate?.toIso8601String(),
          tasbihHistory: _history,
        );
      } catch (e) {
        _handleSyncError(e);
      }
    }
  }

  void _initAudio() {
    // Initialized lazily or at _loadSounds
  }

  Future<void> _loadSounds() async {
    try {
      final profiles = ['Click', 'Water Drop', 'Celestial Pulse'];
      final files = ['screen_tap.mp3', 'water_drop.mp3', 'celestial.mp3'];
      
      for (int i = 0; i < profiles.length; i++) {
        final player = AudioPlayer();
        await player.setAsset('assets/sounds/${files[i]}');
        _audioPlayers[profiles[i]] = player;
      }
    } catch (e) {
      debugPrint("Error pre-loading Tasbih sounds: $e");
    }
  }

  void _triggerRegularHaptic() {
    if (_isSoundEnabled) {
      _playSelectedSound();
    }
    
    if (_hapticIntensity > 0.7) {
      HapticFeedback.mediumImpact();
    } else if (_hapticIntensity > 0.3) {
      HapticFeedback.lightImpact();
    } else if (_hapticIntensity > 0.05) {
      HapticFeedback.selectionClick();
    }
  }

  void _triggerGoalHaptic() {
    if (_isSoundEnabled) {
      _playSelectedSound();
    }
    
    if (_hapticIntensity > 0.5) {
      HapticFeedback.vibrate();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  void _playSelectedSound() {
    final player = _audioPlayers[_selectedSoundProfile];
    if (player != null) {
      // Small optimization: seek to 0 and play to allow rapid re-triggering
      player.seek(Duration.zero);
      player.play();
    }
  }
}
