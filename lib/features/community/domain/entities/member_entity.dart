class MemberEntity {
  final String userId;
  final String name;
  final String? avatarUrl;
  final String role; // 'owner', 'admin', 'member'

  const MemberEntity({
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.role = 'member',
  });
}
