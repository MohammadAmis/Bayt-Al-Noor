import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';
import '../entities/profile_entity.dart';
// For stream merging & debouncing

abstract class ChatRepository {
  // 🔹 Chat List
  Future<ChatEntity> createChat({required String type, String? name, String? avatarUrl});
  Future<void> deleteChat(String chatId);
  Future<List<ChatEntity>> getChatList({
    String? filter, // 'All', 'Groups', 'Private', 'Pinned'
    String? searchQuery,
  });

  // 🔹 Realtime Messaging
  Stream<List<MessageEntity>> listenToMessages(String chatId);
  Future<List<MessageEntity>> getMessages(String chatId, {int limit = 50, int offset = 0});
  Future<void> sendMessage(String chatId, MessageEntity message);
  Future<void> resendPendingMessages(String chatId);
  void disposeChatSync(String chatId);
  Future<void> updateMessageStatus(String messageId, MessageStatus status);
  Future<void> reactToMessage(String chatId, String messageId, Map<String, List<String>> newReactions);
  Future<void> deleteMessage(String messageId);
  Future<void> toggleReaction(String messageId, String userId, String emoji);

  // 🔹 Chat List Updates
  Stream<List<ChatEntity>> listenToChatUpdates();
  Stream<MessageEntity> listenToAllMessages();

  // 🔹 Members & Settings
  Future<void> addMembers(String chatId, List<String> userIds);
  Future<void> removeMember(String chatId, String userId);
  Future<void> updateMemberRole(String chatId, String userId, String role);
  Future<void> updateChatSettings(String chatId, Map<String, dynamic> settings);
  Future<void> markChatAsRead(String chatId);

  // 🔹 Resources
  Future<List<Map<String, dynamic>>> getSharedResources(String chatId);
  Future<String> uploadResource(String filePath, String chatId);
  Future<void> shareResource(String chatId, String resourceUrl, String type, Map<String, dynamic> metadata);

  // 🔹 Discovery
  Future<List<ProfileEntity>> getProfileList();
  Future<ChatEntity> getOrCreatePrivateChat(String otherUserId);
  Future<String?> findExistingPrivateChat(String otherUserId);
  Future<void> clearLocalData();
}