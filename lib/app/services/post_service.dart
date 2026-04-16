import 'dart:convert';

import 'package:aperturely_app/app/models/kategori_model.dart';
import 'package:aperturely_app/app/models/post_model.dart';
import 'package:aperturely_app/app/modules/utils/api.dart';
import 'package:http/http.dart' as http;

class ApiRequestException implements Exception {
  final Uri uri;
  final int statusCode;
  final String body;

  ApiRequestException({
    required this.uri,
    required this.statusCode,
    required this.body,
  });

  @override
  String toString() {
    final trimmed = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    final snippet = trimmed.length > 120 ? '${trimmed.substring(0, 120)}...' : trimmed;
    return 'Request ke $uri gagal (HTTP $statusCode)${snippet.isNotEmpty ? ': $snippet' : ''}';
  }
}

class PostService {
  final http.Client _client;

  PostService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PostModel>> fetchPosts() async {
    final uri = Uri.parse(BaseUrl.posts);
    final response = await _client.get(
      uri,
      headers: BaseUrl.defaultHeaders,
    );
    _ensureSuccess(response, uri);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (decoded['data'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => PostModel.fromJson((item as Map).cast<String, dynamic>()))
        .toList();

    return items;
  }

  Future<PostModel> fetchPostDetail(int id) async {
    final uri = Uri.parse('${BaseUrl.posts}/$id');
    final response = await _client.get(
      uri,
      headers: BaseUrl.defaultHeaders,
    );
    _ensureSuccess(response, uri);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return PostModel.fromJson((decoded['data'] as Map).cast<String, dynamic>());
  }

  Future<List<KategoriModel>> fetchCategories() async {
    final uri = Uri.parse(BaseUrl.categories);
    final response = await _client.get(
      uri,
      headers: BaseUrl.defaultHeaders,
    );
    _ensureSuccess(response, uri);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['data'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => KategoriModel.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<KategoriModel>> fetchPhotoTypes() async {
    final uri = Uri.parse(BaseUrl.photoTypes);
    final response = await _client.get(
      uri,
      headers: BaseUrl.defaultHeaders,
    );
    _ensureSuccess(response, uri);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['data'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => KategoriModel.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<PostModel>> fetchPostsByPhotoType(int id) async {
    final uri = Uri.parse(BaseUrl.postsByPhotoType(id));
    final response = await _client.get(
      uri,
      headers: BaseUrl.defaultHeaders,
    );
    _ensureSuccess(response, uri);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['data'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => PostModel.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }

  void _ensureSuccess(http.Response response, Uri uri) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw ApiRequestException(
      uri: uri,
      statusCode: response.statusCode,
      body: response.body,
    );
  }
}
