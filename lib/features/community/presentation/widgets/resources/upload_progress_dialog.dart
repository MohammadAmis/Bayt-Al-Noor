import 'package:flutter/material.dart';

class UploadProgressDialog extends StatelessWidget {
  final String fileName;
  final Stream<double> progressStream;
  final VoidCallback onCancel;

  const UploadProgressDialog({
    super.key,
    required this.fileName,
    required this.progressStream,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_upload, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onCancel),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<double>(
              stream: progressStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Upload failed: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                }
                final progress = snapshot.data ?? 0.0;
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      color: Colors.blue,
                      minHeight: 6,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toInt()}% uploaded',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}