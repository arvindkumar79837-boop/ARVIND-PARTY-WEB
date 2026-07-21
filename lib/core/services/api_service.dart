// ═══════════════════════════════════════════════════════════════════════════
// SERVICE: ApiService — HTTP client for Web Panel to Node.js Backend
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'role_permission_service.dart';
import '../constants/env_config.dart';

class ApiService extends GetxService {
  final _box = GetStorage();
  final String _baseUrl;

  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? EnvConfig.apiBaseUrl;

  String? get token => _box.read('admin_token');
  set token(String? value) {
    if (value != null) {
      _box.write('admin_token', value);
    } else {
      _box.remove('admin_token');
    }
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('ApiService._parseResponse error: $e');
      return {'success': false, 'message': 'Invalid response format'};
    }
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParams, Map<String, dynamic>? query}) async {
    final params = queryParams ?? query;
    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 30));
    _checkAuth(response);
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await http.post(uri, headers: _headers, body: jsonEncode(body)).timeout(const Duration(seconds: 30));
    _checkAuth(response);
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await http.put(uri, headers: _headers, body: jsonEncode(body ?? {})).timeout(const Duration(seconds: 30));
    _checkAuth(response);
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> patch(String endpoint, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await http.patch(uri, headers: _headers, body: jsonEncode(body ?? {})).timeout(const Duration(seconds: 30));
    _checkAuth(response);
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await http.delete(uri, headers: _headers).timeout(const Duration(seconds: 30));
    _checkAuth(response);
    return _parseResponse(response);
  }

  void _checkAuth(http.Response response) {
    if (response.statusCode == 401) {
      token = null;
      Get.find<RolePermissionService>().logout();
      Get.offAllNamed('/login');
    }
  }
}