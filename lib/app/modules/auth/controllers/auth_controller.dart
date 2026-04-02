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

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading(true);
      final response = await api.login(email, password);

      if (response.statusCode == 200) {
        final token = response.body['token'];
        box.write('token', token);

        // Fix navigation - pake offAllNamed dengan proper route
        Get.offAllNamed(Routes.BerandaScreen);

        Get.snackbar(
          'Berhasil',
          'Login berhasil! Selamat datang di perpustakaan digital',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'Gagal Login',
          response.body['message'] ?? 'Email atau password salah',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      isLoading(true);
      final token = box.read('token');

      if (token != null) {
        await api.logout();
        box.remove('token');
      }

      // Clear semua controller yang mungkin cached
      Get.reset();

      // Navigate ke login
      Get.offAllNamed(Routes.LOGIN);

      Get.snackbar(
        'Logout',
        'Anda telah keluar dari sistem',
        backgroundColor: const Color(0xFF6B7280),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      // Tetap logout meski API gagal
      box.remove('token');
      Get.reset();
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      isLoading(false);
    }
  }
}
