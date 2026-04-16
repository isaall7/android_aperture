import 'package:aperturely_app/app/modules/utils/api_helper.dart';

class UserModel {
  final int id;
  final String name;
  final String username; 
  final String? email;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    this.email,
    this.avatarUrl,
  });

  String get displayName => username.isNotEmpty ? username : name;

  String get avatarDisplay =>
      avatarUrl?.isNotEmpty == true
          ? ApiHelper.getImageUrl(avatarUrl!)
          : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&background=e8e4df&color=888077';

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: j['name'] ?? '',
        username: j['username'] ?? '',
        email: j['email']?.toString(),
        avatarUrl: (j['avatar_display'] ?? j['avatar'])?.toString(),
      );
}
