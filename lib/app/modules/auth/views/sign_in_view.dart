import 'package:aperturely_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:aperturely_app/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInView extends GetView<AuthController> {
  SignInView({super.key});

  @override
  final AuthController controller = Get.put(AuthController());

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF9F7F4),
          gradient: RadialGradient(
            center: Alignment(-0.85, -0.8),
            radius: 1.6,
            colors: [Color(0x1AC8533A), Color(0xFFF9F7F4)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x240A0A0A),
                        blurRadius: 32,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: const [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 34,
                                color: Color(0xFF0A0A0A),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Aperturely',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0A0A0A),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Photography Platform',
                                style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 1.5,
                                  color: Color(0xFF888077),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Selamat datang kembali',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0A0A0A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Masuk untuk melanjutkan ke komunitas fotografi Aperturely.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF888077),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _AuthField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'nama@email.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email wajib diisi.';
                            }
                            if (!GetUtils.isEmail(value.trim())) {
                              return 'Format email belum valid.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => _AuthField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Masukkan password',
                            obscureText: controller.isPasswordHidden.value,
                            suffixIcon: IconButton(
                              onPressed: controller.togglePasswordVisibility,
                              icon: Icon(
                                controller.isPasswordHidden.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF888077),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password wajib diisi.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () {
                                      if (_formKey.currentState?.validate() ?? false) {
                                        controller.login(
                                          _emailController.text.trim(),
                                          _passwordController.text,
                                        );
                                      }
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF0A0A0A),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Masuk'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Color(0xFFE8E4DF))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'atau',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF888077),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Color(0xFFE8E4DF))),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: controller.loginWithGoogle,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0A0A0A),
                              minimumSize: const Size.fromHeight(48),
                              side: const BorderSide(color: Color(0xFFE8E4DF), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.g_mobiledata, size: 26),
                            label: const Text('Masuk dengan Google'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'Belum punya akun?',
                                style: TextStyle(color: Color(0xFF888077)),
                              ),
                              TextButton(
                                onPressed: () => Get.toNamed(Routes.register),
                                child: const Text(
                                  'Daftar sekarang',
                                  style: TextStyle(color: Color(0xFFC8533A)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF888077)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF9F7F4),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE8E4DF), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE8E4DF), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFC8533A), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
