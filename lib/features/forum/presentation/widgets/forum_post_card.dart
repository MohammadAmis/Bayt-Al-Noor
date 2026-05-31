import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/post_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ForumPostCard extends StatelessWidget {
  final PostEntity post;
  final VoidCallback? onUpvote;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final VoidCallback? onDownvote;
  final bool interactive;

  const ForumPostCard({
    super.key,
    required this.post,
    this.onUpvote,
    this.onDownvote,
    this.onComment,
    this.onShare,
    this.onBookmark,
    this.interactive = true,
  });

  String _getTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays >= 365) return '${(duration.inDays / 365).floor()}y';
    if (duration.inDays >= 30) return '${(duration.inDays / 30).floor()}mo';
    if (duration.inDays >= 1) return '${duration.inDays}d';
    if (duration.inHours >= 1) return '${duration.inHours}h';
    if (duration.inMinutes >= 1) return '${duration.inMinutes}m';
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppShapes.xlRadius,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: interactive ? () => context.pushNamed(
          'forum_detail',
          extra: post,
        ) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _buildAvatar(context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () => post.isCommunityPost
                                    ? context.pushNamed(
                                        'community_profile',
                                        pathParameters: {
                                          'communityId':
                                              post.communityId.isEmpty
                                                  ? 'bayt-al-noor'
                                                  : post.communityId
                                        },
                                        queryParameters: {
                                          'name': post.communityName
                                        },
                                      )
                                    : context.pushNamed(
                                        'user_profile',
                                        queryParameters: {
                                          'name': post.authorName,
                                          'avatar': post.authorAvatarUrl ?? '',
                                          'bio':
                                              'Seeking tranquility through reflection and prayer.',
                                        },
                                      ),
                                child: Text(
                                  post.isCommunityPost
                                      ? post.communityName
                                      : 'u/${post.authorName}',
                                  style: AppTypography.title.copyWith(
                                    color: AppColors.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (post.authorBadge != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.sand.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color:
                                        AppColors.sand.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  post.authorBadge!.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.sand,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                            if (post.type == PostType.announcement) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.campaign_rounded,
                                  size: 14, color: AppColors.mutedGold),
                            ],
                            if (post.isPinned) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.push_pin_rounded,
                                  size: 14, color: AppColors.sage),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            if (post.isCommunityPost) ...[
                              Text(
                                'u/${post.authorName}',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.onSurfaceVariant
                                      .withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text('•',
                                    style: TextStyle(color: AppColors.outline)),
                              ),
                            ],
                            Text(
                              _getTimeAgo(post.createdAt),
                              style: AppTypography.label.copyWith(
                                color: AppColors.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO:Need to implement edit and delete options for post
                    },
                    icon: Icon(
                      Icons.more_horiz,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.type == PostType.question) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'QUESTION',
                        style: AppTypography.label.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  if (post.type == PostType.announcement) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.mutedGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: AppColors.mutedGold.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'ANNOUNCEMENT',
                        style: AppTypography.label.copyWith(
                          color: AppColors.mutedGold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  Text(
                    post.title,
                    style: AppTypography.display.copyWith(
                      fontSize: 22,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (post.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: post.tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.grayGreen
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tag,
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.grayGreen,
                                    fontSize: 12,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  if (post.body.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      post.body,
                      style: AppTypography.body.copyWith(
                        color:
                            AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Media / Poll
            if (post.hasMedia)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: post.hasVideo
                          ? (post.videoThumbnailUrl ??
                              (post.mediaUrls.isNotEmpty
                                  ? post.mediaUrls.first
                                  : ''))
                          : post.mediaUrls.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    if (post.hasVideo)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 32),
                        ),
                      ),
                  ],
                ),
              ),

            if (post.type == PostType.poll && post.pollOptions != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildPoll(post.pollOptions!),
              ),

            // Footer / Engagement
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Divider(
                      color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Row(
                            children: [
                              _ActionButton(
                                icon: post.isUserUpvoted
                                    ? Icons.thumb_up_rounded
                                    : Icons.thumb_up_outlined,
                                color: post.isUserUpvoted
                                    ? AppColors.mutedGold
                                    : AppColors.onSurfaceVariant
                                        .withValues(alpha: 0.6),
                                isActive: post.isUserUpvoted,
                                onPressed: onUpvote,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  _formatCount(post.score),
                                  style: AppTypography.label.copyWith(
                                    color: post.isUserUpvoted
                                        ? AppColors.mutedGold
                                        : post.isUserDownvoted
                                            ? Colors.redAccent
                                            : AppColors.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _ActionButton(
                                icon: post.isUserDownvoted
                                    ? Icons.thumb_down_rounded
                                    : Icons.thumb_down_outlined,
                                color: post.isUserDownvoted
                                    ? Colors.redAccent
                                    : AppColors.onSurfaceVariant
                                        .withValues(alpha: 0.6),
                                isActive: post.isUserDownvoted,
                                onPressed: onDownvote,
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          _EngagementButton(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: post.commentCount.toString(),
                            onPressed: onComment,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: onShare,
                            icon: Icon(Icons.share_outlined,
                                size: 20,
                                color: AppColors.onSurfaceVariant
                                    .withValues(alpha: 0.6)),
                          ),
                          IconButton(
                            onPressed: onBookmark,
                            icon: Icon(
                              post.isUserBookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              size: 20,
                              color: post.isUserBookmarked
                                  ? AppColors.mutedGold
                                  : AppColors.onSurfaceVariant
                                      .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final bool hasCommunityIcon =
        post.isCommunityPost && post.communityAvatarUrl != null;
    final String avatarUrl = hasCommunityIcon
        ? post.communityAvatarUrl!
        : (post.authorAvatarUrl ?? '');

    return GestureDetector(
      onTap: interactive ? () => post.isCommunityPost
          ? context.pushNamed(
              'community_profile',
              pathParameters: {
                'communityId':
                    post.communityId.isEmpty ? 'bayt-al-noor' : post.communityId
              },
              queryParameters: {'name': post.communityName},
            )
          : context.pushNamed(
              'user_profile',
              queryParameters: {
                'name': post.authorName,
                'avatar': post.authorAvatarUrl ?? '',
              },
            ) : null,
      child: Stack(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.mutedGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(hasCommunityIcon ? 12 : 22),
              border: Border.all(
                color: AppColors.mutedGold.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(hasCommunityIcon ? 12 : 22),
              child: avatarUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: avatarUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (context, url, error) => Icon(
                          hasCommunityIcon ? Icons.group : Icons.person,
                          size: 24),
                    )
                  : Icon(hasCommunityIcon ? Icons.group : Icons.person,
                      size: 24),
            ),
          ),
          if (hasCommunityIcon && post.authorAvatarUrl != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: post.authorAvatarUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPoll(List<PollOption> options) {
    int totalVotes = options.fold(0, (sum, item) => sum + item.votes);

    return Column(
      children: options.map((option) {
        double percent = option.getPercentage(totalVotes) / 100;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 48,
          child: Stack(
            children: [
              // Progress Bar Background
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppShapes.mdRadius,
                  border: Border.all(
                    color: option.isSelectedByUser
                        ? AppColors.mutedGold.withValues(alpha: 0.3)
                        : AppColors.outlineVariant.withValues(alpha: 0.1),
                  ),
                ),
              ),
              // Progress Fill
              FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.mutedGold
                        .withValues(alpha: option.isSelectedByUser ? 0.3 : 0.1),
                    borderRadius: AppShapes.mdRadius,
                  ),
                ),
              ),
              // Content
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
                          const Icon(Icons.check_circle,
                              size: 16, color: AppColors.sage),
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
        );
      }).toList(),
    );
  }

  String _formatCount(int count) {
    if (count.abs() >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.isActive = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

class _EngagementButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _EngagementButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
