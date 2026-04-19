import '../../domain/entities/chat_entity.dart';

class ChatListState {
  final List<ChatEntity> chats;
  final bool isLoading;
  final bool isRefreshing;
  final String activeFilter;
  final String searchQuery;
  final String? error;
  final bool hasReachedEnd;

  const ChatListState({
    this.chats = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.activeFilter = 'All Messages',
    this.searchQuery = '',
    this.error,
    this.hasReachedEnd = false,
  });

  factory ChatListState.initial() => const ChatListState();

  ChatListState copyWith({
    List<ChatEntity>? chats,
    bool? isLoading,
    bool? isRefreshing,
    String? activeFilter,
    String? searchQuery,
    String? error,
    bool? hasReachedEnd,
  }) {
    return ChatListState(
      chats: chats ?? this.chats,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}