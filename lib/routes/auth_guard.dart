import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/services/role_permission_service.dart';
import 'app_routes.dart';

class AuthGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = GetStorage();
    final token = storage.read('admin_token');
    final isLoggedIn = token != null && token.toString().isNotEmpty;

    // Not logged in → redirect to login (preserve intended destination)
    if (!isLoggedIn && route != AppRoutes.login && route != null) {
      // Store intended route so login can redirect after successful auth
      storage.write('redirect_after_login', route);
      return const RouteSettings(name: AppRoutes.login);
    }

    // Logged in but hitting login page → redirect to dashboard
    if (isLoggedIn && route == AppRoutes.login) {
      // Check if there's a saved redirect destination
      final savedRedirect = storage.read<String>('redirect_after_login');
      storage.remove('redirect_after_login');
      if (savedRedirect != null && savedRedirect != AppRoutes.login) {
        return RouteSettings(name: savedRedirect);
      }
      return const RouteSettings(name: AppRoutes.dashboard);
    }

    // Logged in → check route permissions
    if (isLoggedIn && route != null) {
      final permService = Get.find<RolePermissionService>();
      if (!permService.hasPermissionForRoute(route)) {
        return const RouteSettings(name: AppRoutes.dashboard);
      }
    }

    return null;
  }
}
