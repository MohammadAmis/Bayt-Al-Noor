enum ResourceType { image, document, link, video }

class ResourceEntity {
  final String id;
  final String name;
  final String url;
  final ResourceType type;
  final String size;
  final DateTime uploadedAt;
  final String uploadedBy;

  const ResourceEntity({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    required this.uploadedAt,
    required this.uploadedBy,
  });
}

class ResourceState {
  final List<ResourceEntity> resources;
  final bool isLoading;
  final String? error;
  final String? activeUploadFile; // Track current upload for dialog state

  const ResourceState({
    this.resources = const [],
    this.isLoading = false,
    this.error,
    this.activeUploadFile,
  });

  ResourceState copyWith({
    List<ResourceEntity>? resources,
    bool? isLoading,
    String? error,
    String? activeUploadFile,
  }) {
    return ResourceState(
      resources: resources ?? this.resources,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeUploadFile: activeUploadFile ?? this.activeUploadFile,
    );
  }
}