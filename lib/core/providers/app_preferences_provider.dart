import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme mode provider (if not already created)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }
  
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_mode') ?? ThemeMode.system.index;
    state = ThemeMode.values[index];
  }
  
  Future<void> update(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    state = mode;
  }
}

// Show Arabic names toggle
final showArabicNamesProvider = StateNotifierProvider<ShowArabicNamesNotifier, bool>((ref) {
  return ShowArabicNamesNotifier();
});

class ShowArabicNamesNotifier extends StateNotifier<bool> {
  ShowArabicNamesNotifier() : super(true) {
    _load();
  }
  
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('show_arabic_names') ?? true;
  }
  
  Future<void> toggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_arabic_names', value);
    state = value;
  }
}

// Show Hijri date toggle
final showHijriDateProvider = StateNotifierProvider<ShowHijriDateNotifier, bool>((ref) {
  return ShowHijriDateNotifier();
});

class ShowHijriDateNotifier extends StateNotifier<bool> {
  ShowHijriDateNotifier() : super(true) {
    _load();
  }
  
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('show_hijri_date') ?? true;
  }
  
  Future<void> toggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_hijri_date', value);
    state = value;
  }
}