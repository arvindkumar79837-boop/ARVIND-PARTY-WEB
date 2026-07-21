import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/auth_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../routes/app_routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final staffIdController = TextEditingController();
  final passwordController = TextEditingController();
  final authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    staffIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebTheme.backgroundDark,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: WebTheme.backgroundLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: WebTheme.borderColor),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: WebTheme.primaryOrange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.admin_panel_settings, size: 48, color: WebTheme.primaryOrange),
                  ),
                  const SizedBox(height: 16),
                  const Text('Arvind Party', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: WebTheme.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Admin Panel', style: TextStyle(fontSize: 14, color: WebTheme.textSecondary)),
                  const SizedBox(height: 24),

                  // ── Staff Login Form ─────────────────────────────
                  TextFormField(
                    controller: staffIdController,
                    decoration: const InputDecoration(
                      labelText: 'Staff ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    style: const TextStyle(color: WebTheme.textPrimary),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Staff ID required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    style: const TextStyle(color: WebTheme.textPrimary),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password required';
                      if (v.length < 4) return 'Min 4 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: authController.isLoading.value ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WebTheme.primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: authController.isLoading.value
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )),

                  const SizedBox(height: 20),
                  Row(children: [
                    const Expanded(child: Divider(color: WebTheme.borderColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR', style: TextStyle(color: WebTheme.textSecondary, fontSize: 12)),
                    ),
                    const Expanded(child: Divider(color: WebTheme.borderColor)),
                  ]),
                  const SizedBox(height: 20),

                  // ── Owner Google Sign-In ────────────────────────
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: authController.isLoading.value ? null : _loginWithGoogle,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: WebTheme.borderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.white),
                      label: const Text('Owner — Sign in with Google', style: TextStyle(fontSize: 14, color: WebTheme.textPrimary)),
                    ),
                  )),

                  const SizedBox(height: 12),
                  const Text(
                    'Owner login requires Google account linked to Firebase.',
                    style: TextStyle(color: WebTheme.textSecondary, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),
                  Obx(() {
                    if (authController.errorMessage.value.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(authController.errorMessage.value, style: const TextStyle(color: WebTheme.errorRed, fontSize: 13)),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final staffId = staffIdController.text.trim();
    final password = passwordController.text;

    final success = await authController.login(staffId, password);

    if (success) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.snackbar('Error', authController.errorMessage.value,
        backgroundColor: Colors.redAccent, colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _loginWithGoogle() async {
    final success = await authController.loginWithGoogle();
    if (success) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.snackbar('Error', authController.errorMessage.value,
        backgroundColor: Colors.redAccent, colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
    }
  }
}
