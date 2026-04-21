import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final VoidCallback? onResend;

  const MessageBubble({
    super.key,
    required this.message,
    this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
          child: Column(
            crossAxisAlignment: message.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              _buildContent(),
              const SizedBox(height: 4),
              _buildMeta(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final isFailed = message.status == MessageStatus.failed;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isFailed 
            ? Colors.red.withValues(alpha: 0.1) 
            : (message.isMine ? Colors.blue[100] : Colors.grey[200]),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(message.isMine ? 16 : 4),
          bottomRight: Radius.circular(message.isMine ? 4 : 16),
        ),
      ),
      child: _renderBody(),
    );
  }

  Widget _renderBody() {
    switch (message.type) {
      case MessageType.text:
        return Text(message.content);
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: message.resourceUrl ?? '',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
              ),
            ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(message.content),
            ],
          ],
        );
      case MessageType.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file, color: message.isMine ? Colors.blue[700] : Colors.grey[700]),
            const SizedBox(width: 8),
            Flexible(child: Text(message.metadata?['name'] ?? 'Document')),
          ],
        );
      default:
        return Text(message.content);
    }
  }

  Widget _buildMeta() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(message.createdAt),
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
          const SizedBox(width: 4),
          if (message.isMine) ...[
            _buildStatusIcon(),
            if (message.status == MessageStatus.failed)
              IconButton(
                icon: const Icon(Icons.refresh, size: 12),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: onResend,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time, size: 12, color: Colors.grey);
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 12, color: Colors.grey);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 12, color: Colors.grey);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 12, color: Colors.blue);
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatTime(DateTime time) {
    final localTime = time.toLocal();
    final hourNum = localTime.hour == 0 ? 12 : (localTime.hour > 12 ? localTime.hour - 12 : localTime.hour);
    final minute = localTime.minute.toString().padLeft(2, '0');
    final amPm = localTime.hour >= 12 ? 'PM' : 'AM';
    return "$hourNum:$minute $amPm";
  }
}