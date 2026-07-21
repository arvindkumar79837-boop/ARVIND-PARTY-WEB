import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/constants/auth_controller.dart';
import 'core/services/api_service.dart';
import 'core/services/role_permission_service.dart';
import 'core/services/socket_service.dart';
import 'core/theme/web_theme.dart';
import 'modules/auth/controllers/role_auth_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  await GetStorage.init();

  Get.put<ApiService>(ApiService(), permanent: true);
  Get.put<RolePermissionService>(RolePermissionService(), permanent: true);

  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put<RoleAuthController>(RoleAuthController(), permanent: true);
  Get.put<SocketService>(SocketService(), permanent: true);

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Arvind Party Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: WebTheme.darkTheme,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const _NotFoundPage(),
        transition: Transition.fadeIn,
      ),
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebTheme.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: WebTheme.errorRed),
            const SizedBox(height: 16),
            Text('404', style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: WebTheme.errorRed, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Page Not Found', style: TextStyle(color: WebTheme.textSecondary, fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.offAllNamed(AppRoutes.login),
              icon: const Icon(Icons.home),
              label: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
