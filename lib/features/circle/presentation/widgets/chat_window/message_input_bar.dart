import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/design_tokens.dart';
import '../../../domain/entities/message_entity.dart';

class MessageInputBar extends StatefulWidget {
  final Function(dynamic data, bool isImage) onSend;
  final VoidCallback onTypingStart;
  final VoidCallback? onTypingStop;
  final MessageEntity? replyingTo;   // non-null → user is replying
  final VoidCallback? onCancelReply;

  const MessageInputBar({
    super.key,
    required this.onSend,
    required this.onTypingStart,
    this.onTypingStop,
    this.replyingTo,
    this.onCancelReply,
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final TextEditingController _ctrl = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final hasText = _ctrl.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
        if (hasText) {
          widget.onTypingStart();
        } else {
          widget.onTypingStop?.call();
        }
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _showAttachmentPicker() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Share Media',
              style: AppTypography.titleMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPickerOption(
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              color: AppColors.primary,
              onTap: () async {
                Navigator.pop(ctx);
                final photo =
                    await picker.pickImage(source: ImageSource.camera);
                if (photo != null) widget.onSend(photo, true);
              },
            ),
            _buildPickerOption(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              color: AppColors.secondary,
              onTap: () async {
                Navigator.pop(ctx);
                final image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image != null) widget.onSend(image, true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: AppTypography.bodyMedium
            .copyWith(fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    );
  }

  void _sendMessage() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text, false);
    _ctrl.clear();
    widget.onTypingStop?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.15)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.onSurfaceVariant),
              onPressed: _showAttachmentPicker,
            ),

            // Text field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _ctrl,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null, // expands naturally
                  keyboardType: TextInputType.multiline,
                  style: AppTypography.body
                      .copyWith(color: AppColors.onSurface, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: widget.replyingTo != null
                        ? 'Reply...'
                        : 'Type a message...',
                    hintStyle: AppTypography.body.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                        fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send / Mic animated button
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: _hasText
                  ? _ActionButton(
                      key: const ValueKey('send'),
                      icon: Icons.send_rounded,
                      color: AppColors.primary,
                      onTap: _sendMessage,
                    )
                  : _ActionButton(
                      key: const ValueKey('mic'),
                      icon: Icons.mic_rounded,
                      color: AppColors.secondary,
                      onTap: () {
                        // TODO: Voice recording
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small circular action button ────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}