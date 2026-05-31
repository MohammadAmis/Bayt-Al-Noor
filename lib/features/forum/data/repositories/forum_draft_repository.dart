import 'package:hive_flutter/hive_flutter.dart';

class ForumDraft {
  final String title;
  final String body;
  final String communityId;
  final String communityName;
  final List<String> mediaUrls;
  final String? linkUrl;
  final String? videoUrl;
  final String? videoThumbnailUrl;
  final bool isPollEnabled;
  final List<String>? pollOptions;
  final int? pollDurationDays;

  ForumDraft({
    required this.title,
    required this.body,
    required this.communityId,
    required this.communityName,
    this.mediaUrls = const [],
    this.linkUrl,
    this.videoUrl,
    this.videoThumbnailUrl,
    this.isPollEnabled = false,
    this.pollOptions,
    this.pollDurationDays,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'communityId': communityId,
    'communityName': communityName,
    'mediaUrls': mediaUrls,
    'linkUrl': linkUrl,
    'videoUrl': videoUrl,
    'videoThumbnailUrl': videoThumbnailUrl,
    'isPollEnabled': isPollEnabled,
    'pollOptions': pollOptions,
    'pollDurationDays': pollDurationDays,
  };

  factory ForumDraft.fromJson(Map<String, dynamic> json) => ForumDraft(
    title: json['title'] ?? '',
    body: json['body'] ?? '',
    communityId: json['communityId'] ?? 'bayt-al-noor',
    communityName: json['communityName'] ?? 'Bayt-Al-Noor',
    mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
    linkUrl: json['linkUrl'],
    videoUrl: json['videoUrl'],
    videoThumbnailUrl: json['videoThumbnailUrl'],
    isPollEnabled: json['isPollEnabled'] ?? false,
    pollOptions: json['pollOptions'] != null ? List<String>.from(json['pollOptions']) : null,
    pollDurationDays: json['pollDurationDays'],
  );
}

class ForumDraftRepository {
  static const String _boxName = 'forum_drafts';

  Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  Future<void> saveDraft(String userId, ForumDraft draft) async {
    final box = Hive.box(_boxName);
    await box.put(userId, draft.toJson());
  }

  Future<ForumDraft?> loadDraft(String userId) async {
    final box = Hive.box(_boxName);
    final data = box.get(userId);
    if (data == null) return null;
    return ForumDraft.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> clearDraft(String userId) async {
    final box = Hive.box(_boxName);
    await box.delete(userId);
  }
}
