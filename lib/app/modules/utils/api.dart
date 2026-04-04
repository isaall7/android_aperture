import 'dart:io';

import 'package:flutter/foundation.dart';

class BaseUrl {
  static const String _definedBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _androidEmulatorBase = 'http://10.0.2.2:8000';
  static const String _localNetworkBase = 'http://10.197.75.64:8000';

  static String get base {
    if (_definedBase.isNotEmpty) return _definedBase;
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (Platform.isAndroid) return _androidEmulatorBase;
    return 'http://127.0.0.1:8000';
  }

  static String get localNetworkBase => _localNetworkBase;
  static String get androidEmulatorBase => _androidEmulatorBase;

  static String get login => '$base/api/login';
  static String get register => '$base/api/register';
  static String get logout => '$base/api/logout';
  static String get profile => '$base/api/user';
  static String get posts => '$base/api/posts';
  static String get categories => '$base/api/kategori';
  static String get photoTypes => '$base/api/tipe-foto';
  static String postsByPhotoType(int id) => '$base/api/tipe-foto/$id/posts';
  static String get storageUrl => '$base/storage';

  static Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
