import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_tokens.dart';
import '../../../../core/providers/services_provider.dart';
import '../viewmodels/chat_info_viewmodel.dart';
import '../widgets/members/member_list_tile.dart';
import '../widgets/settings/mute_duration_selector.dart';
import '../states/chat_info_state.dart';
import 'add_members_page.dart';

class ChatInfoPage extends ConsumerWidget {
  final String chatId;
  final String chatName;
  final String chatType; // 'private' | 'group' | 'community'

  const ChatInfoPage({
    super.key,
    required this.chatId,
    required this.chatName,
    this.chatType = 'group',
  });

  bool get _isGroup => chatType != 'private';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
        chatInfoViewModelProvider(chatId, initialName: chatName));
    final notifier = ref.read(
        chatInfoViewModelProvider(chatId, initialName: chatName).notifier);
    final currentUser = ref.watch(currentUserProvider);
    final currentUserId = currentUser?.id ?? '';

    return DefaultTabController(
      length: _isGroup ? 3 : 2, // Private: Settings + Files only (no Members)
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            // ── Collapsing header with avatar + name ──
            SliverAppBar(
              backgroundColor: AppColors.surface,
              expandedHeight: 200,
              pinned: true,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.onSurface,
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  state.chatName,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                background: _buildHeader(context, state, notifier),
              ),
            ),

            // ── Sticky Tab Bar ──
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  onTap: notifier.switchTab,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.onSurfaceVariant,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2,
                  labelStyle: AppTypography.labelMedium
                      .copyWith(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: AppTypography.labelMedium
                      .copyWith(fontWeight: FontWeight.w500),
                  tabs: [
                    if (_isGroup)
                      const Tab(
                          text: 'Members',
                          icon: Icon(Icons.people_outline_rounded, size: 18)),
                    const Tab(
                        text: 'Files',
                        icon: Icon(Icons.folder_outlined, size: 18)),
                    const Tab(
                        text: 'Settings',
                        icon: Icon(Icons.tune_rounded, size: 18)),
                  ],
                ),
              ),
            ),
          ],

          // ── Tab Content ──
          body: TabBarView(
            children: [
              if (_isGroup)
                _MembersTab(
                  state: state,
                  notifier: notifier,
                  currentUserId: currentUserId,
                  chatId: chatId,
                ),
                _FilesTab(resources: state.sharedResources),
              _SettingsTab(
                state: state,
                notifier: notifier,
                isGroup: _isGroup,
                chatId: chatId,
                chatName: state.chatName,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ChatInfoState state, ChatInfoViewModel notifier) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(top: 60, bottom: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.15),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3), width: 2),
            ),
            child: Icon(
              _isGroup ? Icons.groups_rounded : Icons.person_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),

          // Member count for groups
          if (_isGroup)
            Text(
              '${state.members.length} members',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Members Tab
// ────────────────────────────────────────────────────────────────────────────
class _MembersTab extends StatelessWidget {
  final ChatInfoState state;
  final ChatInfoViewModel notifier;
  final String currentUserId;
  final String chatId;

  const _MembersTab({
    required this.state,
    required this.notifier,
    required this.currentUserId,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.members.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline_rounded,
                size: 56,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              'No members yet',
              style: AppTypography.labelMedium.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
      itemCount: state.members.length + 1, // +1 for "Add Members" tile
      separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 72,
          color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      itemBuilder: (context, i) {
        // First item: Add Members button
        if (i == 0) {
          return ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_add_outlined,
                  color: AppColors.primary, size: 22),
            ),
            title: Text(
              'Add Members',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddMembersPage(chatId: chatId)),
            ),
          );
        }

        final member = state.members[i - 1];
        return MemberListTile(
          member: member,
          isCurrentUser: member.userId == currentUserId, // ✅ real userId
          onRoleChanged: (uid, role) => notifier.updateMemberRole(uid, role),
          onRemoved: (uid) => notifier.removeMember(uid),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Settings Tab
// ────────────────────────────────────────────────────────────────────────────
class _SettingsTab extends StatelessWidget {
  final ChatInfoState state;
  final ChatInfoViewModel notifier;
  final bool isGroup;
  final String chatId;
  final String chatName;

  const _SettingsTab({
    required this.state,
    required this.notifier,
    required this.isGroup,
    required this.chatId,
    required this.chatName,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
      children: [
        // ── Group Name (groups only) ──
        if (isGroup) ...[
          const _SectionHeader('Group Info'),
          _SettingsTile(
            icon: Icons.edit_outlined,
            iconColor: AppColors.primary,
            title: 'Change Group Name',
            subtitle: chatName,
            onTap: () => _showRenameDialog(context),
          ),
          _SettingsTile(
            icon: Icons.image_outlined,
            iconColor: AppColors.primary,
            title: 'Change Group Photo',
            onTap: () {}, // TODO: image picker
          ),
          _Divider(),
        ],

        // ── Notifications ──
        const _SectionHeader('Notifications'),
        _SettingsSwitchTile(
          icon: Icons.notifications_off_outlined,
          iconColor: AppColors.secondary,
          title: 'Mute Notifications',
          subtitle: state.settings.isMuted ? 'Muted' : 'On',
          value: state.settings.isMuted,
          onChanged: (val) {
            if (val) {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.surface,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24))),
                builder: (_) => MuteDurationSelector(
                  onSelect: (_) =>
                      notifier.updateSettings(isMuted: true),
                ),
              );
            } else {
              notifier.updateSettings(isMuted: false);
            }
          },
        ),
        _SettingsSwitchTile(
          icon: Icons.visibility_off_outlined,
          iconColor: AppColors.secondary,
          title: 'Hide Message Preview',
          subtitle: 'Hide content in notifications',
          value: state.settings.hidePreview,
          onChanged: (val) => notifier.updateSettings(hidePreview: val),
        ),
        _Divider(),

        // ── Privacy ──
        const _SectionHeader('Privacy'),
        _SettingsSwitchTile(
          icon: Icons.done_all_rounded,
          iconColor: AppColors.primary,
          title: 'Read Receipts',
          subtitle: 'Let others see when you\'ve read messages',
          value: state.settings.readReceiptsEnabled,
          onChanged: (val) =>
              notifier.updateSettings(readReceiptsEnabled: val),
        ),
        _Divider(),

        // ── Danger Zone ──
        const _SectionHeader('Actions'),
        if (isGroup)
          _SettingsTile(
            icon: Icons.exit_to_app_rounded,
            iconColor: AppColors.error,
            title: 'Leave Group',
            titleColor: AppColors.error,
            onTap: () => _showLeaveConfirm(context, isLeave: true),
          ),
        _SettingsTile(
          icon: Icons.delete_outline_rounded,
          iconColor: AppColors.error,
          title: isGroup ? 'Delete Group' : 'Delete Chat',
          titleColor: AppColors.error,
          onTap: () => _showLeaveConfirm(context, isLeave: false),
        ),
      ],
    );
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: chatName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Rename Group',
            style: AppTypography.titleMedium
                .copyWith(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Group name',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              // TODO: notifier.renameChat(controller.text.trim())
              Navigator.pop(ctx);
            },
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLeaveConfirm(BuildContext context, {required bool isLeave}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isLeave ? 'Leave Group?' : (isGroup ? 'Delete Group?' : 'Delete Chat?'),
          style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold, color: AppColors.error),
        ),
        content: Text(
          isLeave
              ? 'You will no longer receive messages from this group.'
              : isGroup
                  ? 'This will permanently delete the group and all messages for everyone.'
                  : 'This will permanently delete all messages in this chat.',
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Close ChatInfoPage
              Navigator.pop(context); // Close ChatPage
              // TODO: notifier.leaveOrDeleteChat()
            },
            child: Text(isLeave ? 'Leave' : 'Delete',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Files Tab
// ────────────────────────────────────────────────────────────────────────────
class _FilesTab extends StatelessWidget {
  final List<dynamic> resources;
  const _FilesTab({required this.resources});

  @override
  Widget build(BuildContext context) {
    if (resources.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_outlined,
                size: 56,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              'No shared files yet',
              style: AppTypography.labelMedium.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
            ),
          ],
        ),
      );
    }
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(12),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: List.generate(
        resources.length,
        (_) => Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.insert_drive_file_outlined,
              color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Reusable Settings Widgets
// ────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        color: AppColors.outlineVariant.withValues(alpha: 0.1),
      );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.titleColor,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: titleColor ?? AppColors.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.onSurfaceVariant),
            )
          : null,
      trailing: onTap != null
          ? Icon(Icons.chevron_right_rounded,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), size: 20)
          : null,
      onTap: onTap,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.onSurfaceVariant),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Sliver Tab Bar Delegate
// ────────────────────────────────────────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
            bottom: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.15))),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => tabBar != old.tabBar;
}