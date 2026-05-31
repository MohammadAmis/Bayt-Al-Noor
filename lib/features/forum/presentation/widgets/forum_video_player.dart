import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ForumVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;

  const ForumVideoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
  });

  @override
  State<ForumVideoPlayer> createState() => _ForumVideoPlayerState();
}

class _ForumVideoPlayerState extends State<ForumVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            child: VideoPlayer(_controller),
          ),
          if (_showControls)
            _buildControls(),
          VideoProgressIndicator(_controller, allowScrubbing: true),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: IconButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying ? _controller.pause() : _controller.play();
            });
          },
          icon: Icon(
            _controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 48,
          ),
        ),
      ),
    );
  }
}
