import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/prayer_service.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';

/// Base Supabase provider
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// PrayerService provider (singleton)
final prayerServiceProvider = Provider<PrayerService>((ref) {
  return PrayerService.instance;
});

/// SupabaseService provider with dependency injection
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance; 
});

/// NotificationService provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

/// Helper: Current user provider (derived from auth)
final currentUserProvider = Provider<User?>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.currentUser;
});