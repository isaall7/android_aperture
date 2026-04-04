import 'dart:convert';

import 'package:aperturely_app/app/models/kategori_model.dart';
import 'package:aperturely_app/app/models/post_model.dart';
import 'package:aperturely_app/app/modules/utils/api.dart';
import 'package:http/http.dart' as http;

class PostService {
  final http.Client _client;

  PostService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PostModel>> fetchPosts() async {
    final response = await _client.get(
      Uri.parse(BaseUrl.posts),
      headers: BaseUrl.defaultHeaders,
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (decoded['data'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => PostModel.fromJson((item as Map).cast<String, dynamic>()))
        .toList();

    return items;
  }

  Future<PostModel> fetchPostDetail(int id) async {
    final response = await _client.get(
      Uri.parse('${BaseUrl.posts}/$id'),
      headers: BaseUrl.defaultHeaders,
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return PostModel.fromJson((decoded['data'] as Map).cast<String, dynamic>());
  }

  Future<List<KategoriModel>> fetchCategories() async {
    final response = await _client.get(
      Uri.parse(BaseUrl.categories),
      headers: BaseUrl.defaultHeaders,
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['data'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => KategoriModel.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<KategoriModel>> fetchPhotoTypes() async {
    final response = await _client.get(
      Uri.parse(BaseUrl.photoTypes),
      headers: BaseUrl.defaultHeaders,
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['data'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => KategoriModel.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<PostModel>> fetchPostsByPhotoType(int id) async {
    final response = await _client.get(
      Uri.parse(BaseUrl.postsByPhotoType(id)),
      headers: BaseUrl.defaultHeaders,
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['data'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => PostModel.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }
}
