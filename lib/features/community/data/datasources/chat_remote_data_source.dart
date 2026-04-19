import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../models/profile_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<MessageEntity>> streamMessages(String chatId);
  Stream<MessageEntity> streamAllMessages();
  Future<List<MessageEntity>> getMessages(String chatId, {int limit = 50, int offset = 0});
  Future<MessageEntity> sendMessage(MessageEntity message);
  Future<void> updateMessageStatus(String messageId, String status);
  Future<void> deleteMessage(String messageId);
  Future<void> markMessageAsDelivered(String messageId);
  
  Stream<List<ChatEntity>> streamChats();
  Future<List<ChatEntity>> getChats();
  Future<ChatEntity> getChatById(String chatId);
  Future<ChatEntity> createChat({required String type, String? name, String? avatarUrl});
  Future<void> deleteChat(String chatId);
  
  Future<void> addMembers(String chatId, List<String> userIds);
  Future<void> removeMember(String chatId, String userId);
  Future<void> updateLastRead(String chatId, DateTime time);
  Future<void> updateRole(String chatId, String userId, String role);
  Future<void> updateSettings(String chatId, Map<String, dynamic> settings);
  Future<void> insertResourceMetadata(String chatId, String fileName, String url, String type);
  Future<String?> findExistingPrivateChat(String otherUserId);
  Future<List<ProfileEntity>> getAllProfiles();
}

class SupabaseChatRemoteDataSource implements ChatRemoteDataSource {
  final SupabaseClient _client;

  SupabaseChatRemoteDataSource(this._client);

  @override
  Stream<List<MessageEntity>> streamMessages(String chatId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at')
        .map((data) {
          final userId = _client.auth.currentUser?.id;
          return data.map((json) => MessageModel.fromJson(json).toEntity(currentUserId: userId)).toList();
        });
  }

  @override
  Stream<MessageEntity> streamAllMessages() {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .where((data) => data.isNotEmpty) // Avoid .last on empty list
        .map((data) {
          final userId = _client.auth.currentUser?.id;
          return data.map((json) => MessageModel.fromJson(json).toEntity(currentUserId: userId)).last;
        });
  }

  @override
  Future<List<MessageEntity>> getMessages(String chatId, {int limit = 50, int offset = 0}) async {
    final userId = _client.auth.currentUser?.id;
    final response = await _client
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    
    return (response as List).map((json) => MessageModel.fromJson(json).toEntity(currentUserId: userId)).toList();
  }

