import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../repositories/forum_repository.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../../core/providers/services_provider.dart';
import '../repositories/forum_draft_repository.dart';

final draftRepositoryProvider = Provider<ForumDraftRepository>((ref) {
  return ForumDraftRepository();
});

class CreatePostRequest {
  final String title;
  final String body;
  final PostType type;
  final String communityId;
  final String communityName;
  final List<String> mediaUrls;
  final String? videoUrl;
  final String? videoThumbnailUrl;
  final String? linkUrl;
  final List<String> tags;
  final List<PollOption>? pollOptions;
  final DateTime? pollEndsAt;
  final String? idempotencyKey;

  CreatePostRequest({
    required this.title,
    required this.body,
    required this.type,
    required this.communityId,
    required this.communityName,
    this.mediaUrls = const [],
    this.videoUrl,
    this.videoThumbnailUrl,
    this.linkUrl,
    this.tags = const [],
    this.pollOptions,
    this.pollEndsAt,
    this.idempotencyKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type.name,
      'communityId': communityId,
      'communityName': communityName,
      'mediaUrls': mediaUrls,
      'videoUrl': videoUrl,
      'videoThumbnailUrl': videoThumbnailUrl,
      'linkUrl': linkUrl,
      'tags': tags,
      'pollOptions': pollOptions?.map((x) => x.toMap()).toList(),
      'pollEndsAt': pollEndsAt?.toIso8601String(),
      'idempotencyKey': idempotencyKey,
    };
  }

  factory CreatePostRequest.fromMap(Map<String, dynamic> map) {
    return CreatePostRequest(
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: PostType.values.byName(map['type'] ?? 'hybrid'),
      communityId: map['communityId'] ?? '',
      communityName: map['communityName'] ?? '',
      mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
      videoUrl: map['videoUrl'],
      videoThumbnailUrl: map['videoThumbnailUrl'],
      linkUrl: map['linkUrl'],
      tags: List<String>.from(map['tags'] ?? []),
      pollOptions: map['pollOptions'] != null
          ? List<PollOption>.from(map['pollOptions']?.map((x) => PollOption.fromMap(x)))
          : null,
      pollEndsAt: map['pollEndsAt'] != null ? DateTime.parse(map['pollEndsAt']) : null,
      idempotencyKey: map['idempotencyKey'],
    );
  }
}

class LinkPreview {
  final String title;
  final String description;
  final String imageUrl;
  final String url;

  LinkPreview({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.url,
  });

  factory LinkPreview.fallback(String url) => LinkPreview(
    title: 'External Link',
    description: 'Click to visit $url',
    imageUrl: 'https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=200',
    url: url,
  );
}

final linkPreviewProvider = Provider((ref) => LinkPreviewService());

class LinkPreviewService {
  Future<LinkPreview> fetch(String url) async {
    // In a real app, you'd use a package like 'metadata_fetch' or a backend endpoint.
    // Mocking it for now.
    await Future.delayed(const Duration(milliseconds: 800));
    if (url.isEmpty || !url.startsWith('http')) {
      return LinkPreview(
        title: 'Preview Unavailable',
        description: 'No metadata found for this link.',
        imageUrl: 'https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=800',
        url: url,
      );
    }
    return LinkPreview(
      title: 'Link Preview',
      description: 'Shared via Bayt-Al-Noor',
      imageUrl: 'https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=800',
      url: url,
    );
  }
}

class ForumPostsNotifier extends AsyncNotifier<List<PostEntity>> {
  @override
  FutureOr<List<PostEntity>> build() async {
    return ref.read(forumRepositoryProvider).fetchPosts();
  }

