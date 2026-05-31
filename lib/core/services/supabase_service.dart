import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/circle/domain/repositories/chat_repository.dart';
import '../../features/circle/data/models/profile_model.dart';

class SupabaseService {
  SupabaseService();

  final SupabaseClient _client = Supabase.instance.client;

  // -- Authentication --

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    
    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user != null) {
      final metaName = response.user!.userMetadata?['full_name'] as String? ?? 
                       response.user!.userMetadata?['display_name'] as String?;
      await ensureProfileExists(response.user!.id, fullName: metaName);
    }
    
    return response;
  }

  Future<void> signInWithOtp({
    required String email,
    String? fullName,
    bool shouldCreateUser = true,
  }) async {
    await _client.auth.signInWithOtp(
      email: email,
      data: fullName != null ? {
        'full_name': fullName,
        'display_name': fullName,
      } : null,
      shouldCreateUser: shouldCreateUser,
    );
  }

  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: type,
      );

      if (response.user != null) {
        final metaName = response.user!.userMetadata?['full_name'] as String? ?? 
                         response.user!.userMetadata?['display_name'] as String?;
        await ensureProfileExists(response.user!.id, fullName: metaName);
      }

      return response;
    } on AuthException catch (e) {
      // If we tried signup but user already exists or token is invalid, try magiclink as fallback
      // This happens because signInWithOtp sends magiclink if user exists, even in Register flow.
      if (type == OtpType.signup && (e.message.toLowerCase().contains('invalid') || e.message.toLowerCase().contains('expired'))) {
        try {
          final fallbackResponse = await _client.auth.verifyOTP(
            email: email,
            token: token,
            type: OtpType.magiclink,
          );
          
          if (fallbackResponse.user != null) {
             final metaName = fallbackResponse.user!.userMetadata?['full_name'] as String? ?? 
                              fallbackResponse.user!.userMetadata?['display_name'] as String?;
             await ensureProfileExists(fallbackResponse.user!.id, fullName: metaName);
          }
          return fallbackResponse;
        } catch (_) {
          // If fallback fails, rethrow original signup error
          rethrow;
        }
      }
      rethrow;
    }
  }

  Future<void> signOut(ChatRepository repo) async {
    // 1. Clear Local Registry
    try {
      await repo.clearLocalData();
    } catch (e) {
      debugPrint('Error clearing local chat data: $e');
    }
    
    await _client.auth.signOut();
  }

  // Session Management
  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // -- Database (Profile Sync) --

  /// Fetches the user profile from the 'profiles' table.
  Future<ProfileModel?> getUserProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return ProfileModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Updates or inserts a user profile.
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    double? latitude,
    double? longitude,
    String? calculationMethod,
    String? madhhab,
    bool? is24hFormat,
    int? tasbihTotal,
    int? tasbihStreak,
    String? lastTasbihDate,
    Map<String, int>? tasbihHistory,
  }) async {
    final updates = {
      'id': userId,
      'updated_at': DateTime.now().toIso8601String(),
      if (fullName != null) 'full_name': fullName,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (calculationMethod != null) 'calculation_method': calculationMethod,
      if (madhhab != null) 'madhhab': madhhab,
      if (is24hFormat != null) 'is_24h_format': is24hFormat,
      if (tasbihTotal != null) 'tasbih_total': tasbihTotal,
      if (tasbihStreak != null) 'tasbih_streak': tasbihStreak,
      if (lastTasbihDate != null) 'last_tasbih_date': lastTasbihDate,
      if (tasbihHistory != null) 'tasbih_history': tasbihHistory,
    };

    await _client.from('profiles').upsert(updates);
  }

  /// Ensures a profile row exists for the user.
  Future<void> ensureProfileExists(String userId, {String? fullName}) async {
    final profile = await getUserProfile(userId);
    
    // Logic: 
    // - If profile doesn't exist: Create it.
    // - If it DOES exist but the name is NULL or just "User": Sync the real name from auth metadata.
    if (profile == null) {
      await updateUserProfile(
        userId: userId,
        fullName: fullName ?? 'User',
      );
    } else {
      if ((profile.fullName == 'User' || profile.fullName.isEmpty) && fullName != null) {
        await updateUserProfile(
          userId: userId,
          fullName: fullName,
        );
      }
    }
  }
}
