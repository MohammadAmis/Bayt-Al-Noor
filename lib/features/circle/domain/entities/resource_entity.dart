class ResourceEntity {
  final String id;
  final String name;
  final String url;
  final String type; // 'image', 'video', 'pdf', etc.
  final String size;
  final String uploadedBy;
  final DateTime uploadedAt;

  const ResourceEntity({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    required this.uploadedBy,
    required this.uploadedAt,
  });
}
