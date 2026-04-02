class UserModel {
  final int id;
  final String name;
  final String username;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
  });

  String get displayName => username.isNotEmpty ? username : name;

  String get avatarDisplay =>
      avatarUrl ??
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=e8e4df&color=888077';

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'],
        name: j['name'] ?? '',
        username: j['username'] ?? '',
        avatarUrl: j['avatar_display'],
      );
}