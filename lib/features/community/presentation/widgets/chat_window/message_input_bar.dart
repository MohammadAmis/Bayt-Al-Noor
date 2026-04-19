import 'package:flutter/material.dart';

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
              onPressed: () {
                // TODO: Open attachment picker (Camera/Gallery/Files)
              },
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