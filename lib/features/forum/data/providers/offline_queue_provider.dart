import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'forum_providers.dart';

import 'package:hive_flutter/hive_flutter.dart';

class SubmissionQueueNotifier extends StateNotifier<List<CreatePostRequest>> {
  SubmissionQueueNotifier() : super([]) {
    _loadFromHive();
  }

  final _box = Hive.box('submission_queue');

  void _loadFromHive() {
    final List<dynamic>? savedData = _box.get('queue');
    if (savedData != null) {
      state = savedData
          .map((item) => CreatePostRequest.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }
  }

  Future<void> _saveToHive() async {
    final data = state.map((r) => r.toMap()).toList();
    await _box.put('queue', data);
  }

  Future<void> enqueue(CreatePostRequest request) async {
    state = [...state, request];
    await _saveToHive();
  }

  Future<void> dequeue(CreatePostRequest request) async {
    state = state.where((r) => r.idempotencyKey != request.idempotencyKey).toList();
    await _saveToHive();
  }
}

final submissionQueueProvider = StateNotifierProvider<SubmissionQueueNotifier, List<CreatePostRequest>>((ref) {
  return SubmissionQueueNotifier();
});
