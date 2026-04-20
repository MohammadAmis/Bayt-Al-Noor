import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../data/services/tasbih_service.dart';

class DhikrInfoCard extends StatelessWidget {
  final TasbihService service;

  const DhikrInfoCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final dhikr = service.selectedDhikr;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header with Arabic text
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.85),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  top: -10,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dhikr.arabic,
                      style: AppTypography.headline.copyWith(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dhikr.transliteration,
                      style: AppTypography.title.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      dhikr.translation,
                      style: AppTypography.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Spiritual Benefits Section
          if (dhikr.benefit != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'SPIRITUAL VIRTUES',
                    style: AppTypography.label.copyWith(
                      color: AppColors.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.orangeAccent, size: 16),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dhikr.benefit!,
                          style: AppTypography.body.copyWith(
                            color: AppColors.onSurface.withValues(alpha: 0.8),
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // 3. Hadith / Prophetic Wisdom Section
          if (dhikr.hadith != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border(
                  left: BorderSide(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    width: 4,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Icon(Icons.format_quote_rounded, color: AppColors.secondary.withValues(alpha: 0.3), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'PROPHETIC WISDOM',
                        style: AppTypography.label.copyWith(
                          color: AppColors.secondary.withValues(alpha: 0.6),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dhikr.hadith!,
                    style: AppTypography.body.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
