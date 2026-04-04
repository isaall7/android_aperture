import 'kategori_model.dart';
import 'komentar_model.dart';
import 'foto_model.dart';
import 'user_model.dart';

class PostModel {
  final int id;
  final String? caption;
  final int? categoryId;
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
    this.categoryId,
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
        id: (j['id'] as num?)?.toInt() ?? 0,
        caption: j['caption']?.toString(),
        categoryId: (j['type_category_id'] as num?)?.toInt() ??
            (j['typeCategoryId'] as num?)?.toInt() ??
            (j['tipefoto']?['id'] as num?)?.toInt() ??
            (j['type_foto']?['id'] as num?)?.toInt() ??
            (j['tipe_kategori']?['id'] as num?)?.toInt() ??
            (j['tipeKategori']?['id'] as num?)?.toInt(),
        user: UserModel.fromJson((j['user'] as Map<String, dynamic>?) ?? {}),
        photos: (j['photos'] as List<dynamic>? ?? [])
            .map((p) => FotoModel.fromJson((p as Map).cast<String, dynamic>()))
            .toList(),
        kategori: j['tipe_kategori'] != null
            ? KategoriModel.fromJson((j['tipe_kategori'] as Map).cast<String, dynamic>())
            : j['tipeKategori'] != null
                ? KategoriModel.fromJson((j['tipeKategori'] as Map).cast<String, dynamic>())
                : j['tipefoto'] != null
                    ? KategoriModel.fromJson((j['tipefoto'] as Map).cast<String, dynamic>())
                    : j['type_foto'] != null
                        ? KategoriModel.fromJson((j['type_foto'] as Map).cast<String, dynamic>())
            : null,
        likesCount: j['likes_count'] ?? 0,
        commentsCount: j['comments_count'] ?? 0,
        isLiked: j['is_liked'] ?? false,
        comments: (j['comments'] as List<dynamic>? ?? [])
            .map((c) => KomentarModel.fromJson((c as Map).cast<String, dynamic>()))
            .toList(),
        createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
      );
}
