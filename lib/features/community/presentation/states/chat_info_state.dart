import '../../domain/entities/member_entity.dart';
import '../../domain/entities/resource_entity.dart';
import '../../domain/entities/chat_settings_entity.dart';

class ChatInfoState {
  final String chatId;
  final String chatName;
  final List<MemberEntity> members;
  final ChatSettingsEntity settings;
  final List<ResourceEntity> sharedResources;
  final int activeTabIndex;
  final bool isLoading;
  final String? error;

  const ChatInfoState({
    required this.chatId,
    required this.chatName,
    this.members = const [],
    this.settings = const ChatSettingsEntity(),
    this.sharedResources = const [],
    this.activeTabIndex = 0,
    this.isLoading = false,
    this.error,
  });

  ChatInfoState copyWith({
    String? chatId,
    String? chatName,
    List<MemberEntity>? members,
    ChatSettingsEntity? settings,
    List<ResourceEntity>? sharedResources,
    int? activeTabIndex,
    bool? isLoading,
    String? error,
  }) {
    return ChatInfoState(
      chatId: chatId ?? this.chatId,
      chatName: chatName ?? this.chatName,
      members: members ?? this.members,
      settings: settings ?? this.settings,
      sharedResources: sharedResources ?? this.sharedResources,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}