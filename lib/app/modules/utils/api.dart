class BaseUrl {
  static const String _base = 'http://192.168.0.100:8000';
  static String get base => _base;

  // Auth endpoints
  static String login = '$_base/api/login';
  static String logout = '$_base/api/logout';
  static String profile = '$_base/api/profile';
  // Storage URL untuk gambar
  static String storageUrl = '$_base/storage';

  // Headers
  static Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // Headers with auth token
  static Map<String, String> authHeaders(String token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Status codes
  static int success = 200;
  static int created = 201;
  static int badRequest = 400;
  static int unauthorized = 401;
  static int notFound = 404;
  static int serverError = 500;
}