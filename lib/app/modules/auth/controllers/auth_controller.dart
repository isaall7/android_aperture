import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:aperturely_app/app/routes/app_routes.dart';
import 'package:aperturely_app/app/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService api = AuthService();
  final box = GetStorage();

  RxBool isLoading = false.obs;
  RxBool isPasswordHidden = true.obs;
  RxBool isRegisterPasswordHidden = true.obs;
  RxBool isRegisterConfirmationHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordHidden.value = !isRegisterPasswordHidden.value;
  }

  void toggleRegisterConfirmationVisibility() {
    isRegisterConfirmationHidden.value = !isRegisterConfirmationHidden.value;
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading(true);
      final response = await api.login(email: email, password: password);
      final statusCode = response['statusCode'] as int?;
      final body = response['body'] as Map<String, dynamic>? ?? {};

      if (statusCode == 200) {
        final token = (body['access_token'] ?? body['token'])?.toString();
        if (token == null || token.isEmpty) {
          throw Exception('Token login tidak ditemukan.');
        }
        box.write('token', token);
        Get.offAllNamed(Routes.dashboard);

        Get.snackbar(
          'Berhasil',
          'Login berhasil. Selamat datang di Aperturely.',
          backgroundColor: const Color(0xFF0A0A0A),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'Gagal Login',
          body['message']?.toString() ?? 'Email atau password salah',
          backgroundColor: const Color(0xFFC8533A),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: const Color(0xFFC8533A),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      isLoading(true);
      final response = await api.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      final statusCode = response['statusCode'] as int?;
      final body = response['body'] as Map<String, dynamic>? ?? {};

      if (statusCode == 200 || statusCode == 201) {
        final token = (body['access_token'] ?? body['token'])?.toString();
        if (token != null && token.isNotEmpty) {
          box.write('token', token);
        }
        Get.offAllNamed(Routes.dashboard);
        Get.snackbar(
          'Akun Dibuat',
          'Registrasi berhasil. Selamat datang di Aperturely.',
          backgroundColor: const Color(0xFF0A0A0A),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final message = _extractErrorMessage(body);
      Get.snackbar(
        'Registrasi Gagal',
        message.isNotEmpty ? message : 'Periksa kembali data pendaftaran.',
        backgroundColor: const Color(0xFFC8533A),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: const Color(0xFFC8533A),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading(false);
    }
  }

  void loginWithGoogle() {
    Get.snackbar(
      'Google Login Belum Aktif',
      'Backend Laravel saat ini baru mendukung Google login lewat redirect web, belum token khusus mobile.',
      backgroundColor: const Color(0xFF0A0A0A),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }

  Future<void> logout() async {
    try {
      isLoading(true);
      final token = box.read('token');

      if (token != null) {
        await api.logout();
        box.remove('token');
      }

      box.remove('token');
      Get.offAllNamed(Routes.dashboard);

      Get.snackbar(
        'Logout',
        'Anda telah keluar dari akun.',
        backgroundColor: const Color(0xFF6B7280),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      box.remove('token');
      Get.offAllNamed(Routes.dashboard);
    } finally {
      isLoading(false);
    }
  }

  String _extractErrorMessage(Map<String, dynamic> body) {
    final directMessage = body['message']?.toString();
    if (directMessage != null && directMessage.isNotEmpty) {
      return directMessage;
    }

    final validationMessages = <String>[];
    for (final value in body.values) {
      if (value is List) {
        validationMessages.addAll(value.map((item) => item.toString()));
      } else if (value is String && value.isNotEmpty) {
        validationMessages.add(value);
      }
    }

    return validationMessages.join('\n');
  }
}
