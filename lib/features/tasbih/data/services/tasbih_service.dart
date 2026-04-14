import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/dhikr_model.dart';

class TasbihService with ChangeNotifier {
  static final TasbihService instance = TasbihService._internal();
  factory TasbihService() => instance;
  TasbihService._internal();

  // State
  int _sessionCount = 0;
  int _sessionGoal = 33;
  int _lifetimeTotal = 0;
  int _streak = 0;
  DateTime? _lastTasbihDate;
  bool _isInitialized = false;

  // Dhikr State
  final List<Dhikr> dhikrs = Dhikr.defaults;
  int _selectedDhikrIndex = 0;
  bool _isSeriesMode = true;

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

  // Keys for Local Storage
  static const String _keySessionCount = 'tasbih_session_count';
  static const String _keySessionGoal = 'tasbih_session_goal';
  static const String _keyLifetimeTotal = 'tasbih_lifetime_total';
  static const String _keyStreak = 'tasbih_streak';
  static const String _keyLastDate = 'tasbih_last_date';
  static const String _keyDhikrIndex = 'tasbih_dhikr_index';
  static const String _keySeriesMode = 'tasbih_series_mode';

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
    
    final lastDateStr = prefs.getString(_keyLastDate);
    if (lastDateStr != null) {
      _lastTasbihDate = DateTime.parse(lastDateStr);
    }

    // 2. Load from Supabase (if online/logged in)
    await _syncFromSupabase();

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _syncFromSupabase() async {
    if (!_syncEnabled) return;
    
    final user = SupabaseService.instance.currentUser;
    if (user != null) {
      try {
        final profile = await SupabaseService.instance.getUserProfile(user.id);
        if (profile != null) {
          final remoteLifetime = profile['tasbih_total'] as int? ?? 0;
          final remoteStreak = profile['tasbih_streak'] as int? ?? 0;
          
          if (remoteLifetime > _lifetimeTotal) {
            _lifetimeTotal = remoteLifetime;
          }
          if (remoteStreak > _streak) {
            _streak = remoteStreak;
          }
          
          final remoteLastDate = profile['last_tasbih_date'] as String?;
          if (remoteLastDate != null) {
            _lastTasbihDate = DateTime.parse(remoteLastDate);
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
      debugPrint('Supabase Sync Disabled: Profiles table missing Tasbih columns. Please run SQL migration.');
      _syncEnabled = false;
    } else {
      debugPrint('Supabase Sync Error: $e');
    }
  }

  Future<void> increment() async {
    _sessionCount++;
    _lifetimeTotal++;
    
    _updateStreak();

    // Haptics & Series Logic
    if (_sessionCount >= _sessionGoal) {
      HapticFeedback.vibrate(); // Heavy pulse
      if (_isSeriesMode) {
        _switchToNextDhikr();
      }
    } else {
      HapticFeedback.lightImpact();
    }

    notifyListeners();
    await _saveLocally();
    _triggerSync();
  }

  void _switchToNextDhikr() {
    _sessionCount = 0;
    _selectedDhikrIndex = (_selectedDhikrIndex + 1) % dhikrs.length;
    _sessionGoal = selectedDhikr.defaultGoal;
  }

  void selectDhikr(int index) {
    if (index >= 0 && index < dhikrs.length) {
      _selectedDhikrIndex = index;
      _sessionCount = 0;
      _sessionGoal = selectedDhikr.defaultGoal;
      notifyListeners();
      _saveLocally();
    }
  }

  void toggleSeriesMode(bool value) {
    _isSeriesMode = value;
    notifyListeners();
    _saveLocally();
  }

  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastTasbihDate == null) {
      _streak = 1;
      _lastTasbihDate = today;
    } else {
      final lastDate = DateTime(_lastTasbihDate!.year, _lastTasbihDate!.month, _lastTasbihDate!.day);
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        _streak++;
        _lastTasbihDate = today;
      } else if (difference > 1) {
        _streak = 1;
        _lastTasbihDate = today;
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
        );
      } catch (e) {
        _handleSyncError(e);
      }
    }
  }
}
