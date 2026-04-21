import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.fullName,
    super.avatarUrl,
    super.status,
    super.lastSeen,
    super.latitude,
    super.longitude,
    super.calculationMethod,
    super.madhhab,
    super.is24hFormat,
    super.tasbihTotal,
    super.tasbihStreak,
    super.lastTasbihDate,
    super.tasbihHistory,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'User',
      avatarUrl: json['avatar_url'] as String?,
      status: json['status'] as String?,
      lastSeen: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      calculationMethod: json['calculation_method'] as String?,
      madhhab: json['madhhab'] as String?,
      is24hFormat: json['is_24h_format'] as bool? ?? false,
      tasbihTotal: json['tasbih_total'] as int? ?? 0,
      tasbihStreak: json['tasbih_streak'] as int? ?? 0,
      lastTasbihDate: json['last_tasbih_date'] != null 
          ? DateTime.parse(json['last_tasbih_date'] as String) 
          : null,
      tasbihHistory: Map<String, int>.from(json['tasbih_history'] as Map? ?? {}),
    );
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      fullName: entity.fullName,
      avatarUrl: entity.avatarUrl,
      status: entity.status,
      lastSeen: entity.lastSeen,
      latitude: entity.latitude,
      longitude: entity.longitude,
      calculationMethod: entity.calculationMethod,
      madhhab: entity.madhhab,
      is24hFormat: entity.is24hFormat,
      tasbihTotal: entity.tasbihTotal,
      tasbihStreak: entity.tasbihStreak,
      lastTasbihDate: entity.lastTasbihDate,
      tasbihHistory: entity.tasbihHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'status': status,
      'updated_at': lastSeen?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'calculation_method': calculationMethod,
      'madhhab': madhhab,
      'is_24h_format': is24hFormat,
      'tasbih_total': tasbihTotal,
      'tasbih_streak': tasbihStreak,
      'last_tasbih_date': lastTasbihDate?.toIso8601String(),
      'tasbih_history': tasbihHistory,
    };
  }

  ProfileEntity toEntity() => this;
}
