import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/chat_info_viewmodel.dart';
import '../widgets/members/member_list_tile.dart';
import '../widgets/settings/mute_duration_selector.dart';
import '../states/chat_info_state.dart';

class ChatInfoPage extends ConsumerWidget {
  final String chatId;
  final String chatName;

  const ChatInfoPage({super.key, required this.chatId, required this.chatName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatInfoViewModelProvider(chatId, initialName: chatName));
    final notifier = ref.read(chatInfoViewModelProvider(chatId, initialName: chatName).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.chatName),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.black,
              tabs: [
                Tab(text: 'Members', icon: Icon(Icons.group, size: 18)),
                Tab(text: 'Settings', icon: Icon(Icons.settings, size: 18)),
                Tab(text: 'Files', icon: Icon(Icons.folder, size: 18)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildMembersTab(context, state, notifier, ref),
                  _buildSettingsTab(context, state, notifier),
                  _buildFilesTab(state.sharedResources),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: state.activeTabIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showAddMembers(context, notifier),
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }

  Widget _buildMembersTab(BuildContext context, ChatInfoState state, ChatInfoViewModel notifier, WidgetRef ref) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.members.length,
      itemBuilder: (_, i) {
        final member = state.members[i];
        return MemberListTile(
          member: member,
          isCurrentUser: member.userId == 'current_user_id',
          onRoleChanged: (uid, role) => notifier.updateMemberRole(uid, role),
          onRemoved: (uid) => notifier.removeMember(uid),
        );
      },
    );
  }

  Widget _buildSettingsTab(BuildContext context, ChatInfoState state, ChatInfoViewModel notifier) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Mute Notifications'),
          value: state.settings.isMuted,
          onChanged: (val) {
            if (val) {
              showModalBottomSheet(
                context: context,
                builder: (_) => MuteDurationSelector(
                  onSelect: (duration) => notifier.updateSettings(isMuted: true),
                ),
              );
            } else {
              notifier.updateSettings(isMuted: false);
            }
          },
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Hide Message Preview'),
          value: state.settings.hidePreview,
          onChanged: (val) => notifier.updateSettings(hidePreview: val),
        ),
        SwitchListTile(
          title: const Text('Read Receipts'),
          value: state.settings.readReceiptsEnabled,
          onChanged: (val) => notifier.updateSettings(readReceiptsEnabled: val),
        ),
      ],
    );
  }

  Widget _buildFilesTab(List<dynamic> resources) {
    if (resources.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('No shared resources yet', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(8),
      children: List.generate(resources.length, (i) => _filePlaceholder(i)),
    );
  }

  Widget _filePlaceholder(int index) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.picture_as_pdf, color: Colors.grey[500], size: 24),
    );
  }

  void _showAddMembers(BuildContext context, ChatInfoViewModel notifier) {
    // Navigate to AddMembersPage
  }
}