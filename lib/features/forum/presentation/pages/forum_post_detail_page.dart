import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/providers/forum_providers.dart';
import '../widgets/forum_video_player.dart';

class ForumPostDetailPage extends ConsumerStatefulWidget {
  final PostEntity post;

  const ForumPostDetailPage({
    super.key,
    required this.post,
  });

  @override
  ConsumerState<ForumPostDetailPage> createState() => _ForumPostDetailPageState();
}

class _ForumPostDetailPageState extends ConsumerState<ForumPostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  String? _replyToCommentId;
  String? _replyingToName;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _getTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays >= 365) return '${(duration.inDays / 365).floor()}y';
    if (duration.inDays >= 30) return '${(duration.inDays / 30).floor()}mo';
    if (duration.inDays >= 1) return '${duration.inDays}d';
    if (duration.inHours >= 1) return '${duration.inHours}h';
    if (duration.inMinutes >= 1) return '${duration.inMinutes}m';
    return 'now';
  }

  void _submitComment(String postId) {
    if (_commentController.text.trim().isEmpty) return;
    
    if (_replyToCommentId != null) {
      ref.read(forumPostsProvider.notifier).addReply(postId, _replyToCommentId!, _commentController.text.trim());
    } else {
      ref.read(forumPostsProvider.notifier).addComment(postId, _commentController.text.trim());
    }
    
    _commentController.clear();
    setState(() {
      _replyToCommentId = null;
      _replyingToName = null;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(forumPostsProvider);
    final livePost = postsAsync.value?.firstWhere((p) => p.id == widget.post.id, orElse: () => widget.post) ?? widget.post;
    final joinedCommunities = ref.watch(joinedCommunitiesProvider);
    final isJoined = joinedCommunities.contains(livePost.communityId);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        title: livePost.communityName,
        isMainScreen: false,
        location: 'Community',
        showLogo: false,
        actions: [
          if (livePost.isCommunityPost)
            GestureDetector(
              onTap: () => ref.read(joinedCommunitiesProvider.notifier).toggleJoin(livePost.communityId),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isJoined ? AppColors.mutedGold.withValues(alpha: 0.1) : AppColors.mutedGold,
                  borderRadius: AppShapes.fullRadius,
                  border: isJoined ? Border.all(color: AppColors.mutedGold.withValues(alpha: 0.2)) : null,
                ),
                child: Text(
                  isJoined ? 'JOINED' : 'JOIN',
                  style: TextStyle(
                    color: isJoined ? AppColors.mutedGold : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(livePost),
                const SizedBox(height: 20),
                _buildContent(livePost),
                if (livePost.type == PostType.poll && livePost.pollOptions != null) ...[
                  const SizedBox(height: 24),
                  _buildPoll(livePost),
                ],
                if (livePost.hasMedia) ...[
                  const SizedBox(height: 24),
                  _buildMedia(livePost),
                ],
                const SizedBox(height: 24),
                _buildEngagementBar(livePost),
                const SizedBox(height: 32),
                _buildCommentsSection(livePost),
              ],
            ),
          ),
          _buildStickyBottomBar(livePost.id),
        ],
      ),
    );
  }

  Widget _buildHeader(PostEntity post) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.mutedGold.withValues(alpha: 0.1)),
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: post.authorAvatarUrl ?? '',
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.person),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    post.authorName,
                    style: AppTypography.title.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, size: 14, color: AppColors.mutedGold),
                ],
              ),
              Text(
                '${_getTimeAgo(post.createdAt)} • ${post.tags.isNotEmpty ? post.tags.first : 'General'}',
                style: AppTypography.label.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (post.authorBadge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.sand.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              post.authorBadge!.toUpperCase(),
              style: const TextStyle(
                color: AppColors.sand,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(PostEntity post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.title,
          style: AppTypography.display.copyWith(
            fontSize: 24,
            height: 1.3,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          post.body,
          style: AppTypography.body.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.6,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildPoll(PostEntity post) {
    final options = post.pollOptions!;
    int totalVotes = options.fold(0, (sum, item) => sum + item.votes);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppShapes.xlRadius,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Poll',
            style: AppTypography.title.copyWith(fontSize: 16, color: AppColors.onSurface),
          ),
          const SizedBox(height: 16),
          ...options.map((option) {
            double percent = option.getPercentage(totalVotes) / 100;
            return GestureDetector(
              onTap: () => ref.read(forumPostsProvider.notifier).votePoll(post.id, option.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 48,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: AppShapes.mdRadius,
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.mutedGold.withValues(alpha: option.isSelectedByUser ? 0.3 : 0.1),
                          borderRadius: AppShapes.mdRadius,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                option.label,
                                style: AppTypography.title.copyWith(
                                  fontSize: 14,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              if (option.isSelectedByUser) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.check_circle, size: 16, color: AppColors.sage),
                              ],
                            ],
                          ),
                          Text(
                            '${(percent * 100).toInt()}%',
                            style: AppTypography.label.copyWith(
                              color: AppColors.sand,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMedia(PostEntity post) {
    if (post.hasVideo) {
      return ClipRRect(
        borderRadius: AppShapes.xlRadius,
        child: ForumVideoPlayer(
          videoUrl: post.videoUrl!,
          thumbnailUrl: post.videoThumbnailUrl,
        ),
      );
    }
    return ClipRRect(
      borderRadius: AppShapes.xlRadius,
      child: CachedNetworkImage(
        imageUrl: post.mediaUrls.first,
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    );
  }

  Widget _buildEngagementBar(PostEntity post) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildActionButton(
                post.isUserUpvoted ? Icons.thumb_up_rounded : Icons.thumb_up_outlined, 
                post.isUserUpvoted ? AppColors.mutedGold : AppColors.onSurfaceVariant, 
                isActive: post.isUserUpvoted, 
                label: post.score.toString(),
                onTap: () => ref.read(forumPostsProvider.notifier).toggleUpvote(post.id),
              ),
              _buildActionButton(
                post.isUserDownvoted ? Icons.thumb_down_rounded : Icons.thumb_down_outlined, 
                post.isUserDownvoted ? Colors.redAccent : AppColors.onSurfaceVariant, 
                isActive: post.isUserDownvoted,
                onTap: () => ref.read(forumPostsProvider.notifier).toggleDownvote(post.id),
              ),
              const SizedBox(width: 20),
              _buildActionButton(
                Icons.chat_bubble_outline_rounded, 
                AppColors.onSurfaceVariant, 
                label: post.commentCount.toString(),
              ),
            ],
          ),
          Row(
            children: [
              _buildActionButton(
                Icons.share_outlined, 
                AppColors.onSurfaceVariant,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard')),
                  );
                },
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                post.isUserBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, 
                post.isUserBookmarked ? AppColors.mutedGold : AppColors.onSurfaceVariant, 
                isActive: post.isUserBookmarked,
                onTap: () => ref.read(forumPostsProvider.notifier).toggleBookmark(post.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, {bool isActive = false, String? label, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            Icon(icon, size: 22, color: isActive ? color : color.withValues(alpha: 0.6)),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: isActive ? color : AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(PostEntity post) {
    final comments = post.comments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Comments (${post.commentCount})',
              style: AppTypography.title.copyWith(fontSize: 18),
            ),
            Row(
              children: [
                Text(
                  'Sort by: Best',
                  style: AppTypography.label.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const Icon(Icons.expand_more, size: 16, color: AppColors.onSurfaceVariant),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (comments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.onSurfaceVariant.withValues(alpha: 0.2)),
                  const SizedBox(height: 12),
                  Text(
                    'No comments yet. Be the first to share your thoughts!',
                    style: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...comments.map((comment) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _buildCommentItem(comment),
          )),
      ],
    );
  }

  Widget _buildCommentItem(CommentEntity comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16, 
              backgroundImage: CachedNetworkImageProvider(comment.authorAvatarUrl)
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(comment.authorName, style: AppTypography.title.copyWith(fontSize: 14)),
                      if (comment.authorBadge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.mutedGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(comment.authorBadge!.toUpperCase(), style: const TextStyle(color: AppColors.mutedGold, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ],
                      const SizedBox(width: 8),
                      Text('• ${_getTimeAgo(comment.createdAt)}', style: AppTypography.label.copyWith(color: AppColors.onSurfaceVariant, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(comment.body, style: AppTypography.body.copyWith(fontSize: 14, color: AppColors.onSurface.withValues(alpha: 0.8))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => ref.read(forumPostsProvider.notifier).toggleCommentUpvote(comment.postId, comment.id),
                        child: Icon(
                          comment.isUserUpvoted ? Icons.thumb_up_rounded : Icons.thumb_up_outlined, 
                          size: 16, 
                          color: comment.isUserUpvoted ? AppColors.mutedGold : AppColors.onSurfaceVariant
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        comment.upvotes.toString(), 
                        style: AppTypography.label.copyWith(
                          fontSize: 11, 
                          fontWeight: FontWeight.bold,
                          color: comment.isUserUpvoted ? AppColors.mutedGold : AppColors.onSurfaceVariant,
                        )
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _replyToCommentId = comment.id;
                            _replyingToName = comment.authorName;
                          });
                          FocusScope.of(context).requestFocus();
                        },
                        child: Text(
                          'Reply', 
                          style: AppTypography.label.copyWith(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold, 
                            color: _replyToCommentId == comment.id ? AppColors.mutedGold : AppColors.onSurfaceVariant
                          )
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Container(
              decoration: BoxDecoration(border: Border(left: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2), width: 2))),
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: comment.replies.map((reply) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildCommentItem(reply),
                )).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStickyBottomBar(String postId) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.paddingOf(context).bottom + 12),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.95),
          border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyingToName != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.mutedGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.reply_rounded, size: 14, color: AppColors.mutedGold),
                    const SizedBox(width: 8),
                    Text(
                      'Replying to $_replyingToName',
                      style: AppTypography.label.copyWith(color: AppColors.mutedGold, fontSize: 11),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() {
                        _replyToCommentId = null;
                        _replyingToName = null;
                      }),
                      child: const Icon(Icons.close_rounded, size: 14, color: AppColors.mutedGold),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppShapes.fullRadius,
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        onSubmitted: (_) => _submitComment(postId),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    const Icon(Icons.sentiment_satisfied_alt_outlined, size: 20, color: AppColors.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _submitComment(postId),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.mutedGold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mutedGold.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);
  }
}
