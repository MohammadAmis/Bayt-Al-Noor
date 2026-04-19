import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/chat_providers.dart';
import '../../domain/entities/member_entity.dart';
import '../states/chat_info_state.dart';

part 'chat_info_viewmodel.g.dart';

@riverpod
class ChatInfoViewModel extends _$ChatInfoViewModel {
  @override
  ChatInfoState build(String chatId, {required String initialName}) {
    loadMembers();
    loadSettings();
    loadResources();
    return ChatInfoState(chatId: chatId, chatName: initialName);
  }

  Future<void> loadMembers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(chatRepositoryProvider);
      // In production: repo.getChatMembers(chatId)
      final members = await _mockFetchMembers(); 
      state = state.copyWith(members: members, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load members', isLoading: false);
    }
  }

  Future<void> loadSettings() async {
    // Logic to load settings from repo
  }

  Future<void> loadResources() async {
    // Logic to load resources from repo
  }

  Future<void> updateMemberRole(String userId, String newRole) async {
    try {
      final repo = ref.read(chatRepositoryProvider);
      await repo.updateMemberRole(state.chatId, userId, newRole);
      await loadMembers(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: 'Role update failed');
    }
  }

  Future<void> removeMember(String userId) async {
    try {
      final repo = ref.read(chatRepositoryProvider);
      await repo.removeMember(state.chatId, userId);
      await loadMembers();
    } catch (e) {
      state = state.copyWith(error: 'Remove failed');
    }
  }

  Future<void> updateSettings({
    bool? isMuted,
    bool? hidePreview,
    bool? readReceiptsEnabled,
  }) async {
    final newSettings = state.settings.copyWith(
      isMuted: isMuted,
      hidePreview: hidePreview,
      readReceiptsEnabled: readReceiptsEnabled,
    );
    state = state.copyWith(settings: newSettings);
    
    try {
      final repo = ref.read(chatRepositoryProvider);
      await repo.updateChatSettings(state.chatId, newSettings.toJson());
    } catch (e) {
      state = state.copyWith(error: 'Settings sync failed');
    }
  }

  void switchTab(int index) {
    state = state.copyWith(activeTabIndex: index);
  }

  Future<void> addMembers(List<String> userIds) async {
    try {
      final repo = ref.read(chatRepositoryProvider);
      await repo.addMembers(state.chatId, userIds);
      await loadMembers();
    } catch (e) {
      state = state.copyWith(error: 'Failed to add members');
    }
  }

  // Mock for structure demonstration
  Future<List<MemberEntity>> _mockFetchMembers() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      const MemberEntity(userId: 'u1', name: 'Admin User', role: 'owner'),
      const MemberEntity(userId: 'u2', name: 'Moderator', role: 'admin'),
      const MemberEntity(userId: 'u3', name: 'Regular User', role: 'member'),
    ];
  }
}
