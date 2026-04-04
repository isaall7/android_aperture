import 'dart:convert';

import 'package:aperturely_app/app/modules/utils/api.dart';
import 'package:aperturely_app/app/modules/utils/api_helper.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse(BaseUrl.login),
      headers: BaseUrl.defaultHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _client.post(
      Uri.parse(BaseUrl.register),
      headers: BaseUrl.defaultHeaders,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client.get(
      Uri.parse(BaseUrl.profile),
      headers: ApiHelper.getAuthHeaders(),
    );
    return _decodeResponse(response);
  }

  Future<void> logout() async {
    await _client.post(
      Uri.parse(BaseUrl.logout),
      headers: ApiHelper.getAuthHeaders(),
      body: jsonEncode({}),
    );
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decoded = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    return {
      'statusCode': response.statusCode,
      'body': decoded,
    };
  }
}
