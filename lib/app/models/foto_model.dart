import 'package:aperturely_app/app/modules/utils/api_helper.dart';

class FotoModel {
  final int id;
  final String photo;

  const FotoModel({required this.id, required this.photo});

  String get url => ApiHelper.getImageUrl(photo);

  factory FotoModel.fromJson(Map<String, dynamic> j) =>
      FotoModel(
        id: (j['id'] as num?)?.toInt() ?? 0,
        photo: (j['photo'] ?? '').toString(),
      );
}
