import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/chat_entity.dart';
import '../states/chat_list_state.dart';
import '../../data/providers/chat_providers.dart';

part 'chat_list_viewmodel.g.dart';

@riverpod
class ChatListViewModel extends _$ChatListViewModel {
  Timer? _debounceTimer;
  StreamSubscription<List<ChatEntity>>? _realtimeSub;

  @override
  ChatListState build() {
    // Load chats when first accessed
    Future.microtask(() => loadChats());
    
    // Setup real-time listener
    _setupRealtimeListener();

    // Cleanup on dispose
    ref.onDispose(() {
      _debounceTimer?.cancel();
      _realtimeSub?.cancel();
    });

    return ChatListState.initial();
  }

  Future<void> loadChats() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: !state.isRefreshing, error: null);
    try {
      final repository = ref.read(chatRepositoryProvider);
      final chats = await repository.getChatList(
        filter: state.activeFilter,
        searchQuery: state.searchQuery.trim(),
      );
      
      final sortedChats = _sortChats(chats);
      state = state.copyWith(
        chats: sortedChats,
        isLoading: false,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: 'Unable to load community chats. Please check connection.',
      );
    }
  }

  void setFilter(String newFilter) {
    if (state.activeFilter != newFilter) {
      state = state.copyWith(activeFilter: newFilter);
      loadChats(); // Reset & reload with new filter
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _debounceTimer?.cancel();
    
    // Wait 300ms before querying DB to prevent spam
    _debounceTimer = Timer(const Duration(milliseconds: 300), loadChats);
  }

  Future<void> refreshChats() async {
    state = state.copyWith(isRefreshing: true);
    await loadChats();
  }

  void _setupRealtimeListener() {
    final repository = ref.read(chatRepositoryProvider);
    _realtimeSub = repository.listenToChatUpdates().listen((updatedChats) {
      // Merge incoming updates with existing state
      final currentIds = state.chats.map((c) => c.id).toSet();
      final newChats = updatedChats.where((c) => !currentIds.contains(c.id)).toList();
      final updatedList = state.chats.map((existing) {
        return updatedChats.firstWhere(
          (incoming) => incoming.id == existing.id,
          orElse: () => existing,
        );
      }).toList();

      state = state.copyWith(
        chats: _sortChats([...updatedList, ...newChats]),
      );
    });
  }

  List<ChatEntity> _sortChats(List<ChatEntity> chats) {
    // Pinned chats always at top, others sorted by last message time (desc)
    final pinned = chats.where((c) => c.isPinned).toList()
      ..sort((a, b) => b.lastMessageTime!.compareTo(a.lastMessageTime!));
    
    final others = chats.where((c) => !c.isPinned).toList()
      ..sort((a, b) => b.lastMessageTime!.compareTo(a.lastMessageTime!));

    return [...pinned, ...others];
  }
}