import 'package:flutter/material.dart';

class AddMembersPage extends StatefulWidget {
  final String chatId;
  const AddMembersPage({super.key, required this.chatId});

  @override
  State<AddMembersPage> createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  final List<String> _selectedUsers = [];
  final List<Map<String, String>> _allUsers = [
    {'id': 'u4', 'name': 'Ahmed'},
    {'id': 'u5', 'name': 'Fatima'},
    {'id': 'u6', 'name': 'Omar'},
  ]; // In production: fetch from UserRepository

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Members'),
        actions: [
          if (_selectedUsers.isNotEmpty)
            TextButton(
              onPressed: _confirmAdd,
              child: Text('ADD (${_selectedUsers.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or username...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _allUsers.length,
              itemBuilder: (_, i) {
                final user = _allUsers[i];
                final isSelected = _selectedUsers.contains(user['id']);
                return ListTile(
                  leading: CircleAvatar(child: Text(user['name']![0])),
                  title: Text(user['name']!),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (val) => setState(() {
                      if (val == true) {
                        _selectedUsers.add(user['id']!);
                      } else {
                        _selectedUsers.remove(user['id']!);
                      }
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAdd() {
    // Call ViewModel: ref.read(chatInfoProvider(widget.chatId).notifier).addMembers(_selectedUsers);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_selectedUsers.length} member(s) added')),
    );
  }
}