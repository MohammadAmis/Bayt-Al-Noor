import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../viewmodels/resource_viewmodel.dart';
import '../widgets/resources/resource_grid_item.dart';
import '../widgets/resources/upload_progress_dialog.dart';

class ResourceGalleryPage extends ConsumerWidget {
  final String chatId;
  const ResourceGalleryPage({super.key, required this.chatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(resourceViewModelProvider(chatId));
    final notifier = ref.read(resourceViewModelProvider(chatId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Resources'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () => _pickAndUpload(context, notifier),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.resources.isEmpty
              ? _buildEmptyState(context, notifier)
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: state.resources.length,
                  itemBuilder: (context, index) {
                    final res = state.resources[index];
                    return ResourceGridItem(
                      resource: res,
                      onTap: () => _openResource(context, res),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ResourceViewModel notifier) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No files shared yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _pickAndUpload(context, notifier),
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Share First File'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context, ResourceViewModel notifier) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => UploadProgressDialog(
        fileName: file.name,
        progressStream: notifier.startUpload(file.path, file.name),
        onCancel: () {
          notifier.cancelUpload(file.path);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload cancelled')));
        },
      ),
    );
  }

  void _openResource(BuildContext context, dynamic res) {
    // TODO: Implement full-screen image viewer or use `open_file` package for PDFs
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening: ${res.name}')),
    );
  }
}