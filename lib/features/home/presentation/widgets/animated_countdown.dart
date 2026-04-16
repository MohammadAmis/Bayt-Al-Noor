import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';

class _AnimatedCountdown extends StatefulWidget {
  final Duration duration;
  final bool isPrayerTime;
  
  const _AnimatedCountdown({
    required this.duration,
    required this.isPrayerTime,
  });

  @override
  State<_AnimatedCountdown> createState() => _AnimatedCountdownState();
}

class _AnimatedCountdownState extends State<_AnimatedCountdown>
    with SingleTickerProviderStateMixin {
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void didUpdateWidget(_AnimatedCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      // Trigger subtle scale animation on change
      _triggerUpdateAnimation();
    }
  }
  
  void _triggerUpdateAnimation() {
    // Could add a subtle flash or scale here if desired
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPrayerTime || widget.duration.inSeconds <= 0) {
      return _PrayerTimeBadge();
    }
    
    final hours = widget.duration.inHours;
    final minutes = widget.duration.inMinutes.remainder(60);
    final seconds = widget.duration.inSeconds.remainder(60);
    final showSeconds = hours == 0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CountdownSegment(
          value: hours.toString().padLeft(2, '0'),
          label: 'h',
          isPrimary: true,
        ),
        _CountdownSeparator(),
        _CountdownSegment(
          value: minutes.toString().padLeft(2, '0'),
          label: 'm',
          isPrimary: true,
        ),
        if (showSeconds) ...[
          _CountdownSeparator(),
          _CountdownSegment(
            value: seconds.toString().padLeft(2, '0'),
            label: 's',
            isPrimary: false,
          ),
        ],
      ],
    );
  }
}

class _CountdownSegment extends StatelessWidget {
  final String value;
  final String label;
  final bool isPrimary;
  
  const _CountdownSegment({
    required this.value,
    required this.label,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Digit display with subtle glass effect
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPrimary ? 18 : 14,
            vertical: isPrimary ? 12 : 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.12),
            borderRadius: AppShapes.lgRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha:0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            value,
            style: (isPrimary ? AppTypography.display : AppTypography.headline).copyWith(
              color: Colors.white,
              fontSize: isPrimary ? 36 : 28,
              fontWeight: FontWeight.w700,
              fontFeatures: [const FontFeature.tabularFigures()], // Monospaced digits
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Label
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: Colors.white.withValues(alpha:0.85),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _CountdownSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _PrayerTimeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.2),
        borderRadius: AppShapes.fullRadius,
        border: Border.all(color: Colors.white.withValues(alpha:0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Text(
            'Time to Pray',
            style: AppTypography.headline.copyWith(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}