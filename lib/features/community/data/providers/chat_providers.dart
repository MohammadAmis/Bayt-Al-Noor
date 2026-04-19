import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../repositories/chat_repository_impl.dart';
import '../datasources/chat_hive_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../../domain/entities/message_entity.dart';
import '../../../../core/network/connectivity_monitor.dart';

part 'chat_providers.g.dart';

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  return ChatRepositoryImpl(
    remote: SupabaseChatRemoteDataSource(Supabase.instance.client),
    local: ChatHiveLocalDataSource(), 
    connectivity: ConnectivityMonitor(),
  );
}

@Riverpod(keepAlive: true)
Stream<List<ChatEntity>> chatList(ChatListRef ref) {
  final repo = ref.watch(chatRepositoryProvider);
  
  // 1. Maintain an accumulated map of the latest message for EVERY chat
  // This prevents previews from disappearing when a new message arrives in a different sanctuary
  final lastMessagesStream = repo.listenToAllMessages()
      .scan<Map<String, MessageEntity>>((accumulated, latest, index) {
        final current = accumulated[latest.chatId];
        // Only update if we don't have a message yet, or if the new one is strictly newer
        if (current == null || latest.createdAt.isAfter(current.createdAt)) {
          return {...accumulated, latest.chatId: latest};
        }
        return accumulated;
      }, {});

  // 2. Combine the base chat stream with our accumulated previews map
  // Added error handling to prevent the whole screen from crashing on timeout
  final combinedStream = Rx.combineLatest2<List<ChatEntity>, Map<String, MessageEntity>, List<ChatEntity>>(
    repo.listenToChatUpdates().startWith([]).onErrorResume((error, stack) {
      debugPrint('Chat Updates Stream Error: $error');
      return Stream.value([]); // Return empty list instead of empty stream to keep pipeline alive
    }),
    lastMessagesStream.startWith({}).onErrorResume((error, stack) {
      debugPrint('Last Messages Stream Error: $error');
      return Stream.value({}); 
    }),
    (chats, previewsMap) {
      final profiles = ref.watch(profileListProvider).value ?? [];
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;

      return chats.map((chat) {
        var resolvedChat = chat;

        // 1. Resolve Name for Private Chats if missing or fallback
        if (chat.type == 'private' && (chat.name == null || chat.name == 'Private Circle' || chat.name == 'Unnamed Chat')) {
          final otherId = chat.memberIds.firstWhere(
            (id) => id != currentUserId,
            orElse: () => '',
          );
          if (otherId.isNotEmpty) {
            final profile = profiles.firstWhere((p) => p.id == otherId, orElse: () => const ProfileEntity(id: '', fullName: ''));
            if (profile.id.isNotEmpty) {
              resolvedChat = resolvedChat.copyWith(
                name: profile.fullName,
                avatarUrl: profile.avatarUrl,
              );
            }
          }
        }

        // 2. Resolve Last Message Preview from real-time message stream
        final lastMsg = previewsMap[chat.id];
        if (lastMsg != null) {
          resolvedChat = resolvedChat.copyWith(
            lastMessagePreview: lastMsg.type == MessageType.text ? lastMsg.content : '[Attachment]',
            lastMessageTime: lastMsg.createdAt.toLocal(),
          );
        }
        return resolvedChat;
      }).toList();
    },
  );

  return Rx.concat([
    Stream.fromFuture(repo.getChatList()).handleError((_) => const Stream.empty()),
    combinedStream,
  ]);
}

/// Helper provider to track focus
final isChatForegroundProvider = StateProvider.family<bool, String>((ref, chatId) => false);

@Riverpod(keepAlive: true)
Future<List<ProfileEntity>> profileList(ProfileListRef ref) {
  return ref.watch(chatRepositoryProvider).getProfileList();
}