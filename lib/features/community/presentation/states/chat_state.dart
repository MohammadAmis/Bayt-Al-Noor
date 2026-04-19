import '../../domain/entities/message_entity.dart';

class ChatState {
  final String chatId;
  final String chatName;
  final String? chatAvatar;
  final List<MessageEntity> messages;
  final Set<String> typingUsers; // userIds of people currently typing
  final bool isLoadingHistory;
  final bool isSending;
  final String? error;

  const ChatState({
    required this.chatId,
    required this.chatName,
    this.chatAvatar,
    this.messages = const [],
    this.typingUsers = const {},
    this.isLoadingHistory = false,
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    String? chatId,
    String? chatName,
    String? chatAvatar,
    List<MessageEntity>? messages,
    Set<String>? typingUsers,
    bool? isLoadingHistory,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      chatId: chatId ?? this.chatId,
      chatName: chatName ?? this.chatName,
      chatAvatar: chatAvatar ?? this.chatAvatar,
      messages: messages ?? this.messages,
      typingUsers: typingUsers ?? this.typingUsers,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}