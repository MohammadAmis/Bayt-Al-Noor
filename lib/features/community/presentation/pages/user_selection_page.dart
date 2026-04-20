import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/profile_entity.dart';
import '../../data/providers/chat_providers.dart';
import 'chat_page.dart';
import 'group_details_page.dart';

class UserSelectionPage extends ConsumerStatefulWidget {
  const UserSelectionPage({super.key});

  @override
  ConsumerState<UserSelectionPage> createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends ConsumerState<UserSelectionPage> {
  final Set<ProfileEntity> _selectedUsers = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(profileListProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        title: _selectedUsers.isEmpty ? 'New Circle' : '${_selectedUsers.length} selected',
        isMainScreen: false,
        location: 'Selection',
      ),
      floatingActionButton: _selectedUsers.length > 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetailsPage(selectedUsers: _selectedUsers.toList()),
                ),
              ),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: const Text('Next', style: TextStyle(color: Colors.white)),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search for someone...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondaryLight),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: profilesAsync.when(
              data: (profiles) {
                final filtered = profiles.where((p) => 
                  p.fullName.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    final isSelected = _selectedUsers.contains(user);

                    return ListTile(
                      onTap: () => _handleUserTap(user),
                      onLongPress: () => _toggleSelection(user),
                      leading: CircleAvatar(
                        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: user.avatarUrl == null ? Text(user.fullName[0].toUpperCase()) : null,
                      ),
                      title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(user.status ?? 'Hey there! I am using Bayt-Al-Noor.'),
                      trailing: _selectedUsers.isNotEmpty
                          ? Checkbox(
                              value: isSelected,
                              activeColor: AppColors.primary,
                              shape: const CircleBorder(),
                              onChanged: (_) => _toggleSelection(user),
                            )
                          : null,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUserTap(ProfileEntity user) async {
    if (_selectedUsers.isNotEmpty) {
      _toggleSelection(user);
    } else {
      // 1-on-1 Flow: LAZY creation (Deferred until first message)
      // Check if it already exists purely to choose between Real ID and Draft ID
      
      // Brief check for existing chat (to avoid draft flickering)
      // We use the Repo's logic which is now consolidated
      final existingChatId = await ref.read(chatRepositoryProvider).findExistingPrivateChat(user.id);
      
      if (!mounted) return;

      if (existingChatId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatId: existingChatId, 
              chatTitle: user.fullName,
              chatAvatar: user.avatarUrl,
            ),
          ),
        );
      } else {
        // OPEN AS DRAFT
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatId: 'draft_${user.id}',
              chatTitle: user.fullName,
              chatAvatar: user.avatarUrl,
              initialProfile: user,
            ),
          ),
        );
      }
    }
  }

  void _toggleSelection(ProfileEntity user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }
}
