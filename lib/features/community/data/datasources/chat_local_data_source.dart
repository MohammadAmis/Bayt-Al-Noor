import 'dart:async';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../models/chat_model.dart';
import '../models/profile_model.dart';

/// Contract for local storage (Hive, Isar, or SQLite)
abstract class ChatLocalDataSource {
  Stream<List<MessageEntity>> loadCachedMessages(String chatId, {String? currentUserId});
  Future<void> cacheMessage(String chatId, MessageEntity message);
  Future<void> deleteMessage(String chatId, String messageId);
  Future<void> queuePendingMessage(String chatId, MessageEntity message);
  
  // Registry Methods (Models returned to allow repository-level resolution)
  Future<void> saveChatRegistry(List<ChatEntity> chats);
  Future<void> upsertChatToRegistry(ChatEntity chat);
  Future<List<ChatModel>> getCachedChats();
  Stream<List<ChatModel>> watchChats();
  
  Future<void> saveProfileRegistry(List<ProfileEntity> profiles);
  Future<List<ProfileModel>> getCachedProfiles();
  Stream<List<ProfileModel>> watchProfiles();
  
  Future<void> clearUnreadCount(String chatId);
  Future<void> invalidateChatCache(String chatId);
  Future<void> updateChatPreview(String chatId, String content, DateTime time);
  Future<void> clearLocalHistory(String chatId);
  Future<void> clearAllData();
}

/// Example: In-memory fallback. Replace with Hive/Isar in production.
class InMemoryLocalDataSource implements ChatLocalDataSource {
  final Map<String, List<MessageEntity>> _cache = {};

  @override
  Stream<List<MessageEntity>> loadCachedMessages(String chatId, {String? currentUserId}) async* {
    yield _cache[chatId] ?? [];
  }

  @override
  Future<void> cacheMessage(String chatId, MessageEntity message) async {
    _cache.putIfAbsent(chatId, () => []);
    _cache[chatId]!.add(message);
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {
    _cache[chatId]?.removeWhere((m) => m.id == messageId);
  }

  @override
  Future<void> queuePendingMessage(String chatId, MessageEntity message) async {
    // Store in Hive box: 'pending_messages'
  }

  @override
  Future<void> clearUnreadCount(String chatId) async {}

  @override
  Future<void> invalidateChatCache(String chatId) async {
    _cache.remove(chatId);
  }

  @override
  Future<void> updateChatPreview(String chatId, String content, DateTime time) async {
    // No-op for memory fallback
  }

  @override
  Future<void> clearLocalHistory(String chatId) async {
    _cache.remove(chatId);
  }

  @override
  Future<void> saveChatRegistry(List<ChatEntity> chats) async {}
  
  @override
  Future<void> upsertChatToRegistry(ChatEntity chat) async {}

  @override
  Future<List<ChatModel>> getCachedChats() async => [];

  @override
  Stream<List<ChatModel>> watchChats() => const Stream.empty();

  @override
  Future<void> saveProfileRegistry(List<ProfileEntity> profiles) async {}

  @override
  Future<List<ProfileModel>> getCachedProfiles() async => [];

  @override
  Stream<List<ProfileModel>> watchProfiles() => const Stream.empty();

  @override
  Future<void> clearAllData() async {
    _cache.clear();
  }
}