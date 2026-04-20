import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../data/services/tasbih_service.dart';
import '../../data/models/dhikr_model.dart';

class ModernOrbCounter extends StatelessWidget {
  final int count;
  final int goal;
  final Dhikr dhikr;
  final VoidCallback onTap;
  final Animation<double> pulseAnimation;

  const ModernOrbCounter({
    super.key,
    required this.count,
    required this.goal,
    required this.dhikr,
    required this.onTap,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    double progress = (count / goal).clamp(0.0, 1.0);
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            double scale = 1.0 + (pulseAnimation.value * 0.05);
            return Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                   // Atmospheric Glow
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  
                  // Main Glass Orb
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.9),
                          Colors.white.withValues(alpha: 0.4),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (TasbihService.instance.languageMode == LanguageMode.arabic)
                          Text(
                            dhikr.arabic,
                            style: AppTypography.headline.copyWith(
                              fontSize: 22,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        if (TasbihService.instance.languageMode == LanguageMode.english)
                           Text(
                            dhikr.transliteration,
                            style: AppTypography.title.copyWith(
                              fontSize: 16,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        if (TasbihService.instance.languageMode == LanguageMode.arabic || 
                            TasbihService.instance.languageMode == LanguageMode.english)
                          const SizedBox(height: 16),
                        Text(
                          '$count',
                          style: AppTypography.display.copyWith(
                            fontSize: 84,
                            fontWeight: FontWeight.w200,
                            color: AppColors.primary,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'GOAL: $goal',
                          style: AppTypography.label.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 3D Progress Ring (Custom Painter)
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CustomPaint(
                      painter: ProgressRingPainter(
                        progress: progress,
                        color: AppColors.primary,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ClassicBeadsCounter extends StatefulWidget {
  final int count;
  final int goal;
  final Dhikr dhikr;
  final VoidCallback onTap;

  const ClassicBeadsCounter({
    super.key,
    required this.count,
    required this.goal,
    required this.dhikr,
    required this.onTap,
  });

  @override
  State<ClassicBeadsCounter> createState() => _ClassicBeadsCounterState();
}

class _ClassicBeadsCounterState extends State<ClassicBeadsCounter> with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(ClassicBeadsCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _slideController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 400,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Bead String (The Line)
            Container(
              width: 2,
              height: 350,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.brown.withValues(alpha: 0.0),
                    Colors.brown.withValues(alpha: 0.3),
                    Colors.brown.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            
            // The Beads
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(5, (index) {
                    // We show 5 beads, one is the "active" one being clicked
                    double offset = (index - 2) * 80.0;
                    double animatedOffset = offset + (_slideAnimation.value * 80.0);
                    
                    return Positioned(
                      top: 160 + animatedOffset,
                      child: _BeadWidget(
                         isCenter: index == 2,
                         opacity: (1 - (index - 2).abs() * 0.3).clamp(0.0, 1.0),
                      ),
                    );
                  }),
                );
              },
            ),

            // Counter Overlay
            Positioned(
              right: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.count}',
                    style: AppTypography.display.copyWith(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '/ ${widget.goal}',
                    style: AppTypography.label.copyWith(
                      color: AppColors.secondary.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Dhikr Label
             if (TasbihService.instance.languageMode == LanguageMode.arabic)
               Positioned(
                 top: 40,
                 child: Text(
                   widget.dhikr.arabic,
                   style: AppTypography.headline.copyWith(
                     fontSize: 28,
                     color: AppColors.onSurface,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
             if (TasbihService.instance.languageMode == LanguageMode.english)
               Positioned(
                 top: 40,
                 child: Text(
                   widget.dhikr.transliteration,
                   style: AppTypography.title.copyWith(
                     fontSize: 20,
                     color: AppColors.onSurface,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
          ],
        ),
      ),
    );
  }
}

class _BeadWidget extends StatelessWidget {
  final bool isCenter;
  final double opacity;

  const _BeadWidget({required this.isCenter, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 60,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8D6E63), // Wood brown
              Color(0xFF5D4037),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(5, 5),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 50,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DhikrCard extends StatelessWidget {
  final Dhikr dhikr;
  final bool isSelected;
  final VoidCallback onTap;

  const DhikrCard({
    super.key,
    required this.dhikr,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.outlineVariant.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (TasbihService.instance.languageMode == LanguageMode.arabic)
              Text(
                dhikr.arabic,
                style: AppTypography.headline.copyWith(
                  fontSize: 20,
                  color: isSelected ? Colors.white : AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            if (TasbihService.instance.languageMode == LanguageMode.english) ...[
              if (TasbihService.instance.isTransliterationVisible)
                Text(
                  dhikr.transliteration,
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              if (TasbihService.instance.isTranslationVisible)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    dhikr.translation,
                    style: AppTypography.body.copyWith(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: isSelected 
                          ? Colors.white.withValues(alpha: 0.7) 
                          : AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;
    const strokeWidth = 12.0;

    // 1. Draw Background Track (Groove)
    final trackPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final sweepAngle = 2 * 3.1415926535 * progress;

    // 2. Draw Bottom Shadow (for 3D depth)
    final shadowPaint = Paint()
      ..color = color.withValues(alpha:0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawArc(
      Rect.fromCircle(center: center + const Offset(2, 2), radius: radius),
      -3.1415926535 / 2,
      sweepAngle,
      false,
      shadowPaint,
    );

    // 3. Draw Primary Progress Path
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Add a simple gradient to the stroke
    progressPaint.shader = SweepGradient(
      colors: [color.withValues(alpha:0.8), color, color.withValues(alpha:0.8)],
      stops: const [0.0, 0.5, 1.0],
      transform: const GradientRotation(-3.1415926535 / 2),
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // 4. Draw Specular Highlight (The "3D Glint")
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha:0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth / 3
      ..strokeCap = StrokeCap.round;

    final highlightRadius = radius - 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: highlightRadius),
      -3.1415926535 / 2 + 0.1, // Slight offset
      sweepAngle - 0.2,
      false,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
