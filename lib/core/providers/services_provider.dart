import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/prayer_service.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import '../services/cloudinary_service.dart';
import '../../features/tasbih/data/services/tasbih_service.dart';

/// TasbihService provider
final tasbihServiceProvider = ChangeNotifierProvider<TasbihService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return TasbihService(supabaseService: supabaseService);
});

/// Base Supabase provider
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// PrayerService provider
final prayerServiceProvider = Provider<PrayerService>((ref) {
  return PrayerService();
});

/// CloudinaryService provider
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});

/// SupabaseService provider with dependency injection
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(); 
});

/// NotificationService provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Helper: Current user provider (derived from auth)
final currentUserProvider = Provider<User?>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.currentUser;
});
