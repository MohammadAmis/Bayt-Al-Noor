import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../states/resource_state.dart';
import '../../data/services/file_upload_service.dart';
import '../../data/providers/chat_providers.dart';

part 'resource_viewmodel.g.dart';

@riverpod
class ResourceViewModel extends _$ResourceViewModel {
  final Map<String, StreamController<double>> _uploadStreams = {};

  @override
  ResourceState build(String chatId) {
    _loadResources(chatId);
    ref.onDispose(() {
      for (var s in _uploadStreams.values) {
        s.close();
      }
    });
    return const ResourceState(isLoading: true);
  }

  Future<void> _loadResources(String chatId) async {
    try {
      final service = FileUploadService();
      final rawResources = await service.listChatResources(chatId);
      
      final mapped = rawResources.map((r) => ResourceEntity(
        id: r['path'] as String,
        name: r['name'] as String,
        url: r['url'] as String,
        type: ResourceType.values.firstWhere((t) => t.name == r['type'], orElse: () => ResourceType.document),
        size: _formatSize(r['size'] as int),
        uploadedAt: DateTime.now(),
        uploadedBy: 'current_user',
      )).toList();

      state = state.copyWith(resources: mapped, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load resources', isLoading: false);
    }
  }

  Stream<double> startUpload(XFile xFile, String fileName) {
    final controller = StreamController<double>();
    _uploadStreams[fileName] = controller;
    state = state.copyWith(activeUploadFile: fileName);

    unawaited(
      _performUpload(xFile, fileName, controller).then((url) {
        // 1. Save metadata to Supabase DB
        ref.read(chatRepositoryProvider).shareResource(
          chatId, url, _getResourceType(fileName).name, {}
        );
        // 2. Refresh list
        _loadResources(chatId);
      }).catchError((e) {
        controller.addError(e);
      }).whenComplete(() {
        controller.close();
        _uploadStreams.remove(fileName);
        state = state.copyWith(activeUploadFile: null);
      })
    );

    return controller.stream;
  }

  void cancelUpload(String fileName) {
    _uploadStreams[fileName]?.close();
    _uploadStreams.remove(fileName);
    state = state.copyWith(activeUploadFile: null);
  }

  Future<String> _performUpload(XFile xFile, String name, StreamController<double> ctrl) async {
    return FileUploadService().uploadXFile(
      xFile: xFile,
      chatId: chatId,
      progressController: ctrl,
    );
  }

  ResourceType _getResourceType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) return ResourceType.image;
    return ResourceType.document;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}