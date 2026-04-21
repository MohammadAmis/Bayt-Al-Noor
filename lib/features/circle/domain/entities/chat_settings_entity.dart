class ChatSettingsEntity {
  final bool isMuted;
  final bool hidePreview;
  final bool readReceiptsEnabled;

  const ChatSettingsEntity({
    this.isMuted = false,
    this.hidePreview = false,
    this.readReceiptsEnabled = true,
  });

  Map<String, dynamic> toJson() => {
    'is_muted': isMuted,
    'hide_preview': hidePreview,
    'read_receipts_enabled': readReceiptsEnabled,
  };

  ChatSettingsEntity copyWith({
    bool? isMuted,
    bool? hidePreview,
    bool? readReceiptsEnabled,
  }) {
    return ChatSettingsEntity(
      isMuted: isMuted ?? this.isMuted,
      hidePreview: hidePreview ?? this.hidePreview,
      readReceiptsEnabled: readReceiptsEnabled ?? this.readReceiptsEnabled,
    );
  }
}
