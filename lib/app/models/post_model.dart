import 'kategori_model.dart';
import 'komentar_model.dart';
import 'foto_model.dart';
import 'user_model.dart';

class PostModel {
  final int id;
  final String? caption;
  final UserModel user;
  final List<FotoModel> photos;
  final KategoriModel? kategori;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final List<KomentarModel> comments;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    this.caption,
    required this.user,
    required this.photos,
    this.kategori,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.comments,
    required this.createdAt,
  });

  FotoModel? get firstPhoto => photos.isNotEmpty ? photos.first : null;
  bool get hasMultiPhoto => photos.length > 1;

  factory PostModel.fromJson(Map<String, dynamic> j) => PostModel(
        id: j['id'],
        caption: j['caption'],
        user: UserModel.fromJson(j['user']),
        photos: (j['photos'] as List<dynamic>? ?? [])
            .map((p) => FotoModel.fromJson(p))
            .toList(),
        kategori: j['tipe_kategori'] != null
            ? KategoriModel.fromJson(j['tipe_kategori'])
            : null,
        likesCount: j['likes_count'] ?? 0,
        commentsCount: j['comments_count'] ?? 0,
        isLiked: j['is_liked'] ?? false,
        comments: (j['comments'] as List<dynamic>? ?? [])
            .map((c) => KomentarModel.fromJson(c))
            .toList(),
        createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
      );
}