import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../data/models/message_model.dart';
import 'package:intl/intl.dart';

class ChatMessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isGroupChat;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isGroupChat = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isMe = message.isMe;
    
    // User-specific coloring for group chat
    Color bubbleColor = _getBubbleColor(isMe);
    Color textColor = _getTextColor(isMe);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) _buildAvatar(),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && isGroupChat)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      message.senderName,
                      style: AppTypography.label.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: bubbleColor.withValues(alpha:0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                _buildContent(context, bubbleColor, textColor, isMe),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(message.timestamp),
                      style: AppTypography.label.copyWith(
                        fontSize: 9,
                        color: AppColors.onSurfaceVariant.withValues(alpha:0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.done_all, size: 12, color: AppColors.primary.withValues(alpha:0.4)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isMe) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha:0.2), width: 1),
        image: DecorationImage(
          image: NetworkImage(message.senderAvatar),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color bubbleColor, Color textColor, bool isMe) {
    switch (message.type) {
      case MessageType.image:
        return _buildImageContent(context);
      case MessageType.file:
        return _buildFileContent(context, bubbleColor, textColor, isMe);
      case MessageType.text:
        return _buildTextContent(bubbleColor, textColor, isMe);
    }
  }

  Widget _buildTextContent(Color bubbleColor, Color textColor, bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isMe ? 20 : 0),
          bottomRight: Radius.circular(isMe ? 0 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: bubbleColor.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        message.content,
        style: AppTypography.body.copyWith(
          color: textColor,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    return Column(
      crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: message.attachmentUrl!.startsWith('assets/')
              ? Image.asset(
                  message.attachmentUrl!,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  message.attachmentUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 200,
                      height: 150,
                      color: AppColors.surfaceContainerLow,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                ),
        ),
        if (message.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
            child: Text(
              message.content,
              style: AppTypography.body.copyWith(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFileContent(BuildContext context, Color bubbleColor, Color textColor, bool isMe) {
    return GestureDetector(
      onTap: () => _showFileActionDialog(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: textColor.withValues(alpha:0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getFileIcon(),
                    color: textColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.fileMetadata?.name ?? 'Document',
                        style: AppTypography.title.copyWith(
                          fontSize: 14,
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        message.fileMetadata?.size ?? 'Unknown size',
                        style: AppTypography.body.copyWith(
                          fontSize: 10,
                          color: textColor.withValues(alpha:0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                message.content,
                style: AppTypography.body.copyWith(
                  fontSize: 13,
                  color: textColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon() {
    final ext = message.fileMetadata?.extension.toLowerCase();
    if (ext == 'pdf') return Icons.picture_as_pdf;
    if (['doc', 'docx'].contains(ext)) return Icons.description;
    if (['xls', 'xlsx'].contains(ext)) return Icons.table_chart;
    return Icons.insert_drive_file;
  }

  Color _getBubbleColor(bool isMe) {
    if (isMe) return AppColors.primary;
    
    // Group chat palette
    final List<Color> palette = [
      AppColors.primaryContainer,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.surfaceTint,
      const Color(0xFF5D4201),
    ];
    
    // Use senderId to pick a consistent color
    final int colorIndex = message.senderId.hashCode.abs() % palette.length;
    return palette[colorIndex];
  }

  Color _getTextColor(bool isMe) {
    // For most of our deep brand colors, white is best
    return Colors.white;
  }

  void _showFileActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppShapes.xlRadius),
        title: Row(
          children: [
            Icon(_getFileIcon(), color: AppColors.primary),
            const SizedBox(width: 12),
            const Text('Sacred Document Reader'),
          ],
        ),
        content: Text(
          'Opening "${message.fileMetadata?.name}" in the secure sanctuary viewer...',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('DOWNLOAD'),
          ),
        ],
      ),
    );
  }
}
