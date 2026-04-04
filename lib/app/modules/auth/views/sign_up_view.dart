import 'package:aperturely_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:aperturely_app/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpView extends GetView<AuthController> {
  SignUpView({super.key});

  @override
  final AuthController controller = Get.put(AuthController());

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF9F7F4),
          gradient: RadialGradient(
            center: Alignment(0.9, 0.85),
            radius: 1.4,
            colors: [Color(0x120A0A0A), Color(0xFFF9F7F4)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
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
                        IconButton(
                          onPressed: Get.back,
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF9F7F4),
                          ),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Buat akun baru',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0A0A0A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Bergabung dengan komunitas fotografer Aperturely.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF888077),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _RegisterField(
                          controller: _nameController,
                          label: 'Nama Lengkap',
                          hint: 'Nama kamu',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama wajib diisi.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _RegisterField(
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
                        Row(
                          children: [
                            Expanded(
                              child: Obx(
                                () => _RegisterField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hint: 'Min. 8 karakter',
                                  obscureText:
                                      controller.isRegisterPasswordHidden.value,
                                  suffixIcon: IconButton(
                                    onPressed:
                                        controller.toggleRegisterPasswordVisibility,
                                    icon: Icon(
                                      controller.isRegisterPasswordHidden.value
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF888077),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password wajib diisi.';
                                    }
                                    if (value.length < 8) {
                                      return 'Minimal 8 karakter.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Obx(
                                () => _RegisterField(
                                  controller: _passwordConfirmationController,
                                  label: 'Konfirmasi',
                                  hint: 'Ulangi password',
                                  obscureText: controller
                                      .isRegisterConfirmationHidden.value,
                                  suffixIcon: IconButton(
                                    onPressed: controller
                                        .toggleRegisterConfirmationVisibility,
                                    icon: Icon(
                                      controller
                                              .isRegisterConfirmationHidden.value
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF888077),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value != _passwordController.text) {
                                      return 'Konfirmasi password belum sama.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () {
                                      if (_formKey.currentState?.validate() ?? false) {
                                        controller.register(
                                          name: _nameController.text.trim(),
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                          passwordConfirmation:
                                              _passwordConfirmationController.text,
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
                                  : const Text('Buat Akun'),
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
                            label: const Text('Daftar dengan Google'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Center(
                          child: Text(
                            'Dengan mendaftar kamu menyetujui syarat dan ketentuan Aperturely.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF888077),
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'Sudah punya akun?',
                                style: TextStyle(color: Color(0xFF888077)),
                              ),
                              TextButton(
                                onPressed: () => Get.offNamed(Routes.login),
                                child: const Text(
                                  'Masuk di sini',
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

class _RegisterField extends StatelessWidget {
  const _RegisterField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
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
          keyboardType: keyboardType,
          obscureText: obscureText,
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
