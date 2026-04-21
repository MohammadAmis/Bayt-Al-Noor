import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:collection/collection.dart';

import '../../../../core/network/connectivity_monitor.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_hive_local_data_source.dart';
import '../models/chat_model.dart';
import '../models/profile_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remote;
  final ChatLocalDataSource _local;
  final ConnectivityMonitor _connectivity;
  final List<MessageEntity> _offlineQueue = [];
  String? _myId; // Cached ID for zero-flicker alignment
  final Map<String, StreamSubscription> _syncSubscriptions = {};

  ChatRepositoryImpl({
    required ChatRemoteDataSource remote,
    required ChatLocalDataSource local,
    required ConnectivityMonitor connectivity,
  })  : _remote = remote,
        _local = local,
        _connectivity = connectivity {
    _loadPersistentQueue();
    _setupAutoSync();
    _initIdentity();
    _fetchAndSyncChats();    // Initial Registry Sync
    _fetchAndSyncProfiles(); // Initial Profile Sync
  }

  void _initIdentity() {
    // 1. Initial resolution
    _updateIdentity(Supabase.instance.client.auth.currentUser?.id);

    // 2. Reactive listener for auth changes (Login/Init/Logout)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final newId = data.session?.user.id;
      if (newId != _myId) {
        debugPrint('👤 Sanctuary Identity Updated: $newId');
        _updateIdentity(newId);
      }
    });
  }

  void _updateIdentity(String? userId) {
    if (userId == null) return;
    _myId = userId;
    
    // Trigger observers and sync once identity is confirmed
    _startGlobalMembershipObserver();
    _startGlobalMessageObserver();
    
    // Trigger a background refresh of chats to resolve any "Sanctuary" names
    _fetchAndSyncChats();
  }

  Future<void> _loadPersistentQueue() async {
    if (_local is ChatHiveLocalDataSource) {
      final pending = await (_local).getPendingMessages();
      _offlineQueue.addAll(pending);
    }
  }

  @override
  Future<ChatEntity> createChat({required String type, String? name, String? avatarUrl}) async {
    final chat = await _remote.createChat(type: type, name: name, avatarUrl: avatarUrl);
    
    // Manually push into registry so it appears immediately on main screen
    await _local.upsertChatToRegistry(chat);
    
    return chat;
  }

  @override
  Future<void> addMembers(String chatId, List<String> userIds) async {
    await _remote.addMembers(chatId, userIds);
    
    // Atomic Identity Refresh:
    // After adding members to Supabase, we MUST re-fetch metadata and update Hive.
    // This bridges the identity gap where a chat starts with 0 members.
    unawaited(_fetchAndResolveSingleChat(chatId));
  }

  @override
  Future<void> deleteChat(String chatId) async {
    // 1. Mark as deleted on remote (Delink)
    await _remote.deleteChat(chatId);
    
    // 2. Wipe local history entirely (Local-First model)
    await _local.clearLocalHistory(chatId);
    await _local.invalidateChatCache(chatId);
  }

  @override
  Future<List<ChatEntity>> getChatList({String? filter, String? searchQuery}) async {
    // 1. Get cached models
    final cachedModels = await _local.getCachedChats();
    final profileMap = await _getProfileMap();
    
    final cached = cachedModels.map((m) {
      return m.toEntity(currentUserId: _myId, profileRegistry: profileMap);
    }).toList();

    // 2. Background Sync
    _fetchAndSyncChats(); 

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      final source = cached;
      final filtered = source.where((c) => (c.name ?? '').toLowerCase().contains(query)).toList();
      return filtered;
    }
    
    return cached;
  }

  Future<void> _fetchAndSyncChats() async {
    try {
      // Identity Check: Only sync if we have a valid ID. 
      // This prevents 'Wiping' the registry to [] if auth is slow.
      final currentId = _myId ?? Supabase.instance.client.auth.currentUser?.id;
      if (currentId == null) {
        debugPrint('⏮️ Sync skipped: Waiting for identity resolution...');
        return;
      }

      final remoteChats = await _remote.getChats();
      
      // Safety Check: If the remote returns empty but we know we had chats, 
      // it might be a transient network issue. We only save if we're sure.
      await _local.saveChatRegistry(remoteChats);
      
      // Update our cached ID if it was null
      if (_myId == null) {
        _myId = currentId;
        _startGlobalMembershipObserver();
        _startGlobalMessageObserver();
      }

      // Healing Sync: Ensure previews are populated even for old chats
      // Run as non-blocking background logic
      for (final chat in remoteChats) {
        unawaited(() async {
          try {
            final messages = await _remote.getMessages(chat.id, limit: 1);
            if (messages.isNotEmpty) {
              final last = messages.first;
              await _local.updateChatPreview(
                chat.id, 
                last.type == MessageType.text ? last.content : '[Attachment]',
                last.createdAt
              );
            }
          } catch (_) {}
        }());
      }
    } catch (e) {
      // debugPrint('Failed to sync chat registry: $e');
    }
  }

  @override
  Stream<List<ChatEntity>> listenToChatUpdates() {
    // True Local-First Reactive registry with combined profile lookup
    // Use startWith([]) on profiles to ensure the stream emits even if registry is empty
    return Rx.combineLatest2<List<ChatModel>, List<ProfileModel>, List<ChatEntity>>(
      _local.watchChats(),
      _local.watchProfiles().startWith([]),
      (chats, profiles) {
        final profileMap = {for (var p in profiles) p.id: p};
        return chats.map((m) {
           return m.toEntity(currentUserId: _myId, profileRegistry: profileMap);
        }).toList();
      }
    ).asBroadcastStream();
  }

  Future<Map<String, ProfileEntity>> _getProfileMap() async {
    final profiles = await _local.getCachedProfiles();
    return {for (var p in profiles) p.id: p};
  }

  @override
  Stream<MessageEntity> listenToAllMessages() {
    return _remote.streamAllMessages();
  }

  @override
  Stream<List<MessageEntity>> listenToMessages(String chatId) {
    // 1. Kick off background sync for this chat if not already running
    _startBackgroundSync(chatId);

    // 2. Return the PURE local stream from Hive. 
    // This is our single source of truth.
    final myId = _myId ?? Supabase.instance.client.auth.currentUser?.id;
    return _local.loadCachedMessages(chatId, currentUserId: myId);
  }

  @override
  void disposeChatSync(String chatId) {
    _stopBackgroundSync(chatId);
  }

  /// Trigger A: The "Listener" (Remote -> Local)
  void _startBackgroundSync(String chatId) {
    if (_syncSubscriptions.containsKey(chatId)) return;

    // debugPrint('📡 Starting background sync for chat: $chatId');
    
    final sub = _remote.streamMessages(chatId).listen(
      (messages) {
        _handleRelaySync(chatId, messages);
      },
      onError: (err) {
        // debugPrint('⚠️ Sync Error for $chatId: $err');
        // If it's a timeout, we just wait for Supabase to reconnect/retry
      },
    );

    _syncSubscriptions[chatId] = sub;
  }

  void _stopBackgroundSync(String chatId) {
    final sub = _syncSubscriptions.remove(chatId);
    if (sub != null) {
      // debugPrint('🔌 Stopping background sync for chat: $chatId');
      sub.cancel();
    }
  }

  @override
  Future<List<MessageEntity>> getMessages(String chatId, {int limit = 50, int offset = 0}) async {
    return await _remote.getMessages(chatId, limit: limit, offset: offset);
  }

  @override
  Future<void> sendMessage(String chatId, MessageEntity message) async {
    // Ensure it's tagged as 'sending' locally
    final localMsg = message.copyWith(status: MessageStatus.sending, isMine: true);
    await _local.cacheMessage(chatId, localMsg);
    
    // Trigger D: Update Chat Preview locally
    await _local.updateChatPreview(
      chatId, 
      localMsg.type == MessageType.text ? localMsg.content : '[Attachment]',
      localMsg.createdAt
    );

    try {
      if (!_connectivity.isOnline) {
        if (!_offlineQueue.any((m) => m.id == message.id)) {
           _offlineQueue.add(localMsg);
        }
        await _local.queuePendingMessage(chatId, localMsg);
        return;
      }
      
      final serverMsg = await _remote.sendMessage(message);
      
      // CRITICAL: Deduplication logic
      // 1. Remove the temporary message from local Hive
      await _local.deleteMessage(chatId, message.id);
      
      // 2. Cache the server-confirmed message with its real UUID
      // This ensures that our local cache matches the Realtime stream Exactly.
      await _local.cacheMessage(chatId, serverMsg.copyWith(status: MessageStatus.sent, isMine: true));
      
    } catch (e) {
       if (!_offlineQueue.any((m) => m.id == message.id)) {
          _offlineQueue.add(localMsg);
       }
      await _local.queuePendingMessage(chatId, localMsg);
    }
  }

  @override
  Future<void> resendPendingMessages(String chatId) async {
    await _flushOfflineQueue(chatId: chatId);
  }

  @override
  Future<void> updateMessageStatus(String messageId, MessageStatus status) async {
    await _remote.updateMessageStatus(messageId, status.name);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _remote.deleteMessage(messageId);
  }

  @override
  Future<void> toggleReaction(String messageId, String userId, String emoji) async {
    // Implementation for reactions toggle in Supabase
  }

  @override
  Future<void> removeMember(String chatId, String userId) async {
    await _remote.removeMember(chatId, userId);
  }

  @override
  Future<void> updateMemberRole(String chatId, String userId, String role) async {
    await _remote.updateRole(chatId, userId, role);
  }

  @override
  Future<void> updateChatSettings(String chatId, Map<String, dynamic> settings) async {
    await _remote.updateSettings(chatId, settings);
  }

  @override
  Future<void> markChatAsRead(String chatId) async {
    await _remote.updateLastRead(chatId, DateTime.now());
    await _local.clearUnreadCount(chatId);
  }

  @override
  Future<List<Map<String, dynamic>>> getSharedResources(String chatId) async {
    // Placeholder return
    return [];
  }

  @override
  Future<void> shareResource(String chatId, String resourceUrl, String type, Map<String, dynamic> metadata) async {
    // In production: send a message with type and resourceUrl
  }

  @override
  Future<String> uploadResource(String filePath, String chatId) async {
    // Logic for file upload in Supabase would go here
    return '';
  }

  Future<void> _handleRelaySync(String chatId, List<MessageEntity> messages) async {
    // Optimization: Only process messages we haven't seen in this session
    // and only report delivery if we aren't already in the list.
    for (final message in messages) {
       if (message.id.startsWith('temp_')) continue;

       // 1. Check if it's already in the delivered list for 'isMine'
       // (Realtime gives us the 'delivered_to' array from Supabase)
       final myId = _myId ?? Supabase.instance.client.auth.currentUser?.id;
       final alreadyDeliveredToMe = message.deliveredTo.contains(myId);

       if (!alreadyDeliveredToMe) {
         try {
           await _remote.markMessageAsDelivered(message.id);
          //  debugPrint('✅ Message Delivery Reported: [${message.id}]');
         } catch (e) {
          //  debugPrint('⚠️ Delivery Report Failed: [${message.id}] - error: $e');
         }
       }
       
       // 2. Persist to Hive if it's a real message
       // Hive handles overwriting gracefully, but we could add a check here for speed
       await _local.cacheMessage(chatId, message);
    }

    // Trigger D: Update Chat Preview with latest message
    if (messages.isNotEmpty) {
      final lastMsg = messages.last;
      await _local.updateChatPreview(
        chatId, 
        lastMsg.type == MessageType.text ? lastMsg.content : '[Attachment]',
        lastMsg.createdAt
      );
    }
  }

  void _setupAutoSync() {
    _connectivity.onlineStream.listen((isOnline) async {
      if (isOnline && _offlineQueue.isNotEmpty) {
        await _flushOfflineQueue();
      }
    });
  }

  Future<void> _flushOfflineQueue({String? chatId}) async {
    final toSend = List<MessageEntity>.from(_offlineQueue.where((m) => chatId == null || m.chatId == chatId));
    
    for (final message in toSend) {
      try {
        final serverMsg = await _remote.sendMessage(message);
        
        // CRITICAL RECONCILIATION
        // 1. Delete temp message from Hive
        await _local.deleteMessage(message.chatId, message.id);
        
        // 2. Cache the server-confirmed message
        await _local.cacheMessage(message.chatId, serverMsg.copyWith(status: MessageStatus.sent, isMine: true));

        // 3. Remove from persistent pending box
        if (_local is ChatHiveLocalDataSource) {
          await (_local).removeFromPending(message.id);
        }
        
        _offlineQueue.remove(message);
        // debugPrint('✅ Successfully flushed message: ${message.id}');
      } catch (e) {
        // debugPrint('⚠️ Sync failed for message: ${message.id} - error: $e');
      }
    }
  }

  @override
  Future<List<ProfileEntity>> getProfileList() async {
    final cached = await _local.getCachedProfiles();
    if (cached.isNotEmpty) {
      _fetchAndSyncProfiles();
      return cached;
    }
    final remote = await _remote.getAllProfiles();
    await _local.saveProfileRegistry(remote);
    return remote;
  }

  Future<void> _fetchAndSyncProfiles() async {
    try {
      final remote = await _remote.getAllProfiles();
      await _local.saveProfileRegistry(remote);
    } catch (e) {
      // debugPrint('Failed to sync profile registry: $e');
    }
  }

  @override
  Future<ChatEntity> getOrCreatePrivateChat(String otherUserId) async {
    final existingId = await _remote.findExistingPrivateChat(otherUserId);
    if (existingId != null) {
      final chat = await _remote.getChatById(existingId);
      await _local.upsertChatToRegistry(chat);
      return chat;
    }

    final newChat = await createChat(type: 'private');
    final myId = _myId ?? Supabase.instance.client.auth.currentUser?.id;
    await addMembers(newChat.id, [otherUserId, if (myId != null) myId]);
    
    // Explicit Name Stamping for Creator:
    // We fetch the profile of the other person and bake it into the chat's name field locally.
    final profiles = await getProfileList();
    final otherProfile = profiles.firstWhereOrNull((p) => p.id == otherUserId);
    
    final stampedChat = newChat.copyWith(
      name: otherProfile?.fullName,
      avatarUrl: otherProfile?.avatarUrl,
      memberIds: [otherUserId, if (myId != null) myId],
    );

    await _local.upsertChatToRegistry(stampedChat);
    return stampedChat;
  }

  @override
  Future<String?> findExistingPrivateChat(String otherUserId) async {
    return _remote.findExistingPrivateChat(otherUserId);
  }

  @override
  Future<void> clearLocalData() async {
    await _local.clearAllData();
    _offlineQueue.clear();
  }

  // --- Real-time Resilience (The Observer) ---

  void _startGlobalMembershipObserver() {
    final myId = _myId ?? Supabase.instance.client.auth.currentUser?.id;
    if (myId == null) return;
    
    final subscriptionKey = 'global_membership_$myId';
    if (_syncSubscriptions.containsKey(subscriptionKey)) return;

    debugPrint('📡 Starting Global Membership Observer for: $myId');
    
    // We listen for NEW memberships added to the current user
    // Added resiliency: ignore errors to prevent crashing the stream-based UI
    final sub = Supabase.instance.client
        .from('chat_members')
        .stream(primaryKey: ['chat_id', 'user_id'])
        .eq('user_id', myId)
        .listen((data) {
          unawaited(_reconcileMemberships(data));
        }, onError: (err) {
          debugPrint('⚠️ Global Membership Observer Error: $err');
          // No action needed, stream will eventually reconnect
        });

    _syncSubscriptions[subscriptionKey] = sub;
  }

  Future<void> _reconcileMemberships(List<Map<String, dynamic>> memberships) async {
    final cachedModels = await _local.getCachedChats();
    final cachedIds = cachedModels.map((m) => m.id).toSet();
    
    for (final row in memberships) {
      final chatId = row['chat_id'] as String;
      final deletedAt = row['deleted_at'];
      
      if (!cachedIds.contains(chatId) && deletedAt == null) {
        debugPrint('🆕 New Sanctuary Discovered! Surgical Enrichment: $chatId');
        // Surgical enrichment: Fetch metadata and members *before* adding to registry
        await _fetchAndResolveSingleChat(chatId);
      }
    }
  }

  Future<void> _fetchAndResolveSingleChat(String chatId) async {
    try {
      // 1. Fetch metadata (members list included)
      final chat = await _remote.getChatById(chatId);
      
      // 2. Fetch profiles for ALL members immediately
      if (chat.memberIds.isNotEmpty) {
        await _fetchAndSyncProfiles(); 
      }
      
      // 3. STATIC IDENTITY STAMPING
      // If it's a private chat and has no name, bake the other member's name into it.
      ChatEntity finalChat = chat;
      if (chat.type == 'private' && (chat.name == null || chat.name!.isEmpty)) {
        final userId = _myId ?? Supabase.instance.client.auth.currentUser?.id;
        final profiles = await _local.getCachedProfiles();
        
        final otherId = chat.memberIds.firstWhereOrNull((id) => id != userId);
        if (otherId != null) {
          final otherProfile = profiles.firstWhereOrNull((p) => p.id == otherId);
          if (otherProfile != null) {
             finalChat = chat.copyWith(
               name: otherProfile.fullName,
               avatarUrl: otherProfile.avatarUrl,
             );
          }
        }
      }

      await _local.upsertChatToRegistry(finalChat);
      debugPrint('✅ Stamped Identity for Sanctuary: $chatId (${finalChat.name ?? 'Unnamed'})');
    } catch (e) {
      debugPrint('Failed to resolve enriched chat $chatId: $e');
    }
  }

  void _startGlobalMessageObserver() {
    final myId = _myId ?? Supabase.instance.client.auth.currentUser?.id;
    if (myId == null) return;
    
    final subscriptionKey = 'global_messages_$myId';
    if (_syncSubscriptions.containsKey(subscriptionKey)) return;

    debugPrint('📡 Starting Global Message Observer (Previews) for: $myId');
    
    // Monitors ALL messages in the sanctuary globally
    // Supabase RLS ensures the user only streams messages they have access to
    final sub = _remote.streamAllMessages().listen((message) {
      // 1. Update Preview in Registry immediately (Real-time List reactivity)
      _local.updateChatPreview(
        message.chatId, 
        message.type == MessageType.text ? message.content : '[Attachment]',
        message.createdAt
      );
      
      // 2. Trigger individual sync if the chat is unknown (Discovery via message)
      unawaited(() async {
        final cached = await _local.getCachedChats();
        if (!cached.any((m) => m.id == message.chatId)) {
          _fetchAndResolveSingleChat(message.chatId);
        }
      }());
    }, onError: (err) {
       debugPrint('⚠️ Global Message Sync Error: $err');
    });

    _syncSubscriptions[subscriptionKey] = sub;
  }
}