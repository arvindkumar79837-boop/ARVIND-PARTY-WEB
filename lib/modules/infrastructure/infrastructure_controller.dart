import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class InfrastructureController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Overall status
  final overallStatus = 'Loading...'.obs;
  final uptime = '--'.obs;
  final activeConnections = '--'.obs;
  final queueJobs = '--'.obs;

  // Services status
  final services = <String, String>{}.obs;

  // Auto Scaling
  final currentInstances = 1.obs;
  final minInstances = 1.obs;
  final maxInstances = 4.obs;
  final scaleUpCount = 0.obs;
  final scaleDownCount = 0.obs;

  // Backup
  final totalBackups = 0.obs;
  final lastBackup = Rxn<String>();

  // Errors
  final recentErrors = 0.obs;
  final criticalErrors = 0.obs;
  final errorHistory = <Map<String, dynamic>>[].obs;

  // Feature Flags
  final featureFlags = <Map<String, dynamic>>[].obs;

  // Alerts
  final activeAlerts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  Future<void> loadAllData() async {
    await Future.wait([
      loadHealthStatus(),
      loadScalingStats(),
      loadBackupHistory(),
      loadErrors(),
      loadFeatureFlags(),
      loadActiveAlerts(),
    ]);
  }

  Future<void> loadHealthStatus() async {
    try {
      final response = await _apiService.get('/infrastructure/monitoring/health');
      if (response['success'] == true) {
        final data = response['data'];
        overallStatus.value = data['status'] ?? 'unknown';

        final servicesData = data['services'] as Map<String, dynamic>?;
        if (servicesData != null) {
          services.clear();
          services['autoScaling'] = _getServiceStatus(servicesData['autoScaling']);
          services['cdn'] = _getServiceStatus(servicesData['cdn']);
          services['backup'] = _getServiceStatus(servicesData['backup']);
          services['errorReporting'] = _getServiceStatus(servicesData['errorReporting']);
          services['auditLog'] = _getServiceStatus(servicesData['auditLog']);
          services['healthAlerts'] = _getServiceStatus(servicesData['healthAlerts']);
          services['deployment'] = _getServiceStatus(servicesData['deployment']);
          services['featureFlags'] = _getServiceStatus(servicesData['featureFlags']);
        }

        final metricsResponse = await _apiService.get('/infrastructure/metrics');
        if (metricsResponse['success'] == true) {
          final metrics = metricsResponse['data']['metrics'];
          uptime.value = _formatUptime(metrics['system']['uptime'] ?? 0);
          activeConnections.value = (metrics['sockets']?['connected'] ?? 0).toString();
          final waitingJobs = metrics['queue']?['jobs']?['waiting'] ?? 0;
          final activeJobs = metrics['queue']?['jobs']?['active'] ?? 0;
          queueJobs.value = (waitingJobs + activeJobs).toString();
        }
      }
    } catch (e) {
      overallStatus.value = 'error';
      debugPrint('Failed to load health status: $e');
    }
  }

  Future<void> loadScalingStats() async {
    try {
      final response = await _apiService.get('/infrastructure/scaling/stats');
      if (response['success'] == true) {
        final data = response['data'];
        currentInstances.value = data['currentInstanceCount'] ?? 1;
        minInstances.value = data['minInstances'] ?? 1;
        maxInstances.value = data['maxInstances'] ?? 4;
        scaleUpCount.value = data['scaleUpCount'] ?? 0;
        scaleDownCount.value = data['scaleDownCount'] ?? 0;
      }
    } catch (e) {
      debugPrint('Failed to load scaling stats: $e');
    }
  }

  Future<void> loadBackupHistory() async {
    try {
      final response = await _apiService.get('/infrastructure/backup/history');
      if (response['success'] == true) {
        final data = response['data'];
        totalBackups.value = data['total'] ?? 0;
        final recent = data['recent'] as List?;
        if (recent != null && recent.isNotEmpty) {
          lastBackup.value = _formatTime(recent[0]['timestamp']);
        }
      }
    } catch (e) {
      debugPrint('Failed to load backup history: $e');
    }
  }

  Future<void> loadErrors() async {
    try {
      final response = await _apiService.get('/infrastructure/errors/stats');
      if (response['success'] == true) {
        final data = response['data'];
        recentErrors.value = data['total'] ?? 0;
        final bySeverity = data['bySeverity'] as Map<String, dynamic>?;
        criticalErrors.value = bySeverity?['critical'] ?? 0;
      }

      final historyResponse = await _apiService.get('/infrastructure/errors/recent?duration=3600000');
      if (historyResponse['success'] == true) {
        errorHistory.value = List<Map<String, dynamic>>.from(historyResponse['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Failed to load errors: $e');
    }
  }

  Future<void> loadFeatureFlags() async {
    try {
      final response = await _apiService.get('/infrastructure/feature-flags');
      if (response['success'] == true) {
        featureFlags.value = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Failed to load feature flags: $e');
    }
  }

  Future<void> loadActiveAlerts() async {
    try {
      final response = await _apiService.get('/infrastructure/alerts/active');
      if (response['success'] == true) {
        final data = response['data'];
        activeAlerts.value = List<Map<String, dynamic>>.from(data['alerts'] ?? []);
      }
    } catch (e) {
      debugPrint('Failed to load active alerts: $e');
    }
  }

  Future<void> refreshAll() async {
    await loadAllData();
  }

  Future<void> scaleUp() async {
    try {
      final response = await _apiService.post('/infrastructure/scaling/manual', {'direction': 'up'});
      if (response['success'] == true) {
        await loadScalingStats();
        Get.snackbar('Success', 'Scale up triggered');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to scale up');
    }
  }

  Future<void> scaleDown() async {
    try {
      final response = await _apiService.post('/infrastructure/scaling/manual', {'direction': 'down'});
      if (response['success'] == true) {
        await loadScalingStats();
        Get.snackbar('Success', 'Scale down triggered');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to scale down');
    }
  }

  Future<void> createBackup() async {
    try {
      Get.snackbar('Creating Backup', 'Please wait...');
      final response = await _apiService.post('/infrastructure/backup/create', {});
      if (response['success'] == true) {
        await loadBackupHistory();
        Get.snackbar('Success', 'Backup created successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create backup');
    }
  }

  Future<void> acknowledgeAlert(String alertId) async {
    try {
      await _apiService.post('/infrastructure/alerts/$alertId/acknowledge', {});
      await loadActiveAlerts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to acknowledge alert');
    }
  }

  Future<void> toggleFeatureFlag(String flagKey, bool value) async {
    try {
      await _apiService.put('/infrastructure/feature-flags/$flagKey', {'enabled': value});
      await loadFeatureFlags();
      Get.snackbar('Success', 'Feature flag updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update feature flag');
    }
  }

  String _getServiceStatus(dynamic serviceData) {
    if (serviceData == null) return 'unknown';
    if (serviceData is Map) {
      return serviceData['status'] ?? serviceData['enabled'] ?? 'unknown';
    }
    return serviceData.toString();
  }

  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (days > 0) return '${days}d ${hours}h';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  String _formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return timestamp;
    }
  }
}