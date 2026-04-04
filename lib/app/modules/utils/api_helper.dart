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
    if (imagePath.isEmpty) {
      return 'https://ui-avatars.com/api/?name=Aperturely&background=e8e4df&color=888077';
    }
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    final normalized =
        imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '${BaseUrl.storageUrl}/$normalized';
  }

  static bool isSuccessResponse(int? statusCode) {
    return statusCode == 200 || statusCode == 201;
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