  Future<void> addPost(CreatePostRequest request) async {
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('User must be logged in to post');

    final post = PostEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: user.id,
      authorName: user.userMetadata?['full_name'] ?? 'User',
      authorAvatarUrl: user.userMetadata?['avatar_url'] ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      communityId: request.communityId,
      communityName: request.communityName,
      title: request.title,
      body: request.body,
      type: request.type,
      mediaUrls: request.mediaUrls,
      videoUrl: request.videoUrl,
      videoThumbnailUrl: request.videoThumbnailUrl,
      linkUrl: request.linkUrl,
      tags: request.tags,
      pollOptions: request.pollOptions,
      pollEndsAt: request.pollEndsAt,
      createdAt: DateTime.now(),
      upvotes: 1,
      isUserUpvoted: true,
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(forumRepositoryProvider).createPost(post);
      return ref.read(forumRepositoryProvider).fetchPosts();
    });
  }

  Future<void> toggleUpvote(String postId) async {
    final userId = sb.Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final currentPosts = state.value ?? [];
    
    state = AsyncValue.data([
      for (final p in currentPosts)
        if (p.id == postId)
          p.copyWith(
            isUserUpvoted: !p.isUserUpvoted,
            upvotes: p.isUserUpvoted ? p.upvotes - 1 : p.upvotes + 1,
            isUserDownvoted: false,
            downvotes: p.isUserDownvoted ? p.downvotes - 1 : p.downvotes,
          )
        else
          p,
    ]);

    await ref.read(forumRepositoryProvider).vote(userId, postId, state.value!.firstWhere((p) => p.id == postId).isUserUpvoted ? 1 : 0);
  }

  Future<void> toggleDownvote(String postId) async {
    final userId = sb.Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final currentPosts = state.value ?? [];
    
    state = AsyncValue.data([
      for (final p in currentPosts)
        if (p.id == postId)
          p.copyWith(
            isUserDownvoted: !p.isUserDownvoted,
            downvotes: p.isUserDownvoted ? p.downvotes - 1 : p.downvotes + 1,
            isUserUpvoted: false,
            upvotes: p.isUserUpvoted ? p.upvotes - 1 : p.upvotes,
          )
        else
          p,
    ]);

    await ref.read(forumRepositoryProvider).vote(userId, postId, state.value!.firstWhere((p) => p.id == postId).isUserDownvoted ? -1 : 0);
  }

  Future<void> toggleBookmark(String postId) async {
    final currentPosts = state.value ?? [];
    state = AsyncValue.data([
      for (final post in currentPosts)
        if (post.id == postId)
          post.copyWith(isUserBookmarked: !post.isUserBookmarked)
        else
          post,
    ]);
  }

  Future<void> addComment(String postId, String body) async {
    final userId = sb.Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final now = DateTime.now();
    final comment = CommentEntity(
      id: 'c_${now.millisecondsSinceEpoch}',
      postId: postId,
      authorId: userId,
      authorName: 'User',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      body: body,
      createdAt: now,
    );

    await ref.read(forumRepositoryProvider).addComment(comment);
    
    state = await AsyncValue.guard(() => ref.read(forumRepositoryProvider).fetchPosts());
  }

  Future<void> toggleCommentUpvote(String postId, String commentId) async {
    final currentPosts = state.value ?? [];
    state = AsyncValue.data([
      for (final post in currentPosts)
        if (post.id == postId)
          post.copyWith(
            comments: _updateCommentUpvote(post.comments, commentId),
          )
        else
          post,
    ]);
  }

  List<CommentEntity> _updateCommentUpvote(
      List<CommentEntity> comments, String targetId) {
    return [
      for (final comment in comments)
        if (comment.id == targetId)
          comment.copyWith(
            isUserUpvoted: !comment.isUserUpvoted,
            upvotes: comment.isUserUpvoted
                ? comment.upvotes - 1
                : comment.upvotes + 1,
          )
        else
          comment.copyWith(
              replies: _updateCommentUpvote(comment.replies, targetId)),
    ];
  }

  Future<void> addReply(String postId, String parentCommentId, String body) async {
    final userId = sb.Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final now = DateTime.now();
    final reply = CommentEntity(
      id: 'r_${now.millisecondsSinceEpoch}',
      postId: postId,
      parentId: parentCommentId,
      authorId: userId,
      authorName: 'User',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      body: body,
      createdAt: now,
    );

    await ref.read(forumRepositoryProvider).addComment(reply);
    
    state = await AsyncValue.guard(() => ref.read(forumRepositoryProvider).fetchPosts());
  }

  Future<void> votePoll(String postId, String optionId) async {
    final userId = sb.Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final currentPosts = state.value ?? [];
    state = AsyncValue.data([
      for (final post in currentPosts)
        if (post.id == postId && post.pollOptions != null)
          post.copyWith(
            pollOptions: [
              for (final option in post.pollOptions!)
                if (option.id == optionId)
                  PollOption(
                    id: option.id,
                    label: option.label,
                    votes: option.isSelectedByUser
                        ? option.votes - 1
                        : option.votes + 1,
                    isSelectedByUser: !option.isSelectedByUser,
                  )
                else if (option.isSelectedByUser)
                  // Deselect previous selection if a new one is clicked
                  PollOption(
                    id: option.id,
                    label: option.label,
                    votes: option.votes - 1,
                    isSelectedByUser: false,
                  )
                else
                  option,
            ],
          )
        else
          post,
    ]);
  }
}

final forumPostsProvider =
    AsyncNotifierProvider<ForumPostsNotifier, List<PostEntity>>(
        ForumPostsNotifier.new);

class JoinedCommunitiesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {'bayt-al-noor', 'quran-study'};
  }

  void toggleJoin(String communityId) {
    if (state.contains(communityId)) {
      state = {...state}..remove(communityId);
    } else {
      state = {...state}..add(communityId);
    }
  }
}

final joinedCommunitiesProvider =
    NotifierProvider<JoinedCommunitiesNotifier, Set<String>>(
        JoinedCommunitiesNotifier.new);

/// ✅ Dynamic Community Provider
final communitiesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(forumRepositoryProvider).fetchCommunities();
});

/// ✅ User Activity Provider for Rate Limiting
class UserActivityNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<DateTime?> getLastPostTime(String userId) async {
    try {
      final response = await sb.Supabase.instance.client
          .from('forum_posts')
          .select('created_at')
          .eq('author_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      
      if (response != null && response['created_at'] != null) {
        return DateTime.parse(response['created_at']);
      }
    } catch (e) {
      debugPrint('Error fetching last post time: $e');
    }
    return null;
  }
}

final userActivityProvider = NotifierProvider<UserActivityNotifier, void>(UserActivityNotifier.new);
