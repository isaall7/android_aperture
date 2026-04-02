import 'package:get/get.dart';
import 'package:aperturely_app/app/modules/utils/api.dart';
import 'package:aperturely_app/app/modules/utils/api_helper.dart';

class AuthService extends GetConnect {
  @override
  void onInit() {
    httpClient.defaultContentType = 'application/json';
    httpClient.timeout = const Duration(seconds: 30);
    super.onInit();
  }

  Future<Response> login(String email, String password) {
    return post(
      BaseUrl.login,
      {'email': email, 'password': password},
      contentType: 'application/json',
      headers: BaseUrl.defaultHeaders,
    );
  }

  Future<Response> logout() {
    return post(BaseUrl.logout, {}, headers: ApiHelper.getAuthHeaders());
  }

  Future<Response> getProfile() {
    return get(BaseUrl.profile, headers: ApiHelper.getAuthHeaders());
  }
}