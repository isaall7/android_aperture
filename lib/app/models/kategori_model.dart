class KategoriModel {
  final int id;
  final String name;
  final String slug;

  const KategoriModel({required this.id, required this.name, required this.slug});

  factory KategoriModel.fromJson(Map<String, dynamic> j) =>
      KategoriModel(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: (j['name'] ?? '').toString(),
        slug: (j['slug'] ?? '').toString(),
      );
}
