import 'package:aperturely_app/app/models/user_model.dart';

class KomentarModel {
  final int id;
  final String comment;
  final UserModel user;
  final DateTime createdAt;
  final int? replyId;
  final List<KomentarModel> replies;

  const KomentarModel({
    required this.id,
    required this.comment,
    required this.user,
    required this.createdAt,
    this.replyId,
    this.replies = const [],
  });

  factory KomentarModel.fromJson(Map<String, dynamic> j) => KomentarModel(
        id: j['id'],
        comment: j['comment'] ?? '',
        user: UserModel.fromJson(j['user']),
        createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
        replyId: j['reply_id'],
        replies: (j['replies'] as List<dynamic>? ?? [])
            .map((r) => KomentarModel.fromJson(r))
            .toList(),
      );
}