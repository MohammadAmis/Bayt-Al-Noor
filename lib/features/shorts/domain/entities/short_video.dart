import 'package:equatable/equatable.dart';

class ShortVideo extends Equatable {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String caption;
  final String authorName;
  final String authorAvatarUrl;
  final String reference; // e.g., "Quran 57:4"
  final String category; // e.g., "Daily Ayat"
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final int bookmarksCount;
  final bool isLiked;
  final bool isBookmarked;
  final DateTime createdAt;

  const ShortVideo({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.caption,
    required this.authorName,
    required this.authorAvatarUrl,
    this.reference = '',
    this.category = 'Reminder',
    this.tags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.bookmarksCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    required this.createdAt,
  });

  ShortVideo copyWith({
    String? id,
    String? videoUrl,
    String? thumbnailUrl,
    String? caption,
    String? authorName,
    String? authorAvatarUrl,
    String? reference,
    String? category,
    List<String>? tags,
    int? likesCount,
    int? commentsCount,
    int? bookmarksCount,
    bool? isLiked,
    bool? isBookmarked,
    DateTime? createdAt,
  }) {
    return ShortVideo(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      reference: reference ?? this.reference,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        videoUrl,
        thumbnailUrl,
        caption,
        authorName,
        authorAvatarUrl,
        reference,
        category,
        tags,
        likesCount,
        commentsCount,
        bookmarksCount,
        isLiked,
        isBookmarked,
        createdAt,
      ];
}
