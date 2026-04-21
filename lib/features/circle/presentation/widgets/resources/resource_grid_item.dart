import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../states/resource_state.dart';

class ResourceGridItem extends StatelessWidget {
  final ResourceEntity resource;
  final VoidCallback onTap;

  const ResourceGridItem({super.key, required this.resource, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: resource.type == ResourceType.image
                  ? CachedNetworkImage(
                      imageUrl: resource.url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                    )
                  : _buildDocumentIcon(),
            ),
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  resource.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentIcon() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file, size: 40, color: Colors.red[400]),
          const SizedBox(height: 4),
          Text(resource.type.name.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }
}