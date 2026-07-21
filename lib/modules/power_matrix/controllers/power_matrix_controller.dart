// ═══════════════════════════════════════════════════════════════════════════
// FILE: arvind_party_web/lib/modules/power_matrix/controllers/power_matrix_controller.dart
// ARVIND PARTY - POWER MATRIX CONTROLLER (Web Panel)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arvind_party_web/core/services/api_service.dart';
import 'package:arvind_party_web/modules/power_matrix/models/power_matrix_model.dart';

class PowerMatrixController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // ─── Power Matrix State ──────────────────────────────────────
  final Rx<PowerMatrix?> powerMatrix = Rxn<PowerMatrix?>();
  final RxList<PowerMatrixRule> rules = <PowerMatrixRule>[].obs;
  final Rx<PowerMatrixGlobalSettings> globalSettings = PowerMatrixGlobalSettings(
    ownerCanOverrideAll: true,
    adminCanOverrideVip: true,
    svipImmunityLevel: 10,
    vipImmunityLevel: 8,
    levelDifferenceRequired: 2,
  ).obs;
  final RxBool isActive = true.obs;
  final RxInt version = 1.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ─── Power Check State ──────────────────────────────────────
  final Rx<PowerCheckResult?> lastCheckResult = Rxn<PowerCheckResult?>();
  final RxString checkTargetUserId = ''.obs;
  final RxString checkAction = 'mute'.obs;

  // ─── History State ──────────────────────────────────────────
  final RxList<PowerMatrixHistory> history = <PowerMatrixHistory>[].obs;
  final RxBool isLoadingHistory = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPowerMatrix();
  }

  Future<void> fetchPowerMatrix() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _apiService.get('/rooms/power-matrix');
      if (response['success'] == true) {
        final result = PowerMatrix.fromJson(Map<String, dynamic>.from(response['data']));
        powerMatrix.value = result;
        rules.assignAll(result.rules);
        globalSettings.value = result.globalSettings;
        isActive.value = result.isActive;
        version.value = result.version;
      } else {
        errorMessage.value = 'Failed to load power matrix configuration.';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      debugPrint('[PowerMatrixController] fetchPowerMatrix error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updatePowerMatrix() async {
    if (rules.isEmpty) {
      Get.snackbar('Validation Error', 'Rules cannot be empty.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _apiService.put('/rooms/power-matrix', {
        'rules': rules.map((r) => r.toJson()).toList(),
        'globalSettings': globalSettings.value.toJson(),
      });
      
      final success = response['success'] == true;
      if (success) {
        Get.snackbar('Success', 'Power matrix updated successfully.',
            backgroundColor: Colors.greenAccent, colorText: Colors.black);
        await fetchPowerMatrix();
        return true;
      } else {
        errorMessage.value = 'Failed to update power matrix.';
        Get.snackbar('Error', 'Failed to update power matrix.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      Get.snackbar('Error', 'Update failed: ${e.toString()}',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPowerMatrix() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _apiService.post('/rooms/power-matrix/reset', {});
      final success = response['success'] == true;
      if (success) {
        Get.snackbar('Success', 'Power matrix reset to defaults.',
            backgroundColor: Colors.greenAccent, colorText: Colors.black);
        await fetchPowerMatrix();
        return true;
      } else {
        errorMessage.value = 'Failed to reset power matrix.';
        Get.snackbar('Error', 'Failed to reset power matrix.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      Get.snackbar('Error', 'Reset failed: ${e.toString()}',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkUserPower(String targetUserId, String action) async {
    if (targetUserId.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Target user ID is required.',
          backgroundColor: Colors.orangeAccent, colorText: Colors.black);
      return;
    }

    isLoading.value = true;
    lastCheckResult.value = null;
    try {
      final response = await _apiService.post('/rooms/check-power', {
        'targetUserId': targetUserId,
        'action': action,
      });
      if (response['success'] == true) {
        lastCheckResult.value = PowerCheckResult.fromJson(Map<String, dynamic>.from(response['data']));
      } else {
        Get.snackbar('Error', 'Failed to check power.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('[PowerMatrixController] checkUserPower error: $e');
      Get.snackbar('Error', 'Check failed: ${e.toString()}',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHistory() async {
    isLoadingHistory.value = true;
    try {
      final response = await _apiService.get('/rooms/power-matrix/history');
      if (response['success'] == true) {
        final List<dynamic> historyList = response['data'] ?? [];
        history.assignAll(
          historyList.map((h) => PowerMatrixHistory.fromJson(Map<String, dynamic>.from(h))).toList(),
        );
      }
    } catch (e) {
      debugPrint('[PowerMatrixController] fetchHistory error: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  void updateRule(PowerMatrixRule updatedRule) {
    final idx = rules.indexWhere((r) => r.level == updatedRule.level);
    if (idx != -1) {
      rules[idx] = updatedRule;
    } else {
      rules.add(updatedRule);
    }
    rules.sort((a, b) => b.level.compareTo(a.level));
  }

  void updateGlobalSettings(PowerMatrixGlobalSettings settings) {
    globalSettings.value = settings;
  }

  PowerMatrixRule? getRuleForLevel(int level) {
    try {
      return rules.firstWhere((rule) => rule.level == level);
    } catch (e) {
      return null;
    }
  }

  void removeRule(int level) {
    rules.removeWhere((r) => r.level == level);
  }

  List<PowerMatrixRule> getActiveRules() {
    return rules.where((rule) => rule.level > 0).toList();
  }

  List<int> getAvailableLevels() {
    return List.generate(50, (index) => index + 1);
  }

  String getPowerCheckDescription(PowerCheckResult result) {
    if (result.allowed) {
      return '${result.action.toUpperCase()} ALLOWED\nActor Level: ${result.actorLevel} (${result.actorRole})\nTarget Level: ${result.targetLevel} (${result.targetRole})\nReason: ${result.reason}';
    } else {
      return '${result.action.toUpperCase()} DENIED\nActor Level: ${result.actorLevel} (${result.actorRole})\nTarget Level: ${result.targetLevel} (${result.targetRole})\nReason: ${result.reason}';
    }
  }

  Color getPowerCheckColor(PowerCheckResult result) {
    return result.allowed ? Colors.green : Colors.red;
  }
}