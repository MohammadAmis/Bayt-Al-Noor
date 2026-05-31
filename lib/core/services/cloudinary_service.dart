import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import '../secrets.dart';

class CloudinaryResponse {
  final String secureUrl;
  final String? thumbnailUrl;

  CloudinaryResponse({
    required this.secureUrl,
    this.thumbnailUrl,
  });
}

class CloudinaryService {
  final String _cloudName = CloudinarySecrets.cloudName;
  final String _apiKey = CloudinarySecrets.apiKey;
  final String _apiSecret = CloudinarySecrets.apiSecret;
  final Dio _dio = Dio();

  /// Uploads a file to Cloudinary and returns a [CloudinaryResponse].
  /// [resourceType] can be 'image' or 'video'.
  Future<CloudinaryResponse?> uploadFile({
    required XFile file,
    required String resourceType,
    String? folder = 'bayt_al_noor/forum',
    void Function(double progress)? onProgress,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      // Prepare parameters for signature
      final params = {
        'timestamp': timestamp.toString(),
        if (folder != null) 'folder': folder,
      };

      // Sort parameters alphabetically for signature
      final sortedKeys = params.keys.toList()..sort();
      final signatureString = sortedKeys.map((key) => '$key=${params[key]}').join('&');
      
      // Generate signature: sha1(params_string + api_secret)
      final signature = sha1.convert(utf8.encode('$signatureString$_apiSecret')).toString();

      final uri = 'https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload';
      
      final formData = FormData.fromMap({
        'api_key': _apiKey,
        'timestamp': timestamp.toString(),
        'signature': signature,
        if (folder != null) 'folder': folder,
        'file': MultipartFile.fromBytes(
          await file.readAsBytes(),
          filename: file.name,
        ),
      });

      final response = await _dio.post(
        uri,
        data: formData,
        onSendProgress: (int sent, int total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200) {
        final secureUrl = response.data['secure_url'] as String;
        String? thumbnailUrl;
        
        // Generate thumbnail for videos
        if (resourceType == 'video') {
          // Replace extension with .jpg and optionally add transformations
          // e.g., https://res.cloudinary.com/.../video/upload/v1234/file.mp4 -> .jpg
          final lastDotIndex = secureUrl.lastIndexOf('.');
          if (lastDotIndex != -1) {
            thumbnailUrl = '${secureUrl.substring(0, lastDotIndex)}.jpg';
          }
        }
        
        return CloudinaryResponse(
          secureUrl: secureUrl,
          thumbnailUrl: thumbnailUrl,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Uploads multiple images.
  Future<List<String>> uploadMultipleImages(List<XFile> files) async {
    final urls = <String>[];
    for (final file in files) {
      final response = await uploadFile(file: file, resourceType: 'image');
      if (response != null) urls.add(response.secureUrl);
    }
    return urls;
  }
}
