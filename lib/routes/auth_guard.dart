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

    if (!isLoggedIn && route != AppRoutes.login && route != null) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (isLoggedIn && route == AppRoutes.login) {
      return const RouteSettings(name: AppRoutes.dashboard);
    }

    if (isLoggedIn && route != null) {
      final permService = Get.find<RolePermissionService>();
      if (permService.hasPermissionForRoute(route)) {
        return const RouteSettings(name: AppRoutes.dashboard);
      }
    }

    return null;
  }
}
