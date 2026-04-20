import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/profile_entity.dart';

class ChatModel {
  final String id;
  final String? name;
  final String type;
  final String? avatarUrl;
  final String createdAt;
  final Map<String, dynamic>? settings;
  final int? unreadCount;
  final String? lastMessage;
  final String? lastMessageTime;

  final List<dynamic>? membersRaw;

  ChatModel({
    required this.id,
    this.name,
    required this.type,
    this.avatarUrl,
    required this.createdAt,
    this.settings,
    this.unreadCount,
    this.lastMessage,
    this.lastMessageTime,
    this.membersRaw,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      type: json['type'] as String? ?? 'private',
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] as String,
      settings: json['settings'] as Map<String, dynamic>?,
      unreadCount: json['unread_count'] as int?,
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_time'] as String?,
      membersRaw: json['chat_members'] as List<dynamic>?,
    );
  }

  factory ChatModel.fromEntity(ChatEntity entity) {
    return ChatModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      avatarUrl: entity.avatarUrl,
      createdAt: DateTime.now().toIso8601String(),
      unreadCount: entity.unreadCount,
      lastMessage: entity.lastMessagePreview,
      lastMessageTime: entity.lastMessageTime?.toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty && !id.startsWith('temp_')) 'id': id,
      'name': name,
      'type': type,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'created_at': createdAt,
      if (settings != null) 'settings': settings,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (lastMessage != null) 'last_message': lastMessage,
      if (lastMessageTime != null) 'last_message_time': lastMessageTime,
      if (membersRaw != null) 'chat_members': membersRaw,
    };
  }

  ChatEntity toEntity({String? currentUserId, Map<String, ProfileEntity>? profileRegistry}) {
    String? resolvedName = name;
    String? resolvedAvatar = avatarUrl;

    // Logic to resolve private chat names from members if name is null OR generic
    final isGenericName = name == null || name == '' || name == 'Sanctuary' || name == 'Private Circle';
    final userId = currentUserId ?? Supabase.instance.client.auth.currentUser?.id;

    if (type == 'private' && isGenericName && membersRaw != null && userId != null) {
      try {
        final List<dynamic> rawMembers = membersRaw!;
        final otherMember = rawMembers.firstWhereOrNull(
          (m) => m is Map && (m['user_id']?.toString() != userId),
        );
        
        if (otherMember != null) {
          final otherId = otherMember['user_id'] as String;
          
          if (profileRegistry != null && profileRegistry.containsKey(otherId)) {
            final profile = profileRegistry[otherId]!;
            resolvedName = profile.fullName;
            resolvedAvatar = profile.avatarUrl;
          }
        }
      } catch (_) {}
    }

    // Resolve Name from Registry if missing

    // Truncate last message preview
    String? preview = lastMessage;
    if (preview != null && preview.length > 40) {
      preview = '${preview.substring(0, 37)}...';
    }

    return ChatEntity(
      id: id,
      name: resolvedName, 
      type: _mapChatType(type),
      avatarUrl: resolvedAvatar,
      unreadCount: unreadCount ?? 0,
      lastMessagePreview: preview,
      lastMessageTime: lastMessageTime != null ? DateTime.parse(lastMessageTime!) : null,
      isMuted: settings?['isMuted'] as bool? ?? false,
      isPinned: settings?['isPinned'] as bool? ?? false,
      memberIds: membersRaw?.map((m) => m['user_id'] as String).toList() ?? [],
    );
  }

  static String _mapChatType(String type) {
    return switch (type) {
      'group' => 'group',
      'community' => 'community',
      _ => 'private',
    };
  }
}
