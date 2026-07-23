// ═══════════════════════════════════════════════════════════════════════════
// SERVICE: ApiService — HTTP client for Web Panel to Node.js Backend
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'role_permission_service.dart';
import '../constants/auth_controller.dart';
import '../constants/env_config.dart';
import '../../routes/app_routes.dart';

class ApiService extends GetxService {
  final _box = GetStorage();
  final String _baseUrl;
  late final Dio _dio;

  /// Expose Dio instance for modules that need direct Dio access
  Dio get dio => _dio;

  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? EnvConfig.apiBaseUrl {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final t = token;
        if (t != null) {
          options.headers['Authorization'] = 'Bearer $t';
        }
        final authController = _getAuthController();
        if (authController != null) {
          options.headers['X-Staff-Role'] = authController.role.value;
          options.headers['X-Staff-Id'] = authController.staffId.value;
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          token = null;
          try { Get.find<RolePermissionService>().logout(); } catch (e) { debugPrint('Logout cleanup error: $e'); }
          Get.offAllNamed(AppRoutes.login);
        }
        handler.next(error);
      },
    ));
  }

  String? get token => _box.read('admin_token');
  set token(String? value) {
    if (value != null) {
      _box.write('admin_token', value);
    } else {
      _box.remove('admin_token');
    }
  }

  Map<String, dynamic> _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message']?.toString() ?? 'Network error';
    if (statusCode == 401) {
      token = null;
      try { Get.find<RolePermissionService>().logout(); } catch (_) {}
      Get.offAllNamed(AppRoutes.login);
    }
    return {'success': false, 'message': message};
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParams, Map<String, dynamic>? query}) async {
    try {
      final params = queryParams ?? query;
      final response = await _dio.get(endpoint, queryParameters: params);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('ApiService.get error: $e');
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(endpoint, data: body);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('ApiService.post error: $e');
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, [Map<String, dynamic>? body]) async {
    try {
      final response = await _dio.put(endpoint, data: body ?? {});
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('ApiService.put error: $e');
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> patch(String endpoint, [Map<String, dynamic>? body]) async {
    try {
      final response = await _dio.patch(endpoint, data: body ?? {});
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('ApiService.patch error: $e');
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('ApiService.delete error: $e');
      return _handleDioError(e);
    }
  }

  AuthController? _getAuthController() {
    try { return Get.find<AuthController>(); } catch (_) { return null; }
  }
}