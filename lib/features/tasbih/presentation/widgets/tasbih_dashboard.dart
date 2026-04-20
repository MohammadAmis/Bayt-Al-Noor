import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import '../../../../core/design_tokens.dart';
import '../../data/services/tasbih_service.dart';

enum TimeRange { week, month, year }

class TasbihDashboard extends StatefulWidget {
  final TasbihService service;

  const TasbihDashboard({super.key, required this.service});

  @override
  State<TasbihDashboard> createState() => _TasbihDashboardState();
}

class _TasbihDashboardState extends State<TasbihDashboard> {
  TimeRange _selectedRange = TimeRange.week;

  @override
  Widget build(BuildContext context) {
    if (!widget.service.isInitialized) return const SizedBox.shrink();

    final data = _getCurrentData();
    final total = _getCurrentTotal();
    final bestDayCount = _getBestDay();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INSIGHTS',
          style: AppTypography.label.copyWith(
            color: AppColors.secondary,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 16),
        
        // Personal Record Card
        _DashboardCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium, color: AppColors.secondary, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PERSONAL RECORD',
                    style: AppTypography.label.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.secondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'Best Day: $bestDayCount counts',
                    style: AppTypography.title.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        
        // Main Insights Card
        _DashboardCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedRange.name.toUpperCase()} PROGRESS',
                        style: AppTypography.label.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: AppColors.secondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatNumber(total),
                        style: AppTypography.headline.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  _buildViewSelector(),
                ],
              ),
              const SizedBox(height: 40),
              
              // Dynamic Chart
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(
                  painter: BarChartPainter(
                    data: data,
                    barColor: AppColors.primary,
                    highlightToday: _selectedRange == TimeRange.week,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildChartLabels(),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Global Stats Row
        Row(
          children: [
            _buildStatBox(
              'Lifetime Total', 
              widget.service.lifetimeTotal, 
              Icons.history_rounded,
            ),
            const SizedBox(width: 16),
            _buildStatBox(
              'Current Streak', 
              widget.service.streak, 
              Icons.local_fire_department_rounded,
              suffix: ' days',
            ),
          ],
        ),
      ],
    );
  }

  List<int> _getCurrentData() {
    switch (_selectedRange) {
      case TimeRange.week: return widget.service.getWeeklyData();
      case TimeRange.month: return widget.service.getMonthlyData();
      case TimeRange.year: return widget.service.getYearlyData();
    }
  }

  int _getCurrentTotal() {
    switch (_selectedRange) {
      case TimeRange.week: return widget.service.getWeeklyTotal();
      case TimeRange.month: return widget.service.getMonthlyTotal();
      case TimeRange.year: return widget.service.getYearlyTotal();
    }
  }

  int _getBestDay() {
    int best = 0;
    widget.service.history.forEach((_, value) {
      if (value > best) best = value;
    });
    return best;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}k';
    return '$number';
  }

  Widget _buildViewSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TimeRange.values.map((range) {
          bool isSelected = _selectedRange == range;
          return GestureDetector(
            onTap: () => setState(() => _selectedRange = range),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Text(
                range.name.toUpperCase(),
                style: AppTypography.label.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartLabels() {
    List<String> labels;
    bool isYear = _selectedRange == TimeRange.year;
    
    switch (_selectedRange) {
      case TimeRange.week:
        final now = DateTime.now();
        labels = List.generate(7, (i) => DateFormat('E').format(now.subtract(Duration(days: 6 - i)))[0]);
        break;
      case TimeRange.month:
        labels = ['W1', 'W2', 'W3', 'W4', 'W5'];
        break;
      case TimeRange.year:
        labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: labels.map((label) => Expanded(
        child: Center(
          child: RotatedBox(
            quarterTurns: isYear ? 3 : 0,
            child: Text(
              label,
              style: AppTypography.label.copyWith(
                fontSize: 9,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildStatBox(String label, int value, IconData icon, {String suffix = ''}) {
    return Expanded(
      child: _DashboardCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppColors.secondary.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text(
              label.toUpperCase(),
              style: AppTypography.label.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_formatNumber(value)}$suffix',
              style: AppTypography.title.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _DashboardCard({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.05),
        ),
      ),
      child: child,
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<int> data;
  final Color barColor;
  final bool highlightToday;

  BarChartPainter({
    required this.data, 
    required this.barColor,
    required this.highlightToday,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxVal == 0 ? 10 : maxVal;
    
    const barRatio = 0.35; // Controls bar thickness
    final step = size.width / data.length;
    final barWidth = step * barRatio;
    
    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i] / effectiveMax) * size.height;
      final x = (i * step) + (step - barWidth) / 2;
      final y = size.height - barHeight;

      // 1. Background "Glass" track
      final trackRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, barWidth, size.height),
        const Radius.circular(100),
      );
      canvas.drawRRect(
        trackRect,
        Paint()..color = barColor.withValues(alpha: 0.04),
      );

      // 2. Main Bar with Volumetric Gradient
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(100),
      );

      final paint = Paint()..style = PaintingStyle.fill;
      
      // Vertical cylinder gradient
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          barColor,
          barColor.withValues(alpha: 0.7),
        ],
      ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight));

      canvas.drawRRect(barRect, paint);

      // 3. Draw Count Label above bar
      if (data[i] > 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: _formatCompact(data[i]),
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: barColor.withValues(alpha: 0.8),
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(x + (barWidth - textPainter.width) / 2, y - textPainter.height - 4),
        );
      }
      
      // 4. Highlight Glare (Specular reflection)
      final glarePaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight));
      
      canvas.drawRRect(barRect, glarePaint);

      // 5. Today / Active Indicator Glow
      if (highlightToday && i == data.length - 1) {
         final glowPaint = Paint()
           ..color = barColor.withValues(alpha: 0.3)
           ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
         
         canvas.drawRRect(barRect, glowPaint);
      }
    }
    
    // Draw subtle horizontal grid lines (Base and 50%)
    final gridPaint = Paint()
      ..color = AppColors.onSurfaceVariant.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), gridPaint);
    canvas.drawLine(Offset(0, size.height/2), Offset(size.width, size.height/2), gridPaint);
  }

  String _formatCompact(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}k';
    return '$number';
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