  @override
  Future<MessageEntity> sendMessage(MessageEntity message) async {
    try {
      final model = MessageModel.fromEntity(message);
      final data = model.toJson();
      
      if (data['id']?.toString().startsWith('temp_') ?? false) {
        data.remove('id');
      }
      
      data.remove('status'); 
      data.remove('reactions');
      data.remove('reply_to');
      data.remove('resource_url');
      data.remove('resource_metadata');
      
      data['delivered_to'] = [];
      data['created_at'] = DateTime.now().toUtc().toIso8601String();
      
      debugPrint('🚀 Sending Message to Supabase: ${data['content']}');
      
      final response = await _client.from('messages').insert(data).select().single();
      final serverModel = MessageModel.fromJson(response);
      final serverEntity = serverModel.toEntity(currentUserId: _client.auth.currentUser?.id);
      
      debugPrint('✅ Message Accepted by Supabase. New ID: ${serverEntity.id}');
  
      try {
        await _client.from('chats').update({
          'last_message': serverEntity.type == MessageType.text ? serverEntity.content : '[Attachment]',
          'last_message_time': serverEntity.createdAt.toUtc().toIso8601String(),
        }).eq('id', serverEntity.chatId);
      } catch (e) {
        debugPrint('⚠️ Non-critical: Failed to update chat preview: $e');
      }

      return serverEntity;
    } catch (e) {
      debugPrint('❌ Critical: Remote sendMessage failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateMessageStatus(String messageId, String status) async {
    await _client.from('messages').update({'status': status}).eq('id', messageId);
  }

  @override
  Future<void> markMessageAsDelivered(String messageId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    // We use a custom RPC or a specific append operation to avoid race conditions
    try {
      await _client.rpc('append_msg_delivery', params: {
        'msg_id': messageId,
        'u_id': userId,
      });
    } catch (e) {
      // Fallback to manual update if RPC is missing
      final res = await _client.from('messages').select('delivered_to').eq('id', messageId).single();
      final List current = res['delivered_to'] ?? [];
      if (!current.contains(userId)) {
        current.add(userId);
        await _client.from('messages').update({'delivered_to': current}).eq('id', messageId);
      }
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _client.from('messages').delete().eq('id', messageId);
  }

  @override
  Stream<List<ChatEntity>> streamChats() {
    return _client
        .from('chats')
        .stream(primaryKey: ['id'])
        .map((data) {
          final userId = _client.auth.currentUser?.id;
          return data.map((json) => ChatModel.fromJson(json).toEntity(currentUserId: userId)).toList();
        });
  }

  @override
  Future<List<ChatEntity>> getChats() async {
    String? userId = _client.auth.currentUser?.id;
    
    // Identity Retry Logic: Wait up to 2 seconds for auth to resolve if null
    int retries = 0;
    while (userId == null && retries < 4) {
      await Future.delayed(const Duration(milliseconds: 500));
      userId = _client.auth.currentUser?.id;
      retries++;
    }

    if (userId == null) {
      debugPrint('🚨 getChats failed: No authenticated user after retries');
      return [];
    }

    try {
      // 1. Get IDs of chats where user is active
      final memberships = await _client
          .from('chat_members')
          .select('chat_id')
          .eq('user_id', userId)
          .filter('deleted_at', 'is', null);
      
      final List ids = (memberships as List).map((m) => m['chat_id']).toList();
      if (ids.isEmpty) return [];

      // 2. Fetch full data for those specific chats
      // Manually format list as (id1,id2,id3) for maximum SDK compatibility
      final idString = ids.map((id) => id).join(',');
      final response = await _client
          .from('chats')
          .select('*, chat_members(user_id, deleted_at)')
          .filter('id', 'in', '($idString)')
          .timeout(const Duration(seconds: 15));
      
      return (response as List).map((json) {
        return ChatModel.fromJson(json).toEntity(currentUserId: userId);
      }).toList();
    } catch (e) {
      debugPrint('Error in getChats: $e');
      return [];
    }
  }

  @override
  Future<ChatEntity> getChatById(String chatId) async {
    final userId = _client.auth.currentUser?.id;
    final response = await _client
        .from('chats')
        .select('*, chat_members(user_id, deleted_at)')
        .eq('id', chatId)
        .single();
    
    return ChatModel.fromJson(response).toEntity(currentUserId: userId);
  }

  @override
  Future<ChatEntity> createChat({required String type, String? name, String? avatarUrl}) async {
    final response = await _client.from('chats').insert({
      'type': type,
      if (name != null) 'name': name,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    }).select().single();
    
    final userId = _client.auth.currentUser?.id;
    return ChatModel.fromJson(response).toEntity(currentUserId: userId);
  }

  @override
  Future<void> deleteChat(String chatId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    
    // "Delink" by setting deleted_at to now
    await _client.from('chat_members').update({
      'deleted_at': DateTime.now().toUtc().toIso8601String(),
    }).match({'chat_id': chatId, 'user_id': userId});
  }

  @override
  Future<void> addMembers(String chatId, List<String> userIds) async {
    final inserts = userIds.map((uid) => {
      'chat_id': chatId,
      'user_id': uid,
      'role': 'member',
    }).toList();
    
    await _client.from('chat_members').insert(inserts);
  }

  @override
  Future<void> removeMember(String chatId, String userId) async {
    await _client
        .from('chat_members')
        .delete()
        .eq('chat_id', chatId)
        .eq('user_id', userId);
  }

  @override
  Future<void> updateLastRead(String chatId, DateTime time) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('chat_members').update({
      'last_read_at': time.toIso8601String(),
    }).match({'chat_id': chatId, 'user_id': userId});
  }

  @override
  Future<void> updateRole(String chatId, String userId, String role) async {
    await _client.from('chat_members').update({
      'role': role,
    }).match({'chat_id': chatId, 'user_id': userId});
  }

  @override
  Future<void> updateSettings(String chatId, Map<String, dynamic> settings) async {
    await _client.from('chats').update({
      'settings': settings,
    }).eq('id', chatId);
  }

  @override
  Future<void> insertResourceMetadata(String chatId, String fileName, String url, String type) async {
    final userId = _client.auth.currentUser?.id;
    await _client.from('messages').insert({
      'chat_id': chatId,
      'sender_id': userId,
      'content': 'Shared a file: $fileName',
      'type': 'file',
      'resource_url': url,
      'resource_metadata': {
        'name': fileName,
        'type': type,
      },
    });
  }

  @override
  Future<String?> findExistingPrivateChat(String otherUserId) async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null) return null;

    try {
      final res = await _client
          .from('chat_members')
          .select('chat_id, chats!inner(type)')
          .eq('chats.type', 'private')
          .filter('user_id', 'in', '($myId,$otherUserId)');

      final List data = res as List;
      final counts = <String, int>{};
      for (var row in data) {
        final id = row['chat_id'] as String;
        counts[id] = (counts[id] ?? 0) + 1;
        if (counts[id] == 2) return id;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ProfileEntity>> getAllProfiles() async {
    final myId = _client.auth.currentUser?.id;
    final response = await _client
        .from('profiles')
        .select()
        .neq('id', myId ?? '')
        .order('full_name');

    return (response as List).map((json) => ProfileModel.fromJson(json).toEntity()).toList();
  }
}
