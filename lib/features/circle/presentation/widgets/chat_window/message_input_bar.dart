import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MessageInputBar extends StatefulWidget {
  final Function(String text, bool isImage) onSend;
  final VoidCallback onTypingStart;

  const MessageInputBar({
    super.key,
    required this.onSend,
    required this.onTypingStart,
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
      setState(() => _hasText = _ctrl.text.trim().isNotEmpty);
      if (_hasText) widget.onTypingStart();
    });
  }

  Future<void> _showAttachmentPicker() async {
    final picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildPickerOption(
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              onTap: () async {
                Navigator.pop(ctx);
                final photo = await picker.pickImage(source: ImageSource.camera);
                if (photo != null) widget.onSend(photo.path, true);
              },
            ),
            _buildPickerOption(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              onTap: () async {
                Navigator.pop(ctx);
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) widget.onSend(image.path, true);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
              onPressed: _showAttachmentPicker,
            ),
            Expanded(
              child: TextField(
                controller: _ctrl,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _hasText
                  ? FloatingActionButton(
                      key: const ValueKey('send'),
                      mini: true,
                      elevation: 2,
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        widget.onSend(_ctrl.text.trim(), false);
                        _ctrl.clear();
                      },
                    )
                  : FloatingActionButton(
                      key: const ValueKey('mic'),
                      mini: true,
                      elevation: 2,
                      child: const Icon(Icons.mic),
                      onPressed: () {
                        // TODO: Voice recording logic
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}