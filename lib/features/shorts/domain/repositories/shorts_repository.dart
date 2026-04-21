import '../entities/short_video.dart';

abstract class ShortsRepository {
  Future<List<ShortVideo>> getShorts();
  Future<List<ShortVideo>> getShortsByCategory(String category);
  Future<List<ShortVideo>> searchShorts(String query);
  Future<void> likeShort(String videoId);
  Future<void> bookmarkShort(String videoId);
}
