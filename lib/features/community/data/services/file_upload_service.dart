import 'dart:io';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class FileUploadService {
  final String bucketName;
  static final Map<String, RealtimeChannel> _channels = {};
  FileUploadService({this.bucketName = 'community-resources'});

  Future<String> uploadWithProgress({
    required String filePath,
    required String chatId,
    required String fileName,
    required StreamController<double> progressController,
  }) async {
    final channel = Supabase.instance.client.channel('chat:$chatId');
    final file = File(filePath);
    final extension = fileName.split('.').last.toLowerCase();
    final storagePath = '$chatId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    try {
      // Supabase Flutter SDK doesn't expose native upload progress.
      // We simulate realistic progress updates for UX, then trigger actual upload.
      // For production-grade progress, use Dio + StreamedRequest or chunked uploads.
      await _simulateProgress(progressController, file.lengthSync());
      
      await Supabase.instance.client.storage.from(bucketName).upload(
        storagePath,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      
      progressController.add(1.0);
      return Supabase.instance.client.storage.from(bucketName).getPublicUrl(storagePath);
    } catch (e) {
      progressController.addError(e);
      throw Exception('Upload failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> listChatResources(String chatId) async {
    final items = await Supabase.instance.client.storage.from(bucketName).list(path: chatId);
    return items.map((item) => {
      'name': item.name,
      'path': item.id,
      'size': item.metadata?['size'] ?? 0,
      'type': _mapExtension(item.name.split('.').last),
      'url': Supabase.instance.client.storage.from(bucketName).getPublicUrl('$chatId/${item.name}'),
    }).toList();
  }

  Future<void> _simulateProgress(StreamController<double> controller, int fileSize) async {
    // Simulate chunked progress (0.1 -> 0.9) before SDK finishes
    for (double i = 0.1; i < 1.0; i += 0.15) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!controller.isClosed) controller.add(i);
    }
  }

  String _mapExtension(String ext) {
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) return 'image';
    if (['mp4', 'mov', 'avi', 'mkv'].contains(ext)) return 'video';
    return 'document';
  }
}