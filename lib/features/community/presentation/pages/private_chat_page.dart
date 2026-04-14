import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../data/models/message_model.dart';
import '../widgets/chat_message_bubble.dart';

class PrivateChatPage extends StatefulWidget {
  const PrivateChatPage({super.key});

  @override
  State<PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  final TextEditingController _msgController = TextEditingController();
  final List<MessageModel> _messages = [
    MessageModel(
      id: '1',
      senderId: 'amir',
      senderName: 'Amir Al-Hussein',
      senderAvatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBCJK2wMGg9gMZiUvgQIGnRElk5TNAbyKemys1O17W0kXuyhkl5XylevUyfHrTa9Hop7ubE0lFzqujFUp-j_ZYjFAON2i72aSzYlVsv6h3TvC0D2Ft7KsWAwB8zGVZkE5mWCPcNtirz2RUxCbbbSVxXqirYVkoLN3CIPW-sK6jShiDfrDvRVpFGp9Wjf3IZ_jfBIGsQQCqIGgP5M7JPxAoJ8fxmeiM7Do8heijs_p03yjZw2Vu9gEgK2PlhDPEi-khNkk6FpnaG9Kw',
      content: 'As-salamu alaykum. I was reflecting on the beauty of patience this morning. How has your journey been today?',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      type: MessageType.text,
    ),
    MessageModel(
      id: '2',
      senderId: 'me',
      senderName: 'Me',
      senderAvatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCoPf0_OVJGtQL1VLBHj_BWlUEvtc_2YxY7Wal2UFlivzaUlP46_E-gMUmYsw3746_IxdvtloEeJc3Xe-RIsfTq3RIanl1nKNsyqy8YNFj5bzOj4yCGqYaYsX_2UfIwqCRFJiLOeBPEXKcuuvR-BFvMGeG1TsHwtBXnV3gf9U2-MRAzrESDxoZ1UN3jn9CWRoWWRBPetjZSkyDMUKDDfW1feEtfoM5Q8YP_88skWW1lPA40eFkY9xzbtkvcdVMCx7NCk2xB7W0Il_s',
      content: 'Wa alaykum as-salam, Amir. I\'ve attached my notes from this morning\'s contemplation.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
      type: MessageType.file,
      fileMetadata: FileMetadata(
        name: 'Morning_Reflections.pdf',
        size: '1.2 MB',
        extension: 'pdf',
      ),
    ),
    MessageModel(
      id: '3',
      senderId: 'amir',
      senderName: 'Amir Al-Hussein',
      senderAvatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBCJK2wMGg9gMZiUvgQIGnRElk5TNAbyKemys1O17W0kXuyhkl5XylevUyfHrTa9Hop7ubE0lFzqujFUp-j_ZYjFAON2i72aSzYlVsv6h3TvC0D2Ft7KsWAwB8zGVZkE5mWCPcNtirz2RUxCbbbSVxXqirYVkoLN3CIPW-sK6jShiDfrDvRVpFGp9Wjf3IZ_jfBIGsQQCqIGgP5M7JPxAoJ8fxmeiM7Do8heijs_p03yjZw2Vu9gEgK2PlhDPEi-khNkk6FpnaG9Kw',
      content: '', // No caption needed as it is self-contained
      timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
      type: MessageType.image,
      attachmentUrl: 'assets/reflection_verse.png',
    ),
    MessageModel(
      id: '4',
      senderId: 'amir',
      senderName: 'Amir Al-Hussein',
      senderAvatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBCJK2wMGg9gMZiUvgQIGnRElk5TNAbyKemys1O17W0kXuyhkl5XylevUyfHrTa9Hop7ubE0lFzqujFUp-j_ZYjFAON2i72aSzYlVsv6h3TvC0D2Ft7KsWAwB8zGVZkE5mWCPcNtirz2RUxCbbbSVxXqirYVkoLN3CIPW-sK6jShiDfrDvRVpFGp9Wjf3IZ_jfBIGsQQCqIGgP5M7JPxAoJ8fxmeiM7Do8heijs_p03yjZw2Vu9gEgK2PlhDPEi-khNkk6FpnaG9Kw',
      content: 'This verse always brings peace to the heart. SubhanAllah.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
      type: MessageType.text,
    ),
  ];

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;
    setState(() {
      _messages.add(MessageModel(
        id: DateTime.now().toString(),
        senderId: 'me',
        senderName: 'Me',
        senderAvatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCoPf0_OVJGtQL1VLBHj_BWlUEvtc_2YxY7Wal2UFlivzaUlP46_E-gMUmYsw3746_IxdvtloEeJc3Xe-RIsfTq3RIanl1nKNsyqy8YNFj5bzOj4yCGqYaYsX_2UfIwqCRFJiLOeBPEXKcuuvR-BFvMGeG1TsHwtBXnV3gf9U2-MRAzrESDxoZ1UN3jn9CWRoWWRBPetjZSkyDMUKDDfW1feEtfoM5Q8YP_88skWW1lPA40eFkY9xzbtkvcdVMCx7NCk2xB7W0Il_s',
        content: _msgController.text,
        timestamp: DateTime.now(),
        type: MessageType.text,
      ));
      _msgController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatMessageBubble(
                  message: message,
                  isGroupChat: false,
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.teal[50]?.withValues(alpha:0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF00342B)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBCJK2wMGg9gMZiUvgQIGnRElk5TNAbyKemys1O17W0kXuyhkl5XylevUyfHrTa9Hop7ubE0lFzqujFUp-j_ZYjFAON2i72aSzYlVsv6h3TvC0D2Ft7KsWAwB8zGVZkE5mWCPcNtirz2RUxCbbbSVxXqirYVkoLN3CIPW-sK6jShiDfrDvRVpFGp9Wjf3IZ_jfBIGsQQCqIGgP5M7JPxAoJ8fxmeiM7Do8heijs_p03yjZw2Vu9gEgK2PlhDPEi-khNkk6FpnaG9Kw'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amir Al-Hussein',
                style: AppTypography.headline.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00342B),
                ),
              ),
              Text(
                'ACTIVE NOW',
                style: AppTypography.label.copyWith(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF004D40).withValues(alpha:0.6),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.outline),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha:0.2))),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: AppColors.primary),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _msgController,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: AppTypography.body.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha:0.4),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                style: AppTypography.body.copyWith(fontSize: 14),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
