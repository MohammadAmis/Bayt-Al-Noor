import 'dart:async';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../models/profile_model.dart';
import 'chat_local_data_source.dart';

class ChatHiveLocalDataSource implements ChatLocalDataSource {
  static const String _pendingBoxName = 'pending_messages';
  static const String _messageBoxPrefix = 'messages_';
  static const String _chatRegistryBoxName = 'chat_registry';
  static const String _profileRegistryBoxName = 'profile_registry';

  // Local state for Hive boxes

  Future<Box<String>> _getChatBox(String chatId) async {
    final boxName = '$_messageBoxPrefix$chatId';
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<String>(boxName);
    }
    return await Hive.openBox<String>(boxName);
  }

  Future<Box<String>> _getPendingBox() async {
    if (Hive.isBoxOpen(_pendingBoxName)) {
      return Hive.box<String>(_pendingBoxName);
    }
    return await Hive.openBox<String>(_pendingBoxName);
  }

  Future<Box<String>> _getChatRegistryBox() async {
    if (Hive.isBoxOpen(_chatRegistryBoxName)) {
      return Hive.box<String>(_chatRegistryBoxName);
    }
    return await Hive.openBox<String>(_chatRegistryBoxName);
  }

  Future<Box<String>> _getProfileRegistryBox() async {
    if (Hive.isBoxOpen(_profileRegistryBoxName)) {
      return Hive.box<String>(_profileRegistryBoxName);
    }
    return await Hive.openBox<String>(_profileRegistryBoxName);
  }

  @override
  Stream<List<MessageEntity>> loadCachedMessages(String chatId, {String? currentUserId}) {
    return Stream.fromFuture(_getChatBox(chatId)).asyncExpand((box) {
      return box.watch().map((_) => box.values
          .map((jsonStr) => MessageModel.fromJson(json.decode(jsonStr)).toEntity(currentUserId: currentUserId))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt))).startWith(box.values
            .map((jsonStr) => MessageModel.fromJson(json.decode(jsonStr)).toEntity(currentUserId: currentUserId))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
    });
  }


  @override
  Future<void> cacheMessage(String chatId, MessageEntity message) async {
    try {
      final box = await _getChatBox(chatId);
      final model = MessageModel.fromEntity(message);
      await box.put(message.id, json.encode(model.toJson()));
    } catch (e) {
      debugPrint('Error caching message in Hive: $e');
    }
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      final box = await _getChatBox(chatId);
      await box.delete(messageId);
    } catch (e) {
      debugPrint('Error deleting message in Hive: $e');
    }
  }

  @override
  Future<void> queuePendingMessage(String chatId, MessageEntity message) async {
    try {
      final box = await _getPendingBox();
      final model = MessageModel.fromEntity(message);
      // Use a composite key or just message ID
      await box.put(message.id, json.encode(model.toJson()));
      
      // Also cache it in the chat box so it shows up in history as "Sending"
      await cacheMessage(chatId, message);
    } catch (e) {
      debugPrint('Error queueing pending message in Hive: $e');
    }
  }

  @override
  Future<void> clearUnreadCount(String chatId) async {
    // Placeholder for local unread logic
  }

  @override
  Future<void> invalidateChatCache(String chatId) async {
    try {
      final box = await _getChatBox(chatId);
      await box.clear();
    } catch (e) {
      debugPrint('Error invalidating chat cache: $e');
    }
  }

  @override
  Future<void> updateChatPreview(String chatId, String content, DateTime time) async {
    final box = await _getChatRegistryBox();
    final jsonStr = box.get(chatId);
    if (jsonStr != null) {
      final model = ChatModel.fromJson(json.decode(jsonStr));
      final updated = ChatModel(
        id: model.id,
        name: model.name,
        type: model.type,
        avatarUrl: model.avatarUrl,
        createdAt: model.createdAt,
        settings: model.settings,
        unreadCount: model.unreadCount,
        lastMessage: content,
        lastMessageTime: time.toUtc().toIso8601String(),
        membersRaw: model.membersRaw,
      );
      await box.put(chatId, json.encode(updated.toJson()));
    }
  }

  @override
  Future<void> clearLocalHistory(String chatId) async {
    await invalidateChatCache(chatId);
  }

  /// Helper to get all pending messages for a specific chat or all
  Future<List<MessageEntity>> getPendingMessages({String? chatId}) async {
    final box = await _getPendingBox();
    final allPending = box.values
        .map((jsonStr) => MessageModel.fromJson(json.decode(jsonStr)).toEntity())
        .toList();
    
    if (chatId != null) {
      return allPending.where((m) => m.chatId == chatId).toList();
    }
    return allPending;
  }

  @override
  Future<void> saveChatRegistry(List<ChatEntity> chats) async {
    final box = await _getChatRegistryBox();
    
    // SMART MERGE: We do not box.clear() because that wipes our local "Identity Stamps"
    // Instead, we update existing chats while preserving names, and remove orphaned ones.
    
    final incomingIds = chats.map((c) => c.id).toSet();
    final existingIds = box.keys.cast<String>().toSet();

    // 1. Process Updates & Additions
    for (var chat in chats) {
      final existingJson = box.get(chat.id);
      String? finalName = chat.name;
      String? finalAvatar = chat.avatarUrl;

      if (existingJson != null) {
        final existingModel = ChatModel.fromJson(json.decode(existingJson));
        // Name Shield: Preserve local name if remote is null/generic
        final isGenericRemote = chat.name == null || chat.name!.isEmpty || chat.name == 'Chat';
        if (isGenericRemote && existingModel.name != null && existingModel.name!.isNotEmpty) {
          finalName = existingModel.name;
          finalAvatar = finalAvatar ?? existingModel.avatarUrl;
        }
      }

      final model = ChatModel.fromEntity(chat.copyWith(name: finalName, avatarUrl: finalAvatar));
      await box.put(chat.id, json.encode(model.toJson()));
    }

    // 2. Remove orphaned chats (no longer on server)
    final toRemove = existingIds.difference(incomingIds);
    for (var orphanId in toRemove) {
      await box.delete(orphanId);
    }
  }

  @override
  Future<void> upsertChatToRegistry(ChatEntity chat) async {
    final box = await _getChatRegistryBox();
    final existingJson = box.get(chat.id);
    
    String? finalName = chat.name;
    String? finalAvatar = chat.avatarUrl;

    if (existingJson != null) {
      final existingModel = ChatModel.fromJson(json.decode(existingJson));
      // Name Shield: Preserve local name if new one is null/generic
      final isGenericNew = chat.name == null || chat.name!.isEmpty || chat.name == 'Chat';
      if (isGenericNew && existingModel.name != null && existingModel.name!.isNotEmpty) {
        finalName = existingModel.name;
        finalAvatar = finalAvatar ?? existingModel.avatarUrl;
      }
    }

    final model = ChatModel.fromEntity(chat.copyWith(name: finalName, avatarUrl: finalAvatar));
    await box.put(chat.id, json.encode(model.toJson()));
  }

  @override
  Future<List<ChatModel>> getCachedChats() async {
    final box = await _getChatRegistryBox();
    return box.values
        .map((jsonStr) => ChatModel.fromJson(json.decode(jsonStr)))
        .toList();
  }

  @override
  Stream<List<ChatModel>> watchChats() {
    return Stream.fromFuture(_getChatRegistryBox()).asyncExpand((box) {
      // Create a stream that emits current values immediately, then watches for changes
      return box.watch().map((_) => box.values
          .map((jsonStr) => ChatModel.fromJson(json.decode(jsonStr)))
          .toList()).startWith(box.values
            .map((jsonStr) => ChatModel.fromJson(json.decode(jsonStr)))
            .toList());
    });
  }

  @override
  Future<void> saveProfileRegistry(List<ProfileEntity> profiles) async {
    final box = await _getProfileRegistryBox();
    await box.clear();
    for (var profile in profiles) {
      final model = ProfileModel.fromEntity(profile);
      await box.put(profile.id, json.encode(model.toJson()));
    }
  }

  @override
  Future<List<ProfileModel>> getCachedProfiles() async {
    final box = await _getProfileRegistryBox();
    return box.values
        .map((jsonStr) => ProfileModel.fromJson(json.decode(jsonStr)))
        .toList();
  }

  @override
  Stream<List<ProfileModel>> watchProfiles() {
    return Stream.fromFuture(_getProfileRegistryBox()).asyncExpand((box) {
      return box.watch().map((_) => box.values
          .map((jsonStr) => ProfileModel.fromJson(json.decode(jsonStr)))
          .toList()).startWith(box.values
            .map((jsonStr) => ProfileModel.fromJson(json.decode(jsonStr)))
            .toList());
    });
  }

  @override
  Future<void> clearAllData() async {
    final chatReg = await _getChatRegistryBox();
    await chatReg.clear();
    final profReg = await _getProfileRegistryBox();
    await profReg.clear();
    final pending = await _getPendingBox();
    await pending.clear();
    
    // Also clear all message boxes (requires finding all keys)
  }

  /// Helper to remove from pending queue
  Future<void> removeFromPending(String messageId) async {
    final box = await _getPendingBox();
    await box.delete(messageId);
  }
}
