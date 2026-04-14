import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../data/models/message_model.dart';
import '../widgets/chat_message_bubble.dart';

class CommunityChatPage extends StatefulWidget {
  const CommunityChatPage({super.key});

  @override
  State<CommunityChatPage> createState() => _CommunityChatPageState();
}

class _CommunityChatPageState extends State<CommunityChatPage> {
  final TextEditingController _msgController = TextEditingController();
  final List<MessageModel> _messages = [
    MessageModel(
      id: '1',
      senderId: 'sarah',
      senderName: 'Sarah J.',
      senderAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBY5AjBhl6Faf4iPQxqgUDduixellgB7VC7W5gwsfmlhBLhPFdzQWamAq9ajcBpLIEgjfD2npnnQbVnhK-RwnB7oP0R25tfvaMwZI2ivSGY7xoztYfk6kg8TkiXEQK6zUurJmo3gdgUKCasoyXiQ6CAUWZ8OHkBOI9s9cPPOOyYXtG_Hu0Tkedvh5nMrPnRhAi3H_RCqKnoOAbnw3UFFhiylUPVp33yjrE3g3_mDTobv2xLFZuIrJA2KqO_H3h3jXIPB5Kp7so984w',
      content:
          'The peace in the air during Fajr today was truly remarkable. Does anyone else find the silence of the dawn to be the clearest time for reflection?',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      type: MessageType.text,
    ),
    MessageModel(
      id: '2',
      senderId: 'omar',
      senderName: 'Omar K.',
      senderAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAVrv9yt9MDGn3Raf7QSwiDCUR94L2Bi7vU-MOdu5VUhRWplXoDyfBV6Wpd4EWetlcfQfQXiFeWmeszwFrFQcWC0J9PAexcG6MDXiea-q6YpyjqdfUllOIV5e9OVDY-sIUmORsoEN9RPVoLdKprDkC5PQv3AgV8XKbEwlNrfiNg7dbDlwYHPdXlQz-mQJJPLTyf6dUHdX5Q5RH_T4zyqg95KCoxaCHSFiqsQfZ-oYJnjJ6e1lFZNaFD060oyXkrBWFUoWT-7UQQnn4',
      content:
          'Absolutely, Sarah. It feels like the world hasn\'t quite woken up to its noise yet.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      type: MessageType.text,
    ),
    MessageModel(
      id: '3',
      senderId: 'me',
      senderName: 'Me',
      senderAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCoPf0_OVJGtQL1VLBHj_BWlUEvtc_2YxY7Wal2UFlivzaUlP46_E-gMUmYsw3746_IxdvtloEeJc3Xe-RIsfTq3RIanl1nKNsyqy8YNFj5bzOj4yCGqYaYsX_2UfIwqCRFJiLOeBPEXKcuuvR-BFvMGeG1TsHwtBXnV3gf9U2-MRAzrESDxoZ1UN3jn9CWRoWWRBPetjZSkyDMUKDDfW1feEtfoM5Q8YP_88skWW1lPA40eFkY9xzbtkvcdVMCx7NCk2xB7W0Il_s',
      content:
          'I\'ve been using the new timeline feature to track my morning dhikr. It helps maintain that focus.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: MessageType.text,
    ),
    MessageModel(
      id: '4',
      senderId: 'zaid',
      senderName: 'Zaid A.',
      senderAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD5y5gtsOjbBE7LbpvBfmKo8fZbKpZceBr0xFGR0rtDEEJAApzvFsfTtlRsyDGWr1vejenevOOo5AwgE3rQMBgeMtixBRqZNDyBXgTcSFsSI-8zrCW6dlZOVLd_0IZlq0kPXX1Z1YFIek_74QK8Oc_mFSA_6SZyUD6lyZE2ozMCWdrunixdrW7uJrZVgPDkZjrsnegc30nHs5E9ZwRrql9KXHQaoNp-OaAAYCLzDIj-jdso_uFAHiuDODph3Mm0Jwiwwa_dTYSTtzE',
      content:
          'Just uploaded the PDF for the upcoming community service project. Please review when you can.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      type: MessageType.file,
      fileMetadata: FileMetadata(
        name: 'Community_Project_v2.pdf',
        size: '2.4 MB',
        extension: 'pdf',
      ),
    ),
    MessageModel(
      id: '5',
      senderId: 'sarah',
      senderName: 'Sarah J.',
      senderAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBY5AjBhl6Faf4iPQxqgUDduixellgB7VC7W5gwsfmlhBLhPFdzQWamAq9ajcBpLIEgjfD2npnnQbVnhK-RwnB7oP0R25tfvaMwZI2ivSGY7xoztYfk6kg8TkiXEQK6zUurJmo3gdgUKCasoyXiQ6CAUWZ8OHkBOI9s9cPPOOyYXtG_Hu0Tkedvh5nMrPnRhAi3H_RCqKnoOAbnw3UFFhiylUPVp33yjrE3g3_mDTobv2xLFZuIrJA2KqO_H3h3jXIPB5Kp7so984w',
      content: 'Look at the light this morning! SubhanAllah.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      type: MessageType.image,
      attachmentUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDXXh5yi08o5Kmwfa1XT1xjVngUL75vfu701yP1nVeHTAXgT_xlD_Isa8AmuxkQ9rK-6OnBqr9otHnHjhihZPfSg60hRkXiiEKy7gYsfzba_VxSqk0NP1kda9uqQ_-y0ReFqeWfhSapJNAdtyZU-gQjo4mZqp5OfVsgNVhzXU3qHWhcD8ImUIQymz1lsC_LPpKYv08AJGd7jcxwrElWS4JQlBp7oIeE2EY0_hHoxIPABz2w4R5ThkfOS-tBGhpgtXBiUCClfOFiOao',
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
        senderAvatar:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCoPf0_OVJGtQL1VLBHj_BWlUEvtc_2YxY7Wal2UFlivzaUlP46_E-gMUmYsw3746_IxdvtloEeJc3Xe-RIsfTq3RIanl1nKNsyqy8YNFj5bzOj4yCGqYaYsX_2UfIwqCRFJiLOeBPEXKcuuvR-BFvMGeG1TsHwtBXnV3gf9U2-MRAzrESDxoZ1UN3jn9CWRoWWRBPetjZSkyDMUKDDfW1feEtfoM5Q8YP_88skWW1lPA40eFkY9xzbtkvcdVMCx7NCk2xB7W0Il_s',
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
                  isGroupChat: true,
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sacred Rhythm',
            style: AppTypography.headline.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00342B),
            ),
          ),
          Text(
            'COMMUNITY CIRCLE',
            style: AppTypography.label.copyWith(
              color: AppColors.secondary,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCoPf0_OVJGtQL1VLBHj_BWlUEvtc_2YxY7Wal2UFlivzaUlP46_E-gMUmYsw3746_IxdvtloEeJc3Xe-RIsfTq3RIanl1nKNsyqy8YNFj5bzOj4yCGqYaYsX_2UfIwqCRFJiLOeBPEXKcuuvR-BFvMGeG1TsHwtBXnV3gf9U2-MRAzrESDxoZ1UN3jn9CWRoWWRBPetjZSkyDMUKDDfW1feEtfoM5Q8YP_88skWW1lPA40eFkY9xzbtkvcdVMCx7NCk2xB7W0Il_s'),
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
            top: BorderSide(color: AppColors.outlineVariant.withValues(alpha:0.2))),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha:0.2)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppColors.outline),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.image, color: AppColors.outline),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _msgController,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Share your reflections...',
                  hintStyle: AppTypography.body
                      .copyWith(color: AppColors.outline, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                style: AppTypography.body.copyWith(fontSize: 14),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha:0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
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
