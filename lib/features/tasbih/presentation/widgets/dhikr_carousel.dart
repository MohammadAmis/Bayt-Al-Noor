import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../data/services/tasbih_service.dart';
import 'tasbih_counters.dart';

class DhikrCarousel extends StatefulWidget {
  final TasbihService service;

  const DhikrCarousel({
    super.key,
    required this.service,
  });

  @override
  State<DhikrCarousel> createState() => _DhikrCarouselState();
}

class _DhikrCarouselState extends State<DhikrCarousel> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.service.addListener(_onServiceChange);
    
    // Initial scroll
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void dispose() {
    widget.service.removeListener(_onServiceChange);
    _scrollController.dispose();
    super.dispose();
  }

  void _onServiceChange() {
    if (mounted) {
      _scrollToSelected();
    }
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;

    final index = widget.service.selectedDhikrIndex;
    const cardWidth = 160.0;
    const spacing = 12.0;
    
    // Calculate central position
    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset = (index * (cardWidth + spacing)) - (screenWidth / 2) + (cardWidth / 2) + 24; // 24 is horizontal padding

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'FOCUS DHIKR',
              style: AppTypography.label.copyWith(
                color: AppColors.secondary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(widget.service.dhikrs.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == widget.service.dhikrs.length - 1 ? 0 : 12,
                ),
                child: DhikrCard(
                  dhikr: widget.service.dhikrs[index],
                  isSelected: widget.service.selectedDhikrIndex == index,
                  onTap: () => widget.service.selectDhikr(index),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class SeriesModeToggle extends StatelessWidget {
  final TasbihService service;

  const SeriesModeToggle({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'SERIES',
              style: AppTypography.label.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: AppColors.primary,
                letterSpacing: 1.0,
              ),
            ),
          ),
          SizedBox(
            height: 24,
            width: 32,
            child: Switch.adaptive(
              value: service.isSeriesMode,
              onChanged: (val) => service.toggleSeriesMode(val),
              activeThumbColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
