import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/message_entity.dart';
import '../../data/providers/chat_providers.dart';
import '../states/chat_state.dart';
import '../../../../core/network/connectivity_monitor.dart';
import 'package:flutter/foundation.dart';
// ignore: implementation_imports
import 'package:realtime_client/src/types.dart';
import '../../domain/entities/profile_entity.dart';

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
    ).subscribe();
  }

  Future<void> sendMessage(String content) async {
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
    client.channel('typing:${state.chatId}').send(
      type: RealtimeListenTypes.broadcast,
      event: 'typing',
      payload: {'userId': client.auth.currentUser?.id, 'isTyping': true},
    );
  }

  void stopTyping() {
    final client = Supabase.instance.client;
    client.channel('typing:${state.chatId}').send(
      type: RealtimeListenTypes.broadcast,
      event: 'typing',
      payload: {'userId': client.auth.currentUser?.id, 'isTyping': false},
    );
  }
}
