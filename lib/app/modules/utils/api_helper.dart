import 'package:get_storage/get_storage.dart';
import 'api.dart';

class ApiHelper {
  static final _box = GetStorage();

  static Map<String, String> getAuthHeaders() {
    final token = _box.read('token');
    final headers = Map<String, String>.from(BaseUrl.defaultHeaders);

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static String getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '${BaseUrl.storageUrl}/$imagePath';
  }

  static bool isSuccessResponse(int? statusCode) {
    return statusCode == BaseUrl.success || statusCode == BaseUrl.created;
  }

  static String getErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized - Please login again';
      case 404:
        return 'Data not found';
      case 500:
        return 'Server error';
      default:
        return 'Something went wrong';
    }
  }
}