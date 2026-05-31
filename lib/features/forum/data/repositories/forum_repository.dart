import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForumRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetches all posts with community and author info.
  Future<List<PostEntity>> fetchPosts() async {
    try {
      final response = await _client
          .from('forum_posts')
          .select('''
            *,
            communities:forum_communities(*)
          ''')
          .order('created_at', ascending: false);

      return (response as List).map((json) => _mapJsonToPost(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetches all available communities.
  Future<List<Map<String, dynamic>>> fetchCommunities() async {
    try {
      final response = await _client.from('forum_communities').select('*').order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [
        {'id': 'bayt-al-noor', 'name': 'Bayt-Al-Noor', 'avatar_url': null},
        {'id': 'quran-study', 'name': 'Quran Study', 'avatar_url': null},
        {'id': 'personal', 'name': 'Personal', 'avatar_url': null},
      ];
    }
  }

  /// Creates a new post in Supabase.
  Future<void> createPost(PostEntity post) async {
    final json = {
      'id': post.id,
      'author_id': post.authorId,
      'author_name': post.authorName,
      'author_avatar_url': post.authorAvatarUrl,
      'community_id': post.communityId,
      'title': post.title,
      'body': post.body,
      'link_url': post.linkUrl,
      'media_urls': post.mediaUrls,
      'video_url': post.videoUrl,
      'video_thumbnail_url': post.videoThumbnailUrl,
      'type': post.type.name,
      'tags': post.tags,
      'upvotes': post.upvotes,
      'downvotes': post.downvotes,
      'comment_count': post.commentCount,
      'is_pinned': post.isPinned,
      'is_locked': post.isLocked,
      'poll_options': post.pollOptions?.map((o) => {
        'id': o.id,
        'label': o.label,
        'votes': o.votes,
      }).toList(),
      'poll_ends_at': post.pollEndsAt?.toIso8601String(),
      'created_at': post.createdAt.toIso8601String(),
    };

    await _client.from('forum_posts').insert(json);
  }

  /// Adds a comment to a post.
  Future<void> addComment(CommentEntity comment) async {
    final json = {
      'id': comment.id,
      'post_id': comment.postId,
      'parent_id': comment.parentId,
      'author_id': comment.authorId,
      'author_name': comment.authorName,
      'author_avatar_url': comment.authorAvatarUrl,
      'body': comment.body,
      'upvotes': comment.upvotes,
      'created_at': comment.createdAt.toIso8601String(),
    };

    await _client.from('forum_comments').insert(json);
    
    // Increment comment count on the post
    await _client.rpc('increment_comment_count', params: {'post_id_param': comment.postId});
  }

  /// Handles voting (upvote/downvote).
  Future<void> vote(String userId, String targetId, int voteType) async {
    await _client.from('forum_votes').upsert({
      'user_id': userId,
      'target_id': targetId,
      'vote_type': voteType,
    });
  }

  PostEntity _mapJsonToPost(Map<String, dynamic> json) {
    final community = json['communities'];
    return PostEntity(
      id: json['id'],
      authorId: json['author_id'],
      authorName: json['author_name'],
      authorAvatarUrl: json['author_avatar_url'],
      communityId: json['community_id'],
      communityName: community != null ? community['name'] : 'Personal',
      communityAvatarUrl: community != null ? community['avatar_url'] : null,
      title: json['title'],
      body: json['body'] ?? '',
      linkUrl: json['link_url'],
      mediaUrls: List<String>.from(json['media_urls'] ?? []),
      videoUrl: json['video_url'],
      videoThumbnailUrl: json['video_thumbnail_url'],
      type: PostType.values.firstWhere((e) => e.name == json['type'], orElse: () => PostType.hybrid),
      createdAt: DateTime.parse(json['created_at']),
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isPinned: json['is_pinned'] ?? false,
      isLocked: json['is_locked'] ?? false,
      isUserBookmarked: json['is_user_bookmarked'] ?? false,
      pollOptions: (json['poll_options'] as List?)?.map((o) => PollOption(
        id: o['id'],
        label: o['label'],
        votes: o['votes'] ?? 0,
      )).toList(),
      pollEndsAt: json['poll_ends_at'] != null ? DateTime.parse(json['poll_ends_at']) : null,
    );
  }
}

final forumRepositoryProvider = Provider((ref) => ForumRepository());
