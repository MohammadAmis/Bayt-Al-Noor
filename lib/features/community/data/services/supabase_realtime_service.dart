import 'dart:async';

/// Manages Supabase Realtime channels for individual chats.
class SupabaseRealtimeService {
  /// Stream of typing events from other users
  static Stream<String> streamTypingEvents(String chatId) {
    // Stubbed for now to resolve compilation errors with Supabase 2.x API
    return const Stream.empty();
  }

  /// Broadcast typing event
  static void broadcastTyping(String chatId, String userId) {
    // Stubbed for now
  }

  /// Handle incoming broadcast events
  static void attachBroadcastHandlers(String chatId) {
    // Stubbed for now
  }

  /// Clean up channel
  static Future<void> disposeChannel(String chatId) async {
    // Stubbed for now
  }
}