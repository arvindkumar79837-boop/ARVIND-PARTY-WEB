// ═══════════════════════════════════════════════════════════════════════════
// CONTROLLER: SecurityController — Web Panel Security Module State
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './security_api_service.dart';

class SecurityController extends GetxController {
  final SecurityApiService _api = Get.find<SecurityApiService>();
  var isLoading = false.obs;
  var dashboard = <String, dynamic>{}.obs;
  var fraudAlerts = <Map<String, dynamic>>[].obs;
  var bannedDevices = <Map<String, dynamic>>[].obs;
  var blockedIps = <Map<String, dynamic>>[].obs;
  var auditLogs = <Map<String, dynamic>>[].obs;
  var liveThreats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      final res = await _api.getDashboard();
      dashboard.value = Map<String, dynamic>.from(res['data'] ?? {});
    } catch (e) {
      debugPrint('Error loading security dashboard: $e');
    }
    isLoading.value = false;
  }

  Future<void> loadFraudAlerts({int page = 1, String? severity, String? status}) async {
    isLoading.value = true;
    try {
      final res = await _api.getFraudAlerts(page: page, severity: severity, status: status);
      fraudAlerts.value = List<Map<String, dynamic>>.from(res['data'] ?? []);
    } catch (e) {
      debugPrint('Error loading fraud alerts: $e');
    }
    isLoading.value = false;
  }

  Future<void> updateFraudAlert(String alertId, Map<String, dynamic> updates) async {
    try {
      await _api.updateFraudAlert(alertId, updates);
      await loadFraudAlerts();
      await loadDashboard();
      Get.snackbar('Success', 'Alert updated.', backgroundColor: Colors.green);
    } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Failed to update alert.', backgroundColor: Colors.red); }
  }

  Future<void> loadBannedDevices() async {
    isLoading.value = true;
    try {
      final res = await _api.getBannedDevices();
      bannedDevices.value = List<Map<String, dynamic>>.from(res['data'] ?? []);
    } catch (e) {
      debugPrint('Error loading banned devices: $e');
    }
    isLoading.value = false;
  }

  Future<void> banDevice(String deviceId, String reason) async {
    try {
      await _api.banDevice(deviceId: deviceId, reason: reason);
      Get.snackbar('Success', 'Device banned.', backgroundColor: Colors.green);
      await loadBannedDevices();
      await loadDashboard();
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar('Error', 'Failed to ban device.', backgroundColor: Colors.red);
    }
  }

  Future<void> unbanDevice(String deviceId) async {
    try {
      await _api.unbanDevice(deviceId);
      Get.snackbar('Success', 'Device unbanned.', backgroundColor: Colors.green);
      await loadBannedDevices();
      await loadDashboard();
    } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Failed to unban device.', backgroundColor: Colors.red); }
  }

  Future<void> loadBlockedIps() async {
    isLoading.value = true;
    try {
      final res = await _api.getBlockedIps();
      blockedIps.value = List<Map<String, dynamic>>.from(res['data'] ?? []);
    } catch (e) {
      debugPrint('Error loading blocked IPs: $e');
    }
    isLoading.value = false;
  }

  Future<void> blockIp(String ip, String reason) async {
    try {
      await _api.blockIp(ipAddress: ip, reason: reason);
      Get.snackbar('Success', 'IP blocked.', backgroundColor: Colors.green);
      await loadBlockedIps();
      await loadDashboard();
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar('Error', 'Failed to block IP.', backgroundColor: Colors.red);
    }
  }

  Future<void> unblockIp(String ipId) async {
    try {
      await _api.unblockIp(ipId);
      Get.snackbar('Success', 'IP unblocked.', backgroundColor: Colors.green);
      await loadBlockedIps();
      await loadDashboard();
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar('Error', 'Failed to unblock IP.', backgroundColor: Colors.red);
    }
  }

  Future<void> loadAuditLogs({int page = 1, String? action}) async {
    isLoading.value = true;
    try {
      final res = await _api.getAuditLogs(page: page, action: action);
      auditLogs.value = List<Map<String, dynamic>>.from(res['data'] ?? []);
    } catch (e) {
      debugPrint('Error loading audit logs: $e');
    }
    isLoading.value = false;
  }

  Future<void> loadLiveThreats() async {
    isLoading.value = true;
    try {
      final res = await _api.getLiveThreats();
      liveThreats.value = Map<String, dynamic>.from(res['data'] ?? {});
    } catch (e) {
      debugPrint('Error loading live threats: $e');
    }
    isLoading.value = false;
  }
}
