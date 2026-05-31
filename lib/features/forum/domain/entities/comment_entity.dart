// lib/features/forum/domain/entities/comment_entity.dart

class CommentEntity {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final String? authorBadge;
  final String body;
  final DateTime createdAt;
  final int upvotes;
  final bool isUserUpvoted;
  final String? parentId;
  final List<CommentEntity> replies;

  CommentEntity({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorAvatarUrl,
    this.authorBadge,
    required this.body,
    required this.createdAt,
    this.upvotes = 0,
    this.isUserUpvoted = false,
    this.parentId,
    this.replies = const [],
  });

  CommentEntity copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? authorName,
    String? authorAvatarUrl,
    String? authorBadge,
    String? body,
    DateTime? createdAt,
    int? upvotes,
    bool? isUserUpvoted,
    String? parentId,
    List<CommentEntity>? replies,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      authorBadge: authorBadge ?? this.authorBadge,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      upvotes: upvotes ?? this.upvotes,
      isUserUpvoted: isUserUpvoted ?? this.isUserUpvoted,
      parentId: parentId ?? this.parentId,
      replies: replies ?? this.replies,
    );
  }
}
