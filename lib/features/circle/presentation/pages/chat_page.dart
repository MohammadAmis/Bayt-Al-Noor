import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../widgets/chat_window/message_bubble.dart';
import '../widgets/chat_window/message_input_bar.dart';
import '../widgets/chat_window/typing_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'chat_info_page.dart';
import 'package:collection/collection.dart';

import '../../domain/entities/message_entity.dart';
import '../../domain/entities/profile_entity.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String? chatId;
  final String chatTitle;
  final String? chatAvatar;
  final String chatType; // 'private' | 'group' | 'community'
  final ProfileEntity? initialProfile; // For lazy creation (Drafts)

  const ChatPage({
    super.key,
    this.chatId,
    required this.chatTitle,
    this.chatAvatar,
    this.chatType = 'group',
    this.initialProfile,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  MessageEntity? _replyingTo; // the message being replied to
  final ScrollController _scrollController = ScrollController();

  String get _providerKey => widget.chatId ?? 'draft_${widget.initialProfile?.id}';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider(_providerKey,
        initialProfile: widget.initialProfile));
    final notifier = ref.read(chatViewModelProvider(_providerKey,
            initialProfile: widget.initialProfile)
        .notifier);

    ref.listen(
      chatViewModelProvider(_providerKey, initialProfile: widget.initialProfile)
          .select((s) => s.error),
      (prev, next) {
        if (next != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    final isDraft = widget.chatId == null || widget.chatId!.startsWith('draft_');

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: isDraft
              ? null
              : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatInfoPage(
                        chatId: widget.chatId!,
                        chatName: state.chatName,
                        chatType: widget.chatType,
                      ),
                    ),
                  ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: widget.chatAvatar != null
                    ? NetworkImage(widget.chatAvatar!)
                    : null,
                child: widget.chatAvatar == null
                    ? Icon(widget.chatType == 'private'
                        ? Icons.person_rounded
                        : Icons.groups_rounded)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.chatName == 'Loading...'
                          ? widget.chatTitle
                          : state.chatName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (state.typingUsers.isNotEmpty)
                      const Text(
                        'typing...',
                        style: TextStyle(fontSize: 11, color: Colors.green),
                      )
                    else if (!isDraft)
                      Text(
                        widget.chatType == 'private'
                            ? 'Tap for profile'
                            : 'Tap for info',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Message list ──
          Expanded(
            child: state.messages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      MessageEntity? repliedMessage;
                      if (message.replyToMessageId != null) {
                        repliedMessage = state.messages.firstWhereOrNull((m) => m.id == message.replyToMessageId);
                      }
                      
                      return MessageBubble(
                        message: message,
                        repliedMessage: repliedMessage,
                        onResend: message.status == MessageStatus.failed
                            ? () => notifier.sendMessage(message.content)
                            : null,
                        onReply: (msg) =>
                            setState(() => _replyingTo = msg),
                        onReact: (emoji) {
                          notifier.reactToMessage(message.id, emoji);
                        },
                        onDelete: message.isMine
                            ? () {
                                notifier.deleteMessage(message.id);
                              }
                            : null,
                      );
                    },
                  ),
          ),

          // ── Typing indicator ──
          if (state.typingUsers.isNotEmpty) const TypingIndicator(),

          // ── Reply banner ──
          if (_replyingTo != null) _buildReplyBanner(),

          // ── Input bar ──
          MessageInputBar(
            replyingTo: _replyingTo,
            onCancelReply: () => setState(() => _replyingTo = null),
            onSend: (data, isImage) {
              if (isImage) {
                notifier.sendImageMessage(data as XFile, replyToMessageId: _replyingTo?.id);
              } else {
                notifier.sendMessage(data as String, replyToMessageId: _replyingTo?.id);
              }
              setState(() => _replyingTo = null);
            },
            onTypingStart: () => notifier.startTyping(),
            onTypingStop: () => notifier.stopTyping(),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Replying to',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue)),
                Text(
                  _replyingTo!.content.isEmpty
                      ? '[Attachment]'
                      : _replyingTo!.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _replyingTo = null),
          ),
        ],
      ),
    );
  }
}
