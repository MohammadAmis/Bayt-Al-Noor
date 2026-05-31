import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/forum_post_card.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../../core/design_tokens.dart';
import '../../domain/entities/post_entity.dart';
import '../../data/providers/forum_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/providers/services_provider.dart';
import 'dart:async';
import '../../data/repositories/forum_draft_repository.dart';
import '../../../../core/exceptions/network_exception.dart';
import '../../data/providers/offline_queue_provider.dart';


class CreatePostPage extends ConsumerStatefulWidget {
  final String? initialType;

  const CreatePostPage({super.key, this.initialType});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  
  bool _isPreviewMode = false;
  String? _videoUrl;
  String? _videoThumbnailUrl;
  late String _selectedCommunityId;
  late String _selectedCommunityName;
  
  final List<String> _mediaUrls = [];
  bool _isPollEnabled = false;
  final List<String> _pollOptions = ['', ''];
  int _pollDurationDays = 1;
  
  bool _isUploading = false;
  bool _isSubmitting = false;
  final ValueNotifier<int> _titleCharCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _bodyCharCountNotifier = ValueNotifier<int>(0);
  final Map<String, double> _mediaUploadProgress = {};
  
  Timer? _saveTimer;
  Timer? _linkPreviewTimer;
  LinkPreview? _linkPreview;
  String? _dismissedLinkUrl;
  bool _isFetchingPreview = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() {
      _titleCharCountNotifier.value = _titleController.text.length;
    });
    _bodyController.addListener(() {
      _bodyCharCountNotifier.value = _bodyController.text.length;
      _onBodyChanged();
    });
    
    _selectedCommunityId = 'bayt-al-noor';
    _selectedCommunityName = 'Bayt-Al-Noor';

    // Initialize Draft logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDraft();
      _startAutoSave();
    });
  }

  void _onBodyChanged() {
    _linkPreviewTimer?.cancel();
    _linkPreviewTimer = Timer(
      const Duration(milliseconds: 800),
      () {
        final url = _extractFirstUrl(_bodyController.text);
        if (url != null && url != _dismissedLinkUrl) {
          _fetchLinkPreview(url);
        } else {
          setState(() => _linkPreview = null);
        }
      },
    );
  }

  String? _extractFirstUrl(String text) {
    final urlPattern = RegExp(
      r'(https?:\/\/[^\s]+)',
      caseSensitive: false,
    );
    final match = urlPattern.firstMatch(text);
    return match?.group(0);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _linkPreviewTimer?.cancel();
    _titleController.dispose();
    _bodyController.dispose();
    _titleCharCountNotifier.dispose();
    _bodyCharCountNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final draft = await ref.read(draftRepositoryProvider).loadDraft(user.id);
    if (draft != null && mounted) {
      setState(() {
        _titleController.text = draft.title;
        _bodyController.text = draft.body;
        _selectedCommunityId = draft.communityId;
        _selectedCommunityName = draft.communityName;
        _mediaUrls.clear();
        _mediaUrls.addAll(draft.mediaUrls);
        _videoUrl = draft.videoUrl;
        _videoThumbnailUrl = draft.videoThumbnailUrl;
        _isPollEnabled = draft.isPollEnabled;
        if (draft.pollOptions != null) {
          _pollOptions.clear();
          _pollOptions.addAll(draft.pollOptions!);
        }
        _pollDurationDays = draft.pollDurationDays ?? 1;
        if (draft.linkUrl != null && _bodyController.text.isEmpty) {
          _bodyController.text = draft.linkUrl!;
        }
      });
    }
  }

  void _startAutoSave() {
    _saveTimer = Timer.periodic(const Duration(seconds: 30), (_) => _saveDraft());
  }

  Future<void> _saveDraft() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final draft = ForumDraft(
      title: _titleController.text,
      body: _bodyController.text,
      communityId: _selectedCommunityId,
      communityName: _selectedCommunityName,
      mediaUrls: _mediaUrls,
      linkUrl: _extractFirstUrl(_bodyController.text),
      videoUrl: _videoUrl,
      videoThumbnailUrl: _videoThumbnailUrl,
      isPollEnabled: _isPollEnabled,
      pollOptions: _pollOptions,
      pollDurationDays: _pollDurationDays,
    );

    await ref.read(draftRepositoryProvider).saveDraft(user.id, draft);
    debugPrint('Draft saved for user: ${user.id}');
  }

  Future<void> _clearDraft() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await ref.read(draftRepositoryProvider).clearDraft(user.id);
    setState(() {
      _titleController.clear();
      _bodyController.clear();
      _mediaUrls.clear();
      _videoUrl = null;
      _videoThumbnailUrl = null;
      _isPollEnabled = false;
      _linkPreview = null;
      _dismissedLinkUrl = null;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft cleared'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _fetchLinkPreview(String url) async {
    if (url.isEmpty || !url.startsWith('http')) {
      setState(() => _linkPreview = null);
      return;
    }

    setState(() => _isFetchingPreview = true);

    try {
      final preview = await ref.read(linkPreviewProvider).fetch(url);
      setState(() => _linkPreview = preview);
    } catch (e) {
      setState(() => _linkPreview = LinkPreview.fallback(url));
    } finally {
      setState(() => _isFetchingPreview = false);
    }
  }
  Future<bool> _isPrayerTime() async {
    try {
      final prayerService = ref.read(prayerServiceProvider);
      final pos = await prayerService.getCurrentPosition();
      if (pos == null) return false;
      
      final times = await prayerService.getPrayerTimes(latitude: pos.latitude, longitude: pos.longitude);
      final now = DateTime.now();
      
      // Check if current time is within 15 minutes of any prayer time
      final prayers = [times.fajr, times.dhuhr, times.asr, times.maghrib, times.isha];
      for (final p in prayers) {
        if (now.isAfter(p.subtract(const Duration(minutes: 15))) && now.isBefore(p.add(const Duration(minutes: 15)))) {
          return true;
        }
      }
    } catch (e) {
      debugPrint('Prayer check error: $e');
    }
    return false;
  }

  void _showAdabReminder({required String message, required VoidCallback onPostAnyway}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Text('Adab Reminder', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Edit Post', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onPostAnyway();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Post Anyway'),
          ),
        ],
      ),
    );
  }

  void _showPrayerTimeNotice({required VoidCallback onPostNow}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.mosque_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Text('Prayer Time', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'It is currently close to prayer time. Would you like to pause and resume after prayer?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveDraft();
              context.pop();
            },
            child: const Text('Pause & Save Draft', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onPostNow();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Post Now'),
          ),
        ],
      ),
    );
  }

  bool _containsReligiousRulingContext() {
    final text = '${_titleController.text} ${_bodyController.text}'.toLowerCase();
    
    // Require context words near keywords to reduce false positives
    final patterns = [
      RegExp(r'\b(fatwa|ruling|permissible|halal|haram)\b.*\b(is|are|can|should|according to|in islam)\b'),
      RegExp(r'\b(haram|forbidden)\b.*\b(in islam|according to|dalil|sharia)\b'),
      RegExp(r'\b(question|ask|ruling)\b.*\b(about|on|regarding)\b'),
    ];
    
    return patterns.any((p) => p.hasMatch(text));
  }

  List<String> _validateForm() {
    final errors = <String>[];
    if (_titleController.text.trim().length < 5) {
      errors.add('Title must be at least 5 characters');
    }
    if (_titleController.text.length > 300) {
      errors.add('Title exceeds 300 characters');
    }
    if (_titleController.text.isEmpty && _bodyController.text.isEmpty && _mediaUrls.isEmpty && _extractFirstUrl(_bodyController.text) == null) {
      errors.add('Add some content to share your reflection');
    }
    return errors;
  }

  Future<bool> _canPostNow() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    final lastPostTime = await ref.read(userActivityProvider.notifier).getLastPostTime(user.id);
    if (lastPostTime != null) {
      final timeSince = DateTime.now().difference(lastPostTime);
      // Relaxed to 5 seconds to prevent double-taps but avoid blocking genuine first posts or clock sync issues
      if (timeSince.inSeconds >= 0 && timeSince.inSeconds < 5) {
        return false;
      }
    }
    return true;
  }

  Future<void> _submitPost() async {
    final errors = _validateForm();
    final messenger = ScaffoldMessenger.of(context);
    if (errors.isNotEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(errors.first), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    if (!await _canPostNow()) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please wait 1 minute between posts'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    // Islamic Safeguards
    if (_containsReligiousRulingContext()) {
      _showAdabReminder(
        message: 'Discussing religious rulings? Consider adding scholarly references (Dalil) to help the community.',
        onPostAnyway: _continueSubmission,
      );
      return;
    }

    if (await _isPrayerTime()) {
      _showPrayerTimeNotice(onPostNow: _continueSubmission);
      return;
    }

    await _continueSubmission();
  }

  Future<void> _continueSubmission() async {
    setState(() => _isSubmitting = true);

    try {
      final idempotencyKey = UniqueKey().toString();
      
      final request = CreatePostRequest(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        type: _isPollEnabled ? PostType.poll : PostType.hybrid,
        communityId: _selectedCommunityId,
        communityName: _selectedCommunityName,
        mediaUrls: _mediaUrls,
        videoUrl: _videoUrl,
        videoThumbnailUrl: _videoThumbnailUrl,
        linkUrl: _extractFirstUrl(_bodyController.text),
        tags: ['#NewPost', '#Community'],
        pollOptions: _isPollEnabled ? _pollOptions.where((opt) => opt.trim().isNotEmpty).map((opt) => PollOption(id: UniqueKey().toString(), label: opt.trim())).toList() : null,
        pollEndsAt: _isPollEnabled ? DateTime.now().add(Duration(days: _pollDurationDays)) : null,
        idempotencyKey: idempotencyKey,
      );

      await ref.read(forumPostsProvider.notifier).addPost(request);
      
      // ✅ Haptic feedback on success
      HapticFeedback.lightImpact();
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post shared successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (e is NetworkException) {
        // Queue for later sync
        final idempotencyKey = UniqueKey().toString();
        final request = CreatePostRequest(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          type: _isPollEnabled ? PostType.poll : PostType.hybrid,
          communityId: _selectedCommunityId,
          communityName: _selectedCommunityName,
          mediaUrls: _mediaUrls,
          videoUrl: _videoUrl,
          videoThumbnailUrl: _videoThumbnailUrl,
          linkUrl: _extractFirstUrl(_bodyController.text),
          tags: ['#NewPost', '#Community'],
          pollOptions: _isPollEnabled ? _pollOptions.where((opt) => opt.trim().isNotEmpty).map((opt) => PollOption(id: UniqueKey().toString(), label: opt.trim())).toList() : null,
          pollEndsAt: _isPollEnabled ? DateTime.now().add(Duration(days: _pollDurationDays)) : null,
          idempotencyKey: idempotencyKey,
        );
        await ref.read(submissionQueueProvider.notifier).enqueue(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved offline. Will post when connected.')),
          );
          context.pop();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickMedia() async {
    if (_mediaUrls.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed')),
      );
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    
    if (image == null) return;

    setState(() => _isUploading = true);

    final uploadId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() => _mediaUploadProgress[uploadId] = 0.0);

    try {
      final cloudinary = ref.read(cloudinaryServiceProvider);
      final response = await cloudinary.uploadFile(
        file: image,
        resourceType: 'image',
        onProgress: (progress) {
          if (mounted) {
            setState(() => _mediaUploadProgress[uploadId] = progress);
          }
        },
      );

      if (response != null) {
        setState(() {
          _mediaUrls.add(response.secureUrl);
        });
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _mediaUploadProgress.remove(uploadId);
          _isUploading = _mediaUploadProgress.isNotEmpty;
        });
      }
    }
  }

  Future<void> _pickVideo() async {
    if (_videoUrl != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only attach one video per post')),
      );
      return;
    }

    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 2),
    );
    
    if (video == null) return;
    
    final length = await video.length();
    if (length > 50 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video too large (max 50MB)')),
        );
      }
      return;
    }
    
    setState(() => _isUploading = true);
    final uploadId = 'video_${DateTime.now().millisecondsSinceEpoch}';
    setState(() => _mediaUploadProgress[uploadId] = 0.0);
    
    try {
      final cloudinary = ref.read(cloudinaryServiceProvider);
      final result = await cloudinary.uploadFile(
        file: video,
        resourceType: 'video',
        onProgress: (progress) { 
          if (mounted) {
            setState(() => _mediaUploadProgress[uploadId] = progress);
          }
        },
      );
      if (result != null) {
        setState(() {
          _videoUrl = result.secureUrl;
          _videoThumbnailUrl = result.thumbnailUrl;
        });
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _mediaUploadProgress.remove(uploadId);
          _isUploading = _mediaUploadProgress.isNotEmpty;
        });
      }
    }
  }

  void _showCommunityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final communitiesAsync = ref.watch(communitiesProvider);

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Select Community', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                communitiesAsync.when(
                  data: (communities) => Column(
                    children: communities.map((c) => ListTile(
                      leading: const Icon(Icons.mosque_rounded, color: AppColors.primary),
                      title: Text(c['name'] as String, style: AppTypography.bodyLarge),
                      trailing: _selectedCommunityId == c['id'] ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                      onTap: () {
                        setState(() {
                          _selectedCommunityId = c['id'] as String;
                          _selectedCommunityName = c['name'] as String;
                        });
                        Navigator.pop(context);
                      },
                    )).toList(),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                  error: (err, stack) => ListTile(
                    title: const Text('Error loading communities'),
                    subtitle: Text(err.toString()),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canPost = _titleController.text.isNotEmpty || _bodyController.text.isNotEmpty;

    return PopScope(
      canPop: !_isUploading && !_isSubmitting,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Discard Post?'),
            content: Text(_isUploading 
              ? 'An upload is still in progress. Leaving now will cancel the upload.' 
              : 'You have unsaved changes. Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: const Text('Discard', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        appBar: _PostAppBar(
          canPost: canPost,
          isSubmitting: _isSubmitting,
          selectedCommunityName: _selectedCommunityName,
          onPost: _submitPost,
          onClearDraft: _clearDraft,
          onClose: () {
            if (!_isUploading && !_isSubmitting) {
              context.pop();
            } else {
              // Trigger PopScope logic manually
              Navigator.of(context).maybePop();
            }
          },
          onCommunitySelect: _showCommunityPicker,
          initialType: widget.initialType,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      children: [
                        _buildStatusIndicator(),
                        _buildModeToggle(),
                        if (_mediaUploadProgress.isNotEmpty) _buildOverallProgress(),
                        const SizedBox(height: 32),
                        _PostComposerBody(
                          titleController: _titleController,
                          bodyController: _bodyController,
                          titleCharCountNotifier: _titleCharCountNotifier,
                          bodyCharCountNotifier: _bodyCharCountNotifier,
                          isPreviewMode: _isPreviewMode,
                          isPollEnabled: _isPollEnabled,
                          pollOptions: _pollOptions,
                          onPollToggle: () => setState(() => _isPollEnabled = !_isPollEnabled),
                          onAddPollOption: () {
                            if (_pollOptions.length < 4) {
                              setState(() => _pollOptions.add(''));
                            }
                          },
                          onRemovePollOption: (index) {
                            if (_pollOptions.length > 2) {
                              setState(() => _pollOptions.removeAt(index));
                            }
                          },
                          onPollOptionChanged: (index, val) => _pollOptions[index] = val,
                          videoUrl: _videoUrl,
                          videoThumbnailUrl: _videoThumbnailUrl,
                          mediaUrls: _mediaUrls,
                          isUploading: _isUploading,
                          isFetchingPreview: _isFetchingPreview,
                          linkPreview: _linkPreview,
                          onDismissLink: () {
                            setState(() {
                              _dismissedLinkUrl = _linkPreview?.url;
                              _linkPreview = null;
                            });
                          },
                          onMediaPick: _pickMedia,
                          onMediaDelete: (index) => setState(() => _mediaUrls.removeAt(index)),
                          onVideoDelete: () => setState(() { _videoUrl = null; _videoThumbnailUrl = null; }),
                          onVideoAdd: _pickVideo,
                          selectedCommunityId: _selectedCommunityId,
                          selectedCommunityName: _selectedCommunityName,
                          initialType: widget.initialType,
                        ),
                        const SizedBox(height: 120), // Toolbar spacing
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _FormattingToolbar(
                onBold: () {},
                onItalic: () {},
                onLink: () {},
                onList: () {},
                onQuote: () {},
                onMention: () {},
                onHideKeyboard: () => FocusScope.of(context).unfocus(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress() {
    final avgProgress = _mediaUploadProgress.values.fold(0.0, (a, b) => a + b) / _mediaUploadProgress.length;
    
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: avgProgress,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            'Uploading Media... ${(avgProgress * 100).toInt()}%',
            style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }


  Widget _buildStatusIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            'SAVED TO SANCTUARY',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: AppShapes.fullRadius,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem(
            'Compose',
            isActive: !_isPreviewMode,
            onTap: () => setState(() => _isPreviewMode = false),
          ),
          _buildToggleItem(
            'Preview',
            isActive: _isPreviewMode,
            onTap: () => setState(() => _isPreviewMode = true),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.bgLight : Colors.transparent,
          borderRadius: AppShapes.fullRadius,
          boxShadow: isActive ? [
            BoxShadow(
              color: AppColors.taupe.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isActive ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }



}

class _PostAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool canPost;
  final bool isSubmitting;
  final String selectedCommunityName;
  final VoidCallback onPost;
  final VoidCallback onClearDraft;
  final VoidCallback onClose;
  final VoidCallback onCommunitySelect;

  final String? initialType;
 
  const _PostAppBar({
    required this.canPost,
    required this.isSubmitting,
    required this.selectedCommunityName,
    required this.onPost,
    required this.onClearDraft,
    required this.onClose,
    required this.onCommunitySelect,
    this.initialType,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgLight,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: onClose,
        icon: const Icon(Icons.close_rounded, color: AppColors.textPrimaryLight),
      ),
      title: Column(
        children: [
          Text(
            'New ${initialType == 'community' ? 'Post' : 'Reflection'}',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onCommunitySelect,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedCommunityName.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more_rounded, size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (!isSubmitting)
          IconButton(
            onPressed: onClearDraft,
            icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
            tooltip: 'Clear Draft',
          ),
        isSubmitting
            ? const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))))
            : TextButton(
                onPressed: canPost ? onPost : null,
                child: Text(
                  'Post',
                  style: AppTypography.titleMedium.copyWith(
                    color: canPost ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

class _PostComposerBody extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final ValueNotifier<int> titleCharCountNotifier;
  final ValueNotifier<int> bodyCharCountNotifier;
  final bool isPreviewMode;
  final bool isPollEnabled;
  final List<String> pollOptions;
  final VoidCallback onPollToggle;
  final VoidCallback onAddPollOption;
  final Function(int) onRemovePollOption;
  final Function(int, String) onPollOptionChanged;
  final String? videoUrl;
  final String? videoThumbnailUrl;
  final List<String> mediaUrls;
  final bool isUploading;
  final bool isFetchingPreview;
  final LinkPreview? linkPreview;
  final VoidCallback onDismissLink;
  final VoidCallback onMediaPick;
  final Function(int) onMediaDelete;
  final VoidCallback onVideoDelete;
  final VoidCallback onVideoAdd;

  final String selectedCommunityId;
  final String selectedCommunityName;
  final String? initialType;
 
  const _PostComposerBody({
    required this.titleController,
    required this.bodyController,
    required this.titleCharCountNotifier,
    required this.bodyCharCountNotifier,
    required this.isPreviewMode,
    required this.isPollEnabled,
    required this.pollOptions,
    required this.onPollToggle,
    required this.onAddPollOption,
    required this.onRemovePollOption,
    required this.onPollOptionChanged,
    this.videoUrl,
    this.videoThumbnailUrl,
    required this.mediaUrls,
    required this.isUploading,
    required this.isFetchingPreview,
    this.linkPreview,
    required this.onDismissLink,
    required this.onMediaPick,
    required this.onMediaDelete,
    required this.onVideoDelete,
    required this.onVideoAdd,
    required this.selectedCommunityId,
    required this.selectedCommunityName,
    this.initialType,
  });

  @override
  Widget build(BuildContext context) {
    if (isPreviewMode) {
      return _buildPreviewCard(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Community Selector & Title Area
        _buildHeader(),
        const SizedBox(height: 24),
        // Body Editor
        _buildBodyEditor(),
        if (isPollEnabled) ...[
          const SizedBox(height: 32),
          _buildPollSection(),
        ],
        const SizedBox(height: 32),
        _buildMediaSection(),
        if (linkPreview != null) ...[
          const SizedBox(height: 32),
          _buildLinkPreviewSection(onDismissLink),
        ],
      ],
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    final titleText = titleController.text.trim();
    final bodyText = bodyController.text.trim();
    
    final previewPost = PostEntity(
      id: 'preview',
      authorId: 'me',
      authorName: 'You',
      authorAvatarUrl: null, 
      communityId: selectedCommunityId,
      communityName: selectedCommunityName,
      title: titleText.isEmpty ? 'Untitled ${initialType == 'community' ? 'Post' : 'Reflection'}' : titleText,
      body: bodyText,
      mediaUrls: mediaUrls,
      videoUrl: videoUrl,
      videoThumbnailUrl: videoThumbnailUrl,
      linkUrl: linkPreview?.url,
      type: isPollEnabled ? PostType.poll : PostType.hybrid,
      createdAt: DateTime.now(),
      pollOptions: isPollEnabled 
          ? pollOptions.asMap().entries.map((e) => PollOption(id: e.key.toString(), label: e.value)).toList() 
          : null,
      pollEndsAt: isPollEnabled ? DateTime.now().add(const Duration(days: 1)) : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'POST PREVIEW',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ForumPostCard(
          key: UniqueKey(),
          post: previewPost,
          interactive: false,
          onUpvote: () {},
          onDownvote: () {},
          onComment: () {},
          onShare: () {},
          onBookmark: () {},
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'This is how your post will appear to the community.',
            style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondaryLight),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: titleController,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: 'Title of your reflection...',
            hintStyle: AppTypography.headlineMedium.copyWith(
              color: AppColors.textSecondaryLight.withValues(alpha: 0.3),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          maxLines: null,
          maxLength: 120,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
        ),
        ValueListenableBuilder<int>(
          valueListenable: titleCharCountNotifier,
          builder: (context, length, child) {
            return Text(
              '$length / 120',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                letterSpacing: 1.2,
              ),
            );
          },
        ),
        const Divider(color: AppColors.secondary, height: 1),
      ],
    );
  }

  Widget _buildBodyEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: bodyController,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textPrimaryLight,
            height: 1.7,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            hintText: 'Write your thoughts... use @ to mention community members or # for spiritual tags.',
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondaryLight.withValues(alpha: 0.3),
              fontSize: 18,
            ),
            border: InputBorder.none,
          ),
          maxLines: null,
          minLines: 8,
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<int>(
          valueListenable: bodyCharCountNotifier,
          builder: (context, length, child) {
            return Text(
              '$length characters',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                letterSpacing: 0.5,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPollSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: AppShapes.lg,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isPreviewMode ? 'POLL PREVIEW' : 'POLL OPTIONS',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!isPreviewMode)
                IconButton(
                  onPressed: onPollToggle,
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.error),
                  tooltip: 'Remove Poll',
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...pollOptions.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            
            if (isPreviewMode) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.radio_button_off_rounded, size: 18, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option.isEmpty ? 'Option ${index + 1}' : option,
                          style: AppTypography.bodyMedium.copyWith(
                            color: option.isEmpty ? AppColors.onSurfaceVariant.withValues(alpha: 0.5) : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => onPollOptionChanged(index, val),
                      controller: TextEditingController(text: option)..selection = TextSelection.fromPosition(TextPosition(offset: option.length)),
                      decoration: InputDecoration(
                        hintText: 'Option ${index + 1}',
                        filled: true,
                        fillColor: AppColors.bgLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                  if (pollOptions.length > 2) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => onRemovePollOption(index),
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            );
          }),
          if (pollOptions.length < 4 && !isPreviewMode)
            TextButton.icon(
              onPressed: onAddPollOption,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Option'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppShapes.lg,
        boxShadow: [
          BoxShadow(
            color: AppColors.taupe.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: videoThumbnailUrl ?? '',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgDark.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: onVideoDelete,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.bgDark.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'MEDIA GALLERY',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondaryLight,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ToolbarButton(
                    icon: Icons.video_collection_outlined,
                    onPressed: onVideoAdd,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  _ToolbarButton(
                    icon: Icons.poll_outlined,
                    onPressed: onPollToggle,
                    color: isPollEnabled ? AppColors.primary : AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: isUploading ? null : onMediaPick,
                    icon: isUploading 
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                      : const Icon(Icons.add_a_photo_rounded, size: 16),
                    label: Text(isUploading ? 'Uploading...' : 'Add Media', style: const TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: AppShapes.fullRadius),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (videoUrl != null) ...[
          const SizedBox(height: 16),
          _buildVideoPreview(),
        ],
        if (mediaUrls.isNotEmpty) ...[
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: mediaUrls.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: AppShapes.md,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.taupe.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    CachedNetworkImage(imageUrl: mediaUrls[index], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => onMediaDelete(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.bgDark.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLinkPreviewSection(VoidCallback onDismiss) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.onSurfaceVariant),
              tooltip: 'Remove Preview',
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: AppShapes.lg,
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: AppColors.taupe.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: AppShapes.md,
                  image: DecorationImage(
                    image: NetworkImage(linkPreview!.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.language_rounded, size: 12, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          linkPreview!.url.split('/')[2].toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      linkPreview!.title,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      linkPreview!.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormattingToolbar extends StatelessWidget {
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onLink;
  final VoidCallback onList;
  final VoidCallback onQuote;
  final VoidCallback onMention;
  final VoidCallback onHideKeyboard;

  const _FormattingToolbar({
    required this.onBold,
    required this.onItalic,
    required this.onLink,
    required this.onList,
    required this.onQuote,
    required this.onMention,
    required this.onHideKeyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgLight.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1))),
        boxShadow: [
          BoxShadow(
            color: AppColors.taupe.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.paddingOf(context).bottom + 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildToolbarIcon(Icons.format_bold_rounded, onPressed: onBold),
                _buildToolbarIcon(Icons.format_italic_rounded, onPressed: onItalic),
                _buildToolbarIcon(Icons.link_rounded, onPressed: onLink),
                _buildToolbarIcon(Icons.list_rounded, onPressed: onList),
                _buildToolbarIcon(Icons.format_quote_rounded, onPressed: onQuote),
              ],
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                _buildToolbarIcon(Icons.alternate_email_rounded, color: AppColors.primary, onPressed: onMention),
                const SizedBox(width: 8),
                Container(width: 1, height: 24, color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                const SizedBox(width: 8),
                _buildToolbarIcon(Icons.keyboard_hide_rounded, onPressed: onHideKeyboard),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarIcon(IconData icon, {Color? color, required VoidCallback onPressed}) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color ?? AppColors.onSurfaceVariant, size: 22),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const _ToolbarButton({
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color ?? AppColors.onSurfaceVariant, size: 22),
      visualDensity: VisualDensity.compact,
    );
  }
}
