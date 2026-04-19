import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/profile_entity.dart';
import '../../data/providers/chat_providers.dart';
import 'chat_page.dart';

class GroupDetailsPage extends ConsumerStatefulWidget {
  final List<ProfileEntity> selectedUsers;

  const GroupDetailsPage({
    super.key,
    required this.selectedUsers,
  });

  @override
  ConsumerState<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends ConsumerState<GroupDetailsPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const AppTopBar(
        title: 'New Circle Details',
        isMainScreen: false,
        location: 'Creation',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hub_outlined, size: 48, color: AppColors.primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Circle Name',
                hintText: 'e.g., Weekly Dhikr, Noble Family',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Members: ${widget.selectedUsers.length}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.selectedUsers.length,
                itemBuilder: (context, index) {
                  final user = widget.selectedUsers[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                          child: user.avatarUrl == null ? Text(user.fullName[0].toUpperCase()) : null,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.fullName.split(' ')[0],
                          style: const TextStyle(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isCreating ? null : _handleCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isCreating 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Create Circle'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please name your Circle')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final repo = ref.read(chatRepositoryProvider);
      
      // 1. Create the chat row
      final newChat = await repo.createChat(
        type: 'group',
        name: name,
      );

      // 2. Add all selected members
      final memberIds = widget.selectedUsers.map((u) => u.id).toList();
      await repo.addMembers(newChat.id, memberIds);

      if (!mounted) return;
      
      // 3. Navigate straight to the new chat
      // We pop twice: once from details, once from selection
      Navigator.pop(context); 
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(chatId: newChat.id, chatTitle: name),
        ),
      );
    } catch (e) {
      setState(() => _isCreating = false);
      if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create Circle: $e')),
      );
    }
  }
}
