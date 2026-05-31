import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/message_entity.dart';
import '../../data/providers/chat_providers.dart';
import '../states/chat_state.dart';
import '../../../../core/network/connectivity_monitor.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/profile_entity.dart';
import 'package:image_picker/image_picker.dart';

part 'chat_viewmodel.g.dart';

@riverpod
class ChatViewModel extends _$ChatViewModel {
  StreamSubscription<List<MessageEntity>>? _messageSub;
  StreamSubscription<bool>? _connectivitySub;
  RealtimeChannel? _typingChannel;
  Timer? _typingTimer;

  @override
  ChatState build(String chatId, {String? chatName, ProfileEntity? initialProfile}) {
    final isDraft = chatId.startsWith('draft_');
    
    if (!isDraft) {
      _initializeChat(chatId);
    }

    // High-End Fallback Resolution:
    // If the passed name is generic, try to resolve it from the local cache immediately
    String displayTitle = chatName ?? initialProfile?.fullName ?? 'Loading...';
    String? displayAvatar = initialProfile?.avatarUrl;

    if (!isDraft && (displayTitle == 'Private Circle' || displayTitle == 'Loading...')) {
      final cachedChats = ref.read(chatListProvider).value;
      final match = cachedChats?.firstWhereOrNull((c) => c.id == chatId);
      if (match != null) {
        displayTitle = match.displayTitle;
        displayAvatar = match.avatarUrl;
      }
    }

    return ChatState(
      chatId: chatId, 
      chatName: displayTitle,
      chatAvatar: displayAvatar,
    );
  }

  void _initializeChat(String targetChatId) {
    final repo = ref.read(chatRepositoryProvider);

    // 1. Subscribe to real-time updates (Reactive Local-First)
    _messageSub = repo.listenToMessages(targetChatId).listen((newMessages) {
      state = state.copyWith(messages: newMessages, isLoadingHistory: false);
    }, onError: (err) {
      debugPrint('Chat stream error: $err');
    });
    
    // 3. Listen to typing alerts
    _listenToTyping(targetChatId);

    // 2. Connectivity Monitoring
    _connectivitySub = ConnectivityMonitor().onlineStream.listen((isOnline) {
      if (isOnline) {
        state = state.copyWith(error: null);
        repo.resendPendingMessages(targetChatId);
      } else {
        state = state.copyWith(error: 'Offline: messages will be queued.');
      }
    });

    // 3. Update Chat Name if available in List
    ref.listen(chatListProvider, (previous, next) {
      final chatList = next.value;
      if (chatList == null) return;
      final foundChat = chatList.firstWhereOrNull((c) => c.id == targetChatId);
      if (foundChat != null) {
        if (state.chatName != foundChat.displayTitle || state.chatAvatar != foundChat.avatarUrl) {
          state = state.copyWith(
            chatName: foundChat.displayTitle, 
            chatAvatar: foundChat.avatarUrl
          );
        }
      }
    }, fireImmediately: true);
    
    ref.onDispose(() {
      _messageSub?.cancel();
      _connectivitySub?.cancel();
      _typingChannel?.unsubscribe();
      _typingTimer?.cancel();
      repo.disposeChatSync(targetChatId);
    });
  }

  void _listenToTyping(String targetChatId) {
    final client = Supabase.instance.client;
    _typingChannel = client.channel('typing:$targetChatId');
    
    _typingChannel!.onBroadcast(
      event: 'typing', 
      callback: (payload) {
        final userId = payload['userId'] as String?;
        final isTyping = payload['isTyping'] as bool? ?? false;
        final myId = client.auth.currentUser?.id;

        if (userId == null || userId == myId) return;

        final currentTyping = Set<String>.from(state.typingUsers);
        if (isTyping) {
          currentTyping.add(userId);
          // Auto-clear after 5 seconds of silence
          _typingTimer?.cancel();
          _typingTimer = Timer(const Duration(seconds: 5), () {
            if (state.typingUsers.isNotEmpty) {
              state = state.copyWith(typingUsers: {});
            }
          });
        } else {
          currentTyping.remove(userId);
        }
        
        state = state.copyWith(typingUsers: currentTyping);
      }
    );

    _typingChannel!.subscribe((status, [error]) {
      if (status == RealtimeSubscribeStatus.channelError) {
        debugPrint('⚠️ Typing channel error: $error. Potential timeout or permission issue.');
      } else if (status == RealtimeSubscribeStatus.closed) {
        debugPrint('🔌 Typing channel closed for $targetChatId');
      }
    });
  }

