enum MessageType { text, image, file, link }
enum MessageStatus { sending, sent, delivered, read, failed }

class MessageEntity {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final MessageStatus status;
  final bool isMine;
  final String? resourceUrl;
  final Map<String, dynamic>? metadata; // {size, mimeType, linkPreview, etc.}
  final Map<String, List<String>>? reactions; // {"❤️": ["user_1", "user_2"]}
  final String? replyToMessageId;
  final List<String> deliveredTo;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.createdAt,
    this.status = MessageStatus.sent,
    this.isMine = false,
    this.resourceUrl,
    this.metadata,
    this.reactions,
    this.replyToMessageId,
    this.deliveredTo = const [],
  });

  MessageEntity copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    MessageType? type,
    DateTime? createdAt,
    MessageStatus? status,
    bool? isMine,
    String? resourceUrl,
    Map<String, dynamic>? metadata,
    Map<String, List<String>>? reactions,
    String? replyToMessageId,
    List<String>? deliveredTo,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      isMine: isMine ?? this.isMine,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      metadata: metadata ?? this.metadata,
      reactions: reactions ?? this.reactions,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      deliveredTo: deliveredTo ?? this.deliveredTo,
    );
  }

  bool get hasAttachments => type != MessageType.text;
}