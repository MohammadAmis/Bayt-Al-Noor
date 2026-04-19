import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../data/providers/chat_providers.dart';
import '../../domain/entities/chat_entity.dart';
import 'chat_page.dart';
import 'user_selection_page.dart';

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  String _activeFilter = 'All Messages';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatListAsync = ref.watch(chatListProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        title: 'Circle',
        isMainScreen: true,
        location: 'Circle',
        onSettingsPressed: () => Navigator.pushNamed(context, '/settings'),
        onProfilePressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserProfilePage(
              name: 'Fatima Al-Sayed',
              avatarUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBTsguL1thXHygl49n-buglmiegAxbwbxDG_0bz8DyMlY4B9PpbOsKMGjNK9LK1xRQeDx8dUwdqiVdvRz_FYFD5Uqqk2-bY4xdF1eQf9RqHESqq4ypt0k7zaDjDKLW0ELh8RVEnj-u2McOpnuf_39Nx27EZlDnizOq3GYfaQ45eQibevgJ3MnbdMjy0DpTxF_Hrc-tke3MtJ981TVt7wVc1CzSGJ70wPDhNo111GDqA5JnVPqhTyUjwaaGOpXZbKdmE3YxkoveBb4Y',
              bio: 'Seeking tranquility through reflection and prayer.',
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0x00001156)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserSelectionPage()),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.edit_square, color: Colors.white, size: 28),
          ),
        ),
      ),
      body: chatListAsync.when(
        data: (chats) {
          final filteredChats = chats.where((chat) {
      final matchesFilter = switch (_activeFilter) {
        'Groups' => chat.type == 'group',
        'Private' => chat.type == 'private',
        'Pinned' => chat.isPinned,
        _ => true,
      };

            final matchesSearch = chat.displayTitle
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

            return matchesFilter && matchesSearch;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _chatSearchBar(),
                const SizedBox(height: 16),
                _buildFilterChips(),
                const SizedBox(height: 16),
                _buildChatList(filteredChats),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _confirmDeleteChat(String chatId, String chatName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Sanctuary?'),
        content: Text('Are you sure you want to remove "$chatName"? This will delete all messages for everyone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(chatRepositoryProvider).deleteChat(chatId);
        // Explicitly invalidate to force a fresh fetch from remote
        ref.invalidate(chatListProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sanctuary removed.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  Widget _chatSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.outline, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search Chat, Group',
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.outline,
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Groups', 'Private', 'Pinned'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          bool isActive = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(
                filter,
                style: AppTypography.label.copyWith(
                  color: isActive
                      ? AppColors.onPrimaryFixed
                      : AppColors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              selected: isActive,
              onSelected: (val) => setState(() => _activeFilter = filter),
              selectedColor: AppColors.primaryFixed,
              backgroundColor: AppColors.surfaceContainerHigh,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              side: BorderSide.none,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChatList(List<ChatEntity> chats) {
    if (chats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text('No active chats', style: TextStyle(color: Colors.grey[600])),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: chats.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 80, endIndent: 20),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return _ChatItem(
            chatId: chat.id,
            title: chat.displayTitle,
            subtitle: chat.lastMessagePreview ?? 'No messages yet',
            time: _formatLastMessageTime(chat.lastMessageTime),
            unreadCount: chat.unreadCount,
            leading: chat.avatarUrl != null 
                ? _buildImageAvatar(chat.avatarUrl!) 
                : _buildInitialAvatar(chat.displayTitle.isNotEmpty ? chat.displayTitle[0] : '?', AppColors.primaryFixedDim),
            onDelete: () => _confirmDeleteChat(chat.id, chat.displayTitle),
          );
        },
      ),
    );
  }

  String _formatLastMessageTime(DateTime? time) {
    if (time == null) return '';
    final localTime = time.toLocal();
    final hour = localTime.hour == 0 ? 12 : (localTime.hour > 12 ? localTime.hour - 12 : localTime.hour);
    final minute = localTime.minute.toString().padLeft(2, '0');
    final amPm = localTime.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $amPm";
  }

  Widget _buildInitialAvatar(String text, Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildImageAvatar(String url) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.outlineVariant.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  final String chatId;
  final String title;
  final String subtitle;
  final String time;
  final int unreadCount;
  final Widget leading;
  final VoidCallback onDelete;

  const _ChatItem({
    required this.chatId,
    required this.title,
    required this.subtitle,
    required this.time,
    this.unreadCount = 0,
    required this.leading,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatId: chatId,
              chatTitle: title,
              chatAvatar: null, // Can extract from leading if needed
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppTypography.headline.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        time,
                        style: AppTypography.label.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.body.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.outline, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
