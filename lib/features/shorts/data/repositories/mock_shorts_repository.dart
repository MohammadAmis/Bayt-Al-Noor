import '../../domain/entities/short_video.dart';
import '../../domain/repositories/shorts_repository.dart';

class MockShortsRepository implements ShortsRepository {
  final List<ShortVideo> _mockShorts = [
    ShortVideo(
      id: '1',
      videoUrl: 'https://lorem.video/720p.mp4',
      thumbnailUrl: 'https://images.pexels.com/photos/167699/pexels-photo-167699.jpeg',
      caption: '"And He is with you wherever you are."',
      authorName: 'Zahra Al-Farsi',
      authorAvatarUrl: 'https://images.pexels.com/photos/1036623/pexels-photo-1036623.jpeg',
      reference: 'Quran 57:4',
      category: 'Daily Ayat',
      tags: const ['#Quran', '#Deen', '#Reminder'],
      likesCount: 12400,
      commentsCount: 892,
      bookmarksCount: 3100,
      createdAt: DateTime.now(),
    ),
    ShortVideo(
      id: '2',
      videoUrl: 'https://lorem.video/480p.mp4',
      thumbnailUrl: 'https://images.pexels.com/photos/1252890/pexels-photo-1252890.jpeg',
      caption: '"Patience is the key to paradise."',
      authorName: 'Ahmad Al-Mansur',
      authorAvatarUrl: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg',
      reference: 'Imam Ali (as)',
      category: 'Spiritual Wisdom',
      tags: const ['#Sabr', '#Wisdom'],
      likesCount: 8500,
      commentsCount: 420,
      bookmarksCount: 1200,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ShortVideo(
      id: '3',
      videoUrl: 'https://lorem.video/360p.mp4',
      thumbnailUrl: 'https://images.pexels.com/photos/333850/pexels-photo-333850.jpeg',
      caption: 'Finding stillness in the patterns of time.',
      authorName: 'Zahra Al-Farsi',
      authorAvatarUrl: 'https://images.pexels.com/photos/1036623/pexels-photo-1036623.jpeg',
      category: 'Reflections',
      tags: const ['#Peace', '#Mindfulness'],
      likesCount: 5200,
      commentsCount: 156,
      bookmarksCount: 890,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<ShortVideo>> getShorts() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    return _mockShorts;
  }

  @override
  Future<List<ShortVideo>> getShortsByCategory(String category) async {
    return _mockShorts.where((s) => s.category == category).toList();
  }

  @override
  Future<List<ShortVideo>> searchShorts(String query) async {
    final lowerQuery = query.toLowerCase();
    return _mockShorts.where((s) =>
        s.caption.toLowerCase().contains(lowerQuery) ||
        s.authorName.toLowerCase().contains(lowerQuery)).toList();
  }

  @override
  Future<void> likeShort(String videoId) async {
    // Mock interaction
  }

  @override
  Future<void> bookmarkShort(String videoId) async {
    // Mock interaction
  }
}
