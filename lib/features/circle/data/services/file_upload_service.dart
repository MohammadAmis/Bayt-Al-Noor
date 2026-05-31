import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/cloudinary_service.dart';

class FileUploadService {
  final CloudinaryService _cloudinary = CloudinaryService();

  /// Cross-platform upload: uses Cloudinary.
  Future<String> uploadXFile({
    required XFile xFile,
    required String chatId,
    required StreamController<double> progressController,
  }) async {
    try {
      final resourceType = _guessResourceType(xFile.name);
      
      final response = await _cloudinary.uploadFile(
        file: xFile,
        resourceType: resourceType,
        folder: 'bayt_al_noor/circle/$chatId',
        onProgress: (progress) {
          if (!progressController.isClosed) {
            progressController.add(progress);
          }
        },
      );

      if (response == null) {
        throw Exception('Cloudinary returned null');
      }

      progressController.add(1.0);
      return response.secureUrl;
    } catch (e) {
      progressController.addError(e);
      debugPrint('❌ FileUploadService.uploadXFile failed: $e');
      throw Exception('Upload failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> listChatResources(String chatId) async {
    // Cloudinary doesn't easily allow listing by prefix securely on client side.
    // For now, we return an empty list or we could fetch from DB metadata.
    return [];
  }

  String _guessResourceType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['mp4', 'mov', 'avi', 'mkv'].contains(ext)) return 'video';
    return 'image';
  }

}