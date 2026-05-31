import 'comment_entity.dart';

enum PostType { hybrid, poll, announcement, question }

class PostEntity {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String? authorBadge; // e.g., "Scholar", "Verified"
  
  final String communityId;
  final String communityName;
  final String? communityAvatarUrl;
  
  final String title;
  final String body; // Renamed from content for clarity
  final String? linkUrl; // For link posts
  final List<String> mediaUrls; // Supports single or gallery
  final String? videoUrl; // For video posts
  final String? videoThumbnailUrl; // For video preview
  final List<String> tags; // Flairs/categories
  
  final PostType type;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  final int upvotes;
  final int downvotes;
  final int commentCount;
  
  final bool isPinned;
  final bool isLocked;
  final bool isSpoiler;
  final bool isEdited;
  final bool isCommunityAnnouncement;
  
  // Poll data (only if type == poll)
  final List<PollOption>? pollOptions;
  final DateTime? pollEndsAt;
  final bool allowMultiplePollVotes;
  
  // Client-side state
  final bool isUserUpvoted;
  final bool isUserDownvoted;
  final bool isUserBookmarked;
  final List<CommentEntity> comments;

  bool get hasMedia => mediaUrls.isNotEmpty || hasVideo;
  bool get hasVideo => videoUrl != null;

  PostEntity({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    this.authorBadge,
    required this.communityId,
    required this.communityName,
    this.communityAvatarUrl,
    required this.title,
    this.body = '',
    this.linkUrl,
    this.mediaUrls = const [],
    this.videoUrl,
    this.videoThumbnailUrl,
    this.tags = const [],
    required this.type,
    required this.createdAt,
    this.updatedAt,
    this.upvotes = 0,
    this.downvotes = 0,
    this.commentCount = 0,
    this.isPinned = false,
    this.isLocked = false,
    this.isSpoiler = false,
    this.isEdited = false,
    this.isCommunityAnnouncement = false,
    this.pollOptions,
    this.pollEndsAt,
    this.allowMultiplePollVotes = false,
    this.isUserUpvoted = false,
    this.isUserDownvoted = false,
    this.isUserBookmarked = false,
    this.comments = const [],
  });

  int get score => upvotes - downvotes;
  bool get isCommunityPost => communityId != 'personal';

  PostEntity copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatarUrl,
    String? authorBadge,
    String? communityId,
    String? communityName,
    String? communityAvatarUrl,
    String? title,
    String? body,
    String? linkUrl,
    List<String>? mediaUrls,
    String? videoUrl,
    String? videoThumbnailUrl,
    List<String>? tags,
    PostType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? upvotes,
    int? downvotes,
    int? commentCount,
    bool? isPinned,
    bool? isLocked,
    bool? isSpoiler,
    bool? isEdited,
    bool? isCommunityAnnouncement,
    List<PollOption>? pollOptions,
    DateTime? pollEndsAt,
    bool? allowMultiplePollVotes,
    bool? isUserUpvoted,
    bool? isUserDownvoted,
    bool? isUserBookmarked,
    List<CommentEntity>? comments,
  }) {
    return PostEntity(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      authorBadge: authorBadge ?? this.authorBadge,
      communityId: communityId ?? this.communityId,
      communityName: communityName ?? this.communityName,
      communityAvatarUrl: communityAvatarUrl ?? this.communityAvatarUrl,
      title: title ?? this.title,
      body: body ?? this.body,
      linkUrl: linkUrl ?? this.linkUrl,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      videoThumbnailUrl: videoThumbnailUrl ?? this.videoThumbnailUrl,
      tags: tags ?? this.tags,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      commentCount: commentCount ?? this.commentCount,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      isSpoiler: isSpoiler ?? this.isSpoiler,
      isEdited: isEdited ?? this.isEdited,
      isCommunityAnnouncement: isCommunityAnnouncement ?? this.isCommunityAnnouncement,
      pollOptions: pollOptions ?? this.pollOptions,
      pollEndsAt: pollEndsAt ?? this.pollEndsAt,
      allowMultiplePollVotes: allowMultiplePollVotes ?? this.allowMultiplePollVotes,
      isUserUpvoted: isUserUpvoted ?? this.isUserUpvoted,
      isUserDownvoted: isUserDownvoted ?? this.isUserDownvoted,
      isUserBookmarked: isUserBookmarked ?? this.isUserBookmarked,
      comments: comments ?? this.comments,
    );
  }
}

class PollOption {
  final String id;
  final String label;
  final int votes;
  final bool isSelectedByUser;

  PollOption({
    required this.id,
    required this.label,
    this.votes = 0,
    this.isSelectedByUser = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'votes': votes,
      'isSelectedByUser': isSelectedByUser,
    };
  }

  factory PollOption.fromMap(Map<String, dynamic> map) {
    return PollOption(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      votes: map['votes'] ?? 0,
      isSelectedByUser: map['isSelectedByUser'] ?? false,
    );
  }

  double getPercentage(int totalVotes) {
    if (totalVotes == 0) return 0;
    return (votes / totalVotes) * 100;
  }
}