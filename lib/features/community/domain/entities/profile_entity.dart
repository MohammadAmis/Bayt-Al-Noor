class ProfileEntity {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? status;
  final DateTime? lastSeen;

  // Location & Settings
  final double? latitude;
  final double? longitude;
  final String? calculationMethod;
  final String? madhhab;
  final bool is24hFormat;

  // Tasbih Progress
  final int tasbihTotal;
  final int tasbihStreak;
  final DateTime? lastTasbihDate;
  final Map<String, int> tasbihHistory;

  const ProfileEntity({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.status,
    this.lastSeen,
    this.latitude,
    this.longitude,
    this.calculationMethod,
    this.madhhab,
    this.is24hFormat = false,
    this.tasbihTotal = 0,
    this.tasbihStreak = 0,
    this.lastTasbihDate,
    this.tasbihHistory = const {},
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
