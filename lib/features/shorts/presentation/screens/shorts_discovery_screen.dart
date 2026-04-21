import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_tokens.dart';

class ShortsDiscoveryScreen extends StatefulWidget {
  const ShortsDiscoveryScreen({super.key});

  @override
  State<ShortsDiscoveryScreen> createState() => _ShortsDiscoveryScreenState();
}

class _ShortsDiscoveryScreenState extends State<ShortsDiscoveryScreen> {
  final List<String> _categories = ['All', 'Quran', 'Hadith', 'Stories', 'Reminders', 'Nasheeds'];
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.emeraldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://images.pexels.com/photos/1036623/pexels-photo-1036623.jpeg'),
          ),
        ),
        title: Text(
          'BAYT-AL-NOOR',
          style: AppTypography.title.copyWith(
            color: AppColors.emeraldPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.emeraldSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search inspiration...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Categories
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedCategoryIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.emeraldGradient : null,
                      color: isSelected ? null : AppColors.emeraldSurface,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        color: isSelected ? AppColors.emeraldOnPrimary : Colors.grey,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Masonry Grid
          Expanded(
            child: MasonryGridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              itemCount: _mockDiscoveryItems.length,
              itemBuilder: (context, index) {
                final item = _mockDiscoveryItems[index];
                return _DiscoveryCard(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _DiscoveryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isLarge = item['isLarge'] ?? false;
    
    return GestureDetector(
      onTap: () => context.goNamed('shorts'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: NetworkImage(item['imageUrl']),
            fit: BoxFit.cover,
          ),
        ),
        child: AspectRatio(
          aspectRatio: isLarge ? 0.7 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Colors.black87, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item['tag'] != null) ...[
                  Row(
                    children: [
                      Icon(item['tagIcon'] ?? Icons.play_circle, color: AppColors.emeraldSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        item['tag']!.toUpperCase(),
                        style: const TextStyle(color: AppColors.emeraldSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  item['title'],
                  style: AppTypography.title.copyWith(color: Colors.white, fontSize: isLarge ? 18 : 14, fontWeight: FontWeight.bold),
                ),
                if (isLarge && item['subtitle'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    item['subtitle'],
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> _mockDiscoveryItems = [
  {
    'imageUrl': 'https://images.pexels.com/photos/2362002/pexels-photo-2362002.jpeg',
    'title': 'The Power of Dua',
    'tag': '2.4k plays',
    'tagIcon': Icons.play_circle,
    'isLarge': true,
  },
  {
    'imageUrl': 'https://images.pexels.com/photos/333850/pexels-photo-333850.jpeg',
    'title': 'Daily Wisdom',
    'isLarge': false,
  },
  {
    'imageUrl': 'https://images.pexels.com/photos/167699/pexels-photo-167699.jpeg',
    'title': 'Finding Peace',
    'isLarge': false,
  },
  {
    'imageUrl': 'https://images.pexels.com/photos/2087391/pexels-photo-2087391.jpeg',
    'title': 'Prophetic Patience',
    'subtitle': 'Exploring the depths of resilience through the lives of the Messengers.',
    'tag': 'Featured Narrative',
    'tagIcon': Icons.auto_awesome,
    'isLarge': true,
  },
  {
    'imageUrl': 'https://images.pexels.com/photos/1252890/pexels-photo-1252890.jpeg',
    'title': "The Ocean's Dhikr",
    'isLarge': false,
  },
];
