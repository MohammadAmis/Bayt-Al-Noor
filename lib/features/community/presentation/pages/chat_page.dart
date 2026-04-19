import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../widgets/chat_window/message_bubble.dart';
import '../widgets/chat_window/message_input_bar.dart';
import 'chat_info_page.dart';

import '../../domain/entities/profile_entity.dart';

class ChatPage extends ConsumerWidget {
  final String? chatId;
  final String chatTitle;
  final String? chatAvatar;
  final ProfileEntity? initialProfile; // For lazy creation (Drafts)

  const ChatPage({
    super.key,
    this.chatId,
    required this.chatTitle,
    this.chatAvatar,
    this.initialProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We use the chatId as the provider key. If it's a draft, it will be 'draft_UUID'
    final state = ref.watch(chatViewModelProvider(chatId ?? 'draft_${initialProfile?.id}', initialProfile: initialProfile));
    final notifier = ref.read(chatViewModelProvider(chatId ?? 'draft_${initialProfile?.id}', initialProfile: initialProfile).notifier);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: (chatId == null || chatId!.startsWith('draft_')) ? null : () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatInfoPage(chatId: chatId!, chatName: state.chatName),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: chatAvatar != null ? NetworkImage(chatAvatar!) : null,
                child: chatAvatar == null ? const Icon(Icons.group) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.chatName == 'Loading...' ? chatTitle : state.chatName, 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (state.typingUsers.isNotEmpty)
                      const Text(
                        'Typing...',
                        style: TextStyle(fontSize: 12, color: Colors.green),
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
          Expanded(
            child: state.messages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    reverse: true,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return MessageBubble(
                        message: message,
                      );
                    },
                  ),
          ),
          MessageInputBar(
            onSend: (text, isImage) {
              notifier.sendMessage(text);
            },
            onTypingStart: () {
              notifier.startTyping();
            },
          ),
        ],
      ),
    );
  }
}