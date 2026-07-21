// ═══════════════════════════════════════════════════════════════════════════
// SERVICE: SecurityApiService — HTTP client for Security Module
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class SecurityApiService extends GetxService {
  final ApiService _api;

  SecurityApiService(this._api);

  Future<Map<String, dynamic>> getDashboard() async {
    return await _api.get('/security/dashboard');
  }

  Future<Map<String, dynamic>> getFraudAlerts({int page = 1, int limit = 20, String? severity, String? status}) async {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (severity != null) params['severity'] = severity;
    if (status != null) params['status'] = status;
    return await _api.get('/security/fraud-alerts', queryParams: params);
  }

  Future<Map<String, dynamic>> updateFraudAlert(String alertId, Map<String, dynamic> body) async {
    return await _api.put('/security/fraud-alerts/$alertId', body);
  }

  Future<Map<String, dynamic>> getBannedDevices() async => await _api.get('/security/banned-devices');
  Future<Map<String, dynamic>> banDevice({required String deviceId, String reason = 'Violation of platform policies.'}) async => await _api.post('/security/banned-devices', {'deviceId': deviceId, 'reason': reason});
  Future<Map<String, dynamic>> unbanDevice(String deviceId) async => await _api.delete('/security/banned-devices/$deviceId');
  Future<Map<String, dynamic>> getBlockedIps() async => await _api.get('/security/blocked-ips');
  Future<Map<String, dynamic>> blockIp({required String ipAddress, String reason = 'Security violation', bool permanent = false}) async => await _api.post('/security/blocked-ips', {'ipAddress': ipAddress, 'reason': reason, 'isPermanent': permanent});
  Future<Map<String, dynamic>> unblockIp(String ipId) async => await _api.delete('/security/blocked-ips/$ipId');
  Future<Map<String, dynamic>> getAuditLogs({int page = 1, int limit = 50, String? action}) async {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (action != null) params['action'] = action;
    return await _api.get('/security/audit-logs', queryParams: params);
  }
  Future<Map<String, dynamic>> getLiveThreats() async => await _api.get('/security/live-threats');
}