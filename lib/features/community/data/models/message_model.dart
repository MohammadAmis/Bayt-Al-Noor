enum MessageType { text, image, file }

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final String? attachmentUrl;
  final FileMetadata? fileMetadata;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.content,
    required this.timestamp,
    required this.type,
    this.attachmentUrl,
    this.fileMetadata,
  });

  bool get isMe => senderId == 'me';
}

class FileMetadata {
  final String name;
  final String size;
  final String extension;

  FileMetadata({
    required this.name,
    required this.size,
    required this.extension,
  });
}
