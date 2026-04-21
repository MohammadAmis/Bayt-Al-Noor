import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/short_video.dart';
import '../../domain/repositories/shorts_repository.dart';
import '../../data/repositories/mock_shorts_repository.dart';

final shortsRepositoryProvider = Provider<ShortsRepository>((ref) {
  return MockShortsRepository();
});

final shortsFeedProvider = FutureProvider<List<ShortVideo>>((ref) async {
  final repo = ref.watch(shortsRepositoryProvider);
  return repo.getShorts();
});

final currentShortIndexProvider = StateProvider<int>((ref) => 0);
