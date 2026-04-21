import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../core/design_tokens.dart';

class ShortVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final bool isVisible;

  const ShortVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.isVisible = false,
  });

  @override
  State<ShortVideoPlayer> createState() => _ShortVideoPlayerState();
}

class _ShortVideoPlayerState extends State<ShortVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller.initialize();
      _controller.setLooping(true);
      _controller.setVolume(0.0); // Muted for auto-play compatibility on Web
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        if (widget.isVisible) {
          _controller.play();
        }
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  void didUpdateWidget(ShortVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isInitialized) {
      if (widget.isVisible) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.8) {
          if (_isInitialized) _controller.play();
        } else {
          if (_isInitialized) _controller.pause();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail / Placeholder
          if (!_isInitialized || _hasError)
            Image.network(
              widget.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.emeraldBg),
            ),

          // Video Player
          if (_isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),

          // Loading Overlay
          if (!_isInitialized && !_hasError)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.emeraldPrimary),
              ),
            ),

          // Error Overlay
          if (_hasError)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load video',
                    style: AppTypography.body.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            
          // Click to play/pause overlay
          GestureDetector(
            onTap: () {
              if (_isInitialized) {
                _controller.value.isPlaying ? _controller.pause() : _controller.play();
              }
            },
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }
}
