import '../../domain/entities/message_entity.dart';

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String type; // stored as string in Supabase
  final String createdAt;
  final String? resourceUrl;
  final Map<String, dynamic>? metadata;
  final Map<String, List<String>>? reactions;
  final String? replyToMessageId;
  final String? status; // stored as string
  final List<String> deliveredTo;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.createdAt,
    this.resourceUrl,
    this.metadata,
    this.reactions,
    this.replyToMessageId,
    this.status,
    this.deliveredTo = const [],
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? 'unk',
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String? ?? '',
      type: json['type'] as String,
      createdAt: json['created_at'] as String,
      resourceUrl: json['resource_url'] as String?,
      metadata: json['resource_metadata'] as Map<String, dynamic>?,
      reactions: _parseReactions(json['reactions'] as Map<String, dynamic>?),
      replyToMessageId: json['reply_to'] as String?,
      status: json['status'] as String?,
      deliveredTo: List<String>.from(json['delivered_to'] ?? []),
    );
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      chatId: entity.chatId,
      senderId: entity.senderId,
      content: entity.content,
      type: entity.type.name,
      createdAt: entity.createdAt.toIso8601String(),
      resourceUrl: entity.resourceUrl,
      metadata: entity.metadata,
      reactions: entity.reactions,
      replyToMessageId: entity.replyToMessageId,
      status: entity.status.name,
      deliveredTo: entity.deliveredTo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'type': type,
      'created_at': createdAt,
      'resource_url': resourceUrl,
      'resource_metadata': metadata,
      'reactions': reactions,
      'reply_to': replyToMessageId,
      'status': status,
      'delivered_to': deliveredTo,
    };
  }

  MessageEntity toEntity({String? currentUserId}) {
    return MessageEntity(
      id: id,
      chatId: chatId,
      senderId: senderId,
      content: content,
      type: _mapMessageType(type),
      createdAt: DateTime.parse(createdAt).toLocal(),
      status: _mapMessageStatus(status, deliveredTo, senderId, currentUserId),
      isMine: senderId.trim() == (currentUserId ?? '').trim(),
      resourceUrl: resourceUrl,
      metadata: metadata,
      reactions: reactions,
      replyToMessageId: replyToMessageId,
      deliveredTo: deliveredTo,
    );
  }

  static MessageStatus _mapMessageStatus(String? status, List<String> deliveredTo, String senderId, String? currentUserId) {
    if (status == 'sending') return MessageStatus.sending;
    if (status == 'failed') return MessageStatus.failed;
    
    // If it's my message, check delivery status
    if (senderId == currentUserId) {
      if (deliveredTo.isNotEmpty && deliveredTo.any((id) => id != currentUserId)) {
        return MessageStatus.delivered;
      }
      return MessageStatus.sent;
    }
    
    // For incoming messages, they are always 'read' or 'sent' (delivered is implicit if we see it)
    return MessageStatus.sent;
  }

  static Map<String, List<String>> _parseReactions(Map<String, dynamic>? json) {
    if (json == null) return {};
    return json.map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    );
  }

  static MessageType _mapMessageType(String type) {
    return switch (type) {
      'image' => MessageType.image,
      'file' => MessageType.file,
      'link' => MessageType.link,
      _ => MessageType.text,
    };
  }
}