  Future<void> sendMessage(String content, {String? replyToMessageId}) async {
    if (content.trim().isEmpty) return;

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    final repo = ref.read(chatRepositoryProvider);
    String targetChatId = state.chatId;

    // --- LAZY CREATION RESOLUTION ---
    if (state.chatId.startsWith('draft_')) {
      state = state.copyWith(isSending: true);
      try {
        final otherUserId = state.chatId.replaceFirst('draft_', '');
        final realChat = await repo.getOrCreatePrivateChat(otherUserId);
        targetChatId = realChat.id;
        
        // Transition state to real chatId
        state = state.copyWith(chatId: targetChatId);
        
        // Start listening to the real message stream for this new ID
        _messageSub?.cancel();
        _messageSub = repo.listenToMessages(targetChatId).listen((newMessages) {
          state = state.copyWith(messages: newMessages, isLoadingHistory: false);
        });

      } catch (e) {
        state = state.copyWith(error: 'Failed to create Sanctuary', isSending: false);
        return;
      }
    }

    final tempMsg = MessageEntity(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      chatId: targetChatId,
      senderId: currentUser.id,
      content: content,
      type: MessageType.text,
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
      isMine: true,
      replyToMessageId: replyToMessageId?.startsWith('temp_') == true ? null : replyToMessageId,
    );

    try {
      // This will trigger the Hive sync loop automatically
      await repo.sendMessage(targetChatId, tempMsg);
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(error: 'Send failed', isSending: false);
    }
  }

  void startTyping() {
    // Memory-only broadcast via Supabase Realtime (does not touch Hive)
    final client = Supabase.instance.client;
    client.channel('typing:${state.chatId}').sendBroadcastMessage(
      event: 'typing',
      payload: {'userId': client.auth.currentUser?.id, 'isTyping': true},
    );
  }

  void stopTyping() {
    final client = Supabase.instance.client;
    client.channel('typing:${state.chatId}').sendBroadcastMessage(
      event: 'typing',
      payload: {'userId': client.auth.currentUser?.id, 'isTyping': false},
    );
  }

  Future<void> sendImageMessage(dynamic fileData, {String? caption, String? replyToMessageId}) async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;
    
    // We only support XFile now
    if (fileData is! XFile) return;
    final xFile = fileData;

    final repo = ref.read(chatRepositoryProvider);
    final uploadService = ref.read(fileUploadServiceProvider);
    String targetChatId = state.chatId;

    // --- LAZY CREATION RESOLUTION ---
    if (state.chatId.startsWith('draft_')) {
      try {
        final otherUserId = state.chatId.replaceFirst('draft_', '');
        final realChat = await repo.getOrCreatePrivateChat(otherUserId);
        targetChatId = realChat.id;
        state = state.copyWith(chatId: targetChatId);
        _messageSub?.cancel();
        _messageSub = repo.listenToMessages(targetChatId).listen((newMessages) {
          state = state.copyWith(messages: newMessages, isLoadingHistory: false);
        });
      } catch (e) {
        state = state.copyWith(error: 'Failed to create Sanctuary for image');
        return;
      }
    }

    final progressController = StreamController<double>();

    // We don't block the UI for the full upload, but we show a 'sending' status if possible
    // For now, we perform the upload and then send the message
    try {
      final publicUrl = await uploadService.uploadXFile(
        xFile: xFile,
        chatId: targetChatId,
        progressController: progressController,
      );

      final msg = MessageEntity(
        id: 'temp_img_${DateTime.now().millisecondsSinceEpoch}',
        chatId: targetChatId,
        senderId: currentUser.id,
        content: caption ?? '',
        type: MessageType.image,
        createdAt: DateTime.now(),
        status: MessageStatus.sending,
        isMine: true,
        resourceUrl: publicUrl,
        replyToMessageId: replyToMessageId?.startsWith('temp_') == true ? null : replyToMessageId,
      );

      await repo.sendMessage(targetChatId, msg);
    } catch (e) {
      state = state.copyWith(error: 'Image upload failed');
    } finally {
      progressController.close();
    }
  }

  Future<void> deleteMessage(String messageId) async {
    final repo = ref.read(chatRepositoryProvider);
    try {
      // Optimistic UI removal
      final newMessages = state.messages.where((m) => m.id != messageId).toList();
      state = state.copyWith(messages: newMessages);
      
      await repo.deleteMessage(messageId);
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete message');
    }
  }

  Future<void> reactToMessage(String messageId, String emoji) async {
    final repo = ref.read(chatRepositoryProvider);
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;
    
    final msgIndex = state.messages.indexWhere((m) => m.id == messageId);
    if (msgIndex == -1) return;
    
    final msg = state.messages[msgIndex];
    final currentReactions = Map<String, List<String>>.from(msg.reactions ?? {});
    
    final usersForEmoji = List<String>.from(currentReactions[emoji] ?? []);
    if (usersForEmoji.contains(currentUser.id)) {
      usersForEmoji.remove(currentUser.id);
      if (usersForEmoji.isEmpty) {
        currentReactions.remove(emoji);
      } else {
        currentReactions[emoji] = usersForEmoji;
      }
    } else {
      usersForEmoji.add(currentUser.id);
      currentReactions[emoji] = usersForEmoji;
    }

    // Optimistic UI update
    final updatedMsg = msg.copyWith(reactions: currentReactions);
    final newMessages = List<MessageEntity>.from(state.messages);
    newMessages[msgIndex] = updatedMsg;
    state = state.copyWith(messages: newMessages);

    try {
      await repo.reactToMessage(state.chatId, messageId, currentReactions);
    } catch (e) {
      debugPrint('Failed to react: $e');
    }
  }
}
