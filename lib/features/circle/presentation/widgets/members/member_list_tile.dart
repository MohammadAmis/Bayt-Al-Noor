import 'package:flutter/material.dart';
import '../../../domain/entities/member_entity.dart';

class MemberListTile extends StatelessWidget {
  final MemberEntity member;
  final bool isCurrentUser;
  final Function(String userId, String newRole) onRoleChanged;
  final Function(String userId) onRemoved;

  const MemberListTile({
    super.key,
    required this.member,
    required this.isCurrentUser,
    required this.onRoleChanged,
    required this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
    
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: member.avatarUrl != null 
            ? NetworkImage(member.avatarUrl!) 
            : null,
        child: member.avatarUrl == null 
            ? Text(member.name[0].toUpperCase(), style: const TextStyle(fontSize: 16))
            : null,
      ),
      title: Row(
        children: [
          Expanded(child: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w500))),
          if (member.role != 'member')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: member.role == 'owner' ? Colors.amber.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                member.role.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: member.role == 'owner' ? Colors.amber[800] : Colors.blue[800],
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(isCurrentUser ? 'You' : 'Last seen recently', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: isCurrentUser
          ? null
          : PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (value) {
                switch (value) {
                  case 'promote': onRoleChanged(member.userId, 'admin'); break;
                  case 'demote': onRoleChanged(member.userId, 'member'); break;
                  case 'remove': onRemoved(member.userId); break;
                }
              },
              itemBuilder: (context) => [
                if (member.role == 'member')
                  const PopupMenuItem(value: 'promote', child: Text('Make Admin')),
                if (member.role == 'admin')
                  const PopupMenuItem(value: 'demote', child: Text('Demote to Member')),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove from Group', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
    );
  }
}