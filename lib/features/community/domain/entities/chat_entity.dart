class ChatEntity {
  final String id;
  final String? name;
  final String type; // 'private', 'group', 'community'
  final String? avatarUrl;
  final String? lastMessagePreview;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isMuted;
  final bool isPinned;
  final int memberCount;
  final List<String> memberIds;

  const ChatEntity({
    required this.id,
    this.name,
    required this.type,
    this.avatarUrl,
    this.lastMessagePreview,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
    this.memberCount = 0,
    this.memberIds = const [],
  });

  ChatEntity copyWith({
    String? id,
    String? name,
    String? type,
    String? avatarUrl,
    String? lastMessagePreview,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isMuted,
    bool? isPinned,
    int? memberCount,
    List<String>? memberIds,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
      memberCount: memberCount ?? this.memberCount,
      memberIds: memberIds ?? this.memberIds,
    );
  }

  String get displayTitle => name ?? (type == 'group' ? 'Unnamed Sanctuary' : 'Chat');
}