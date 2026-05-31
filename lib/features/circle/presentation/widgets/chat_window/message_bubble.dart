import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../../../core/design_tokens.dart';
import 'message_status_icon.dart';
import 'message_reactions.dart';
import '../../../../../core/widgets/full_screen_image_viewer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final MessageEntity? repliedMessage;
  final VoidCallback? onResend;
  final ValueChanged<MessageEntity>? onReply; // swipe-to-reply callback
  final ValueChanged<String>? onReact;
  final VoidCallback? onDelete;

  const MessageBubble({
    super.key,
    required this.message,
    this.repliedMessage,
    this.onResend,
    this.onReply,
    this.onReact,
    this.onDelete,
  });

  // ─── Colors ──────────────────────────────────────────────────────────────
  Color get _bubbleColor => message.isMine
      ? AppColors.primary.withValues(alpha: 0.85)
      : AppColors.surfaceContainerHigh;

  Color get _textColor =>
      message.isMine ? Colors.white : AppColors.onSurface;

  // ─── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('swipe_${message.id}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        if (message.id.startsWith('temp_')) return false; // Cannot reply to unsynced messages
        onReply?.call(message);
        return false; // never actually dismiss
      },
      background: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.reply_rounded,
              color: AppColors.primary.withValues(alpha: 0.6), size: 28),
        ),
      ),
      child: GestureDetector(
        onLongPress: () => _showContextMenu(context),
        onSecondaryTapDown: (_) => _showContextMenu(context),
        child: Align(
          alignment:
              message.isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 12, right: 12),
              child: Column(
                crossAxisAlignment: message.isMine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // ── Reply preview ──
                  if (message.replyToMessageId != null) _buildReplyPreview(),

                  // ── Bubble ──
                  _buildBubble(context),

                  // ── Meta: time + status ──
                  const SizedBox(height: 3),
                  _buildMeta(context),

                  // ── Reactions ──
                  if (message.reactions != null &&
                      message.reactions!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: MessageReactions(
                        reactions: message.reactions!.map(
                          (emoji, users) => MapEntry(emoji, users.length),
                        ),
                        myReaction: _getMyReaction(),
                        onReact: (emoji) => onReact?.call(emoji),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Bubble Container ────────────────────────────────────────────────────
  Widget _buildBubble(BuildContext context) {
    final isFailed = message.status == MessageStatus.failed;
    final isImage = message.type == MessageType.image;
    
    final bubble = Container(
      padding: isImage 
          ? EdgeInsets.zero 
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isFailed
            ? AppColors.error.withValues(alpha: 0.1)
            : _bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(message.isMine ? 18 : 4),
          bottomRight: Radius.circular(message.isMine ? 4 : 18),
        ),
        border: isFailed
            ? Border.all(color: AppColors.error.withValues(alpha: 0.4))
            : null,
      ),
      child: _renderBody(context),
    );

    return Stack(
      children: [
        bubble,
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _showContextMenu(context),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: _textColor.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Message Types ───────────────────────────────────────────────────────
  Widget _renderBody(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Text(
            message.content,
            style: AppTypography.body.copyWith(
              color: _textColor,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        );

      case MessageType.image:
        final bool hasText = message.content.isNotEmpty;
        final BorderRadius imageRadius = BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: hasText ? Radius.zero : Radius.circular(message.isMine ? 18 : 4),
          bottomRight: hasText ? Radius.zero : Radius.circular(message.isMine ? 4 : 18),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                if (message.resourceUrl == null || message.resourceUrl!.isEmpty) return;
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => FullScreenImageViewer(
                      imageUrl: message.resourceUrl!,
                      heroTag: 'image_${message.id}',
                    ),
                  ),
                );
              },
              child: Hero(
                tag: 'image_${message.id}',
                child: ClipRRect(
                  borderRadius: imageRadius,
                  child: kIsWeb
                  ? Image.network(
                      message.resourceUrl ?? '',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 200,
                        height: 200,
                        color: Colors.transparent,
                        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.transparent,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                    )
                  : CachedNetworkImage(
                      imageUrl: message.resourceUrl ?? '',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 200,
                        height: 200,
                        color: Colors.transparent,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 200,
                        height: 200,
                        color: Colors.transparent,
                        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                      ),
                    ),
                ),
              ),
            ),
            if (message.content.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 8),
                child: Text(message.content,
                    style: AppTypography.body.copyWith(color: _textColor)),
              ),
            ],
          ],
        );

      case MessageType.file:
        return Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (message.isMine ? Colors.white : AppColors.primary)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.insert_drive_file_outlined,
                size: 22,
                color: message.isMine ? Colors.white70 : AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message.metadata?['name'] ?? 'Document',
                style: AppTypography.bodyMedium.copyWith(color: _textColor),
              ),
            ),
          ],
        )
      );

      default:
        return Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Text(message.content,
              style: AppTypography.body.copyWith(color: _textColor)),
        );
    }
  }

  // ─── Reply Preview ───────────────────────────────────────────────────────
  Widget _buildReplyPreview() {
    final previewText = repliedMessage != null
        ? (repliedMessage!.content.isEmpty ? '[Attachment]' : repliedMessage!.content)
        : 'Loading original message...';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Text(
        previewText,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  String? _getMyReaction() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || message.reactions == null) return null;
    
    for (var entry in message.reactions!.entries) {
      if (entry.value.contains(userId)) {
        return entry.key;
      }
    }
    return null;
  }

  // ─── Meta Row ────────────────────────────────────────────────────────────
  Widget _buildMeta(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(message.createdAt),
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
        if (message.isMine) ...[
          const SizedBox(width: 4),
          MessageStatusIcon(status: message.status),
          if (message.status == MessageStatus.failed && onResend != null)
            GestureDetector(
              onTap: onResend,
              child: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.refresh_rounded,
                    size: 13, color: AppColors.error),
              ),
            ),
        ],
      ],
    );
  }

  // ─── Long-press context menu ─────────────────────────────────────────────
  void _showContextMenu(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (ctx) => Stack(
        children: [
          Positioned(
            top: offset.dy - 130,
            left: message.isMine ? null : offset.dx,
            right: message.isMine ? 16 : null,
            child: EmojiPickerBar(
              onReply: () => onReply?.call(message),
              onReact: (emoji) => onReact?.call(emoji),
              onCopy: message.type == MessageType.text
                  ? () => Clipboard.setData(
                      ClipboardData(text: message.content))
                  : null,
              onDelete: message.isMine ? onDelete : null,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
  String _formatTime(DateTime time) {
    final t = time.toLocal();
    final h = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    final a = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $a';
  }
}