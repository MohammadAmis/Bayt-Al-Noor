import 'package:flutter/material.dart';
import '../../../domain/entities/message_entity.dart';

/// Tick icons for message delivery status (sent / delivered / read).
class MessageStatusIcon extends StatelessWidget {
  final MessageStatus status;
  const MessageStatusIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey);
      case MessageStatus.sent:
        return const Icon(Icons.check_rounded, size: 13, color: Colors.grey);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all_rounded, size: 13, color: Colors.grey);
      case MessageStatus.read:
        return const Icon(Icons.done_all_rounded, size: 13, color: Color(0xFF4FC3F7));
      case MessageStatus.failed:
        return const Icon(Icons.error_outline_rounded, size: 13, color: Colors.redAccent);
    }
  }
}
