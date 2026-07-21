// ═══════════════════════════════════════════════════════════════════════════
// VIEW: SecurityDashboardView — Owner Web Panel
// Live threat monitor with red/black theme and glowing alerts.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/role_permission_service.dart';
import './security_controller.dart';

class SecurityDashboardView extends StatefulWidget {
  final int initialTab;
  const SecurityDashboardView({super.key, this.initialTab = 0});

  @override
  State<SecurityDashboardView> createState() => _SecurityDashboardViewState();
}

class _SecurityDashboardViewState extends State<SecurityDashboardView> with SingleTickerProviderStateMixin {
  final _permService = Get.find<RolePermissionService>();
  late final SecurityController _ctrl = Get.put(SecurityController());
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTab.clamp(0, 3));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canManage = _permService.hasPermission('security.manage');
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D24),
        title: const Text('SECURITY COMMAND CENTER', style: TextStyle(color: Colors.white, fontSize: 20)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.redAccent,
          labelColor: Colors.redAccent,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'LIVE THREATS'),
            Tab(text: 'FRAUD ALERTS'),
            Tab(text: 'DEVICES & IPS'),
            Tab(text: 'AUDIT LOGS'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _ctrl.loadDashboard,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () => _tabController.index = (_tabController.index + 1) % 4,
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            tooltip: 'Next tab',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _LiveThreatsTab(),
          _FraudAlertsTab(),
          _DevicesAndIpsTab(),
          _AuditLogsTab(),
        ],
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              backgroundColor: Colors.redAccent,
              onPressed: _showQuickActionMenu,
              icon: const Icon(Icons.security),
              label: const Text('Quick Action'),
            )
          : null,
    );
  }

  void _showQuickActionMenu() {
    final controller = TextEditingController();
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D24),
        title: const Text('Quick Security Action', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Device ID or IP', labelStyle: TextStyle(color: Colors.grey)),
            ),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason', labelStyle: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isEmpty) return;
              final reason = reasonController.text.trim();
              if (value.contains('.')) {
                await _ctrl.blockIp(value, reason.isEmpty ? 'Security violation' : reason);
              } else {
                await _ctrl.banDevice(value, reason.isEmpty ? 'Violation of platform policies.' : reason);
              }
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1: LIVE THREATS
// ─────────────────────────────────────────────────────────────────────────────
class _LiveThreatsTab extends StatelessWidget {
  const _LiveThreatsTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SecurityController>();
    return RefreshIndicator(
      onRefresh: () => ctrl.loadLiveThreats(),
      child: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
        }
        final suspiciousUsers = ctrl.liveThreats['suspiciousUsers'] as List<dynamic>? ?? [];
        final criticalAlerts = ctrl.liveThreats['criticalAlerts'] as List<dynamic>? ?? [];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (criticalAlerts.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.redAccent, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('${criticalAlerts.length} CRITICAL FRAUD ALERT(S)', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              const Text('Suspicious Users', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (suspiciousUsers.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No active threats detected.', style: TextStyle(color: Colors.grey))))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: suspiciousUsers.length,
                  itemBuilder: (_, i) {
                    final user = suspiciousUsers[i] as Map<String, dynamic>;
                    final isBanned = user['isBanned'] == true;
                    final isBlocked = user['isBlocked'] == true;
                    final flags = user['suspiciousActivityCount'] ?? 0;
                    return Card(
                      color: (isBanned || isBlocked) ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.08),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(isBanned ? Icons.block : isBlocked ? Icons.pause_circle : Icons.warning, color: Colors.redAccent),
                        title: Text(user['name'] ?? user['arvindId'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                        subtitle: Text('Flagged: $flags | Status: ${isBanned ? 'BANNED' : isBlocked ? 'BLOCKED' : 'FLAGGED'}', style: const TextStyle(color: Colors.grey)),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2: FRAUD ALERTS
// ─────────────────────────────────────────────────────────────────────────────
class _FraudAlertsTab extends StatelessWidget {
  const _FraudAlertsTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SecurityController>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  value: ctrl.fraudAlerts.isEmpty ? null : 'ALL',
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('All Severity')),
                    DropdownMenuItem(value: 'CRITICAL', child: Text('CRITICAL')),
                    DropdownMenuItem(value: 'HIGH', child: Text('HIGH')),
                    DropdownMenuItem(value: 'MEDIUM', child: Text('MEDIUM')),
                    DropdownMenuItem(value: 'LOW', child: Text('LOW')),
                  ],
                  onChanged: (v) async => await ctrl.loadFraudAlerts(severity: v == 'ALL' ? null : v),
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                )),
              ),
              const SizedBox(width: 12),
              IconButton(onPressed: () => ctrl.loadFraudAlerts(), icon: const Icon(Icons.refresh, color: Colors.white)),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (ctrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
            }
            if (ctrl.fraudAlerts.isEmpty) {
              return const Center(child: Text('No fraud alerts found.', style: TextStyle(color: Colors.grey)));
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ctrl.fraudAlerts.length,
              itemBuilder: (_, i) {
                final alert = ctrl.fraudAlerts[i];
                final severity = (alert['severity'] ?? 'HIGH').toString();
                Color severityColor = Colors.orange;
                if (severity == 'CRITICAL') severityColor = Colors.redAccent;
                if (severity == 'HIGH') severityColor = Colors.deepOrange;
                if (severity == 'MEDIUM') severityColor = Colors.amber;
                return Card(
                  color: const Color(0xFF1A1D24),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ExpansionTile(
                    leading: Icon(Icons.report, color: severityColor),
                    title: Text(alert['type'] ?? 'UNKNOWN', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text(alert['description'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: Text(severity, style: TextStyle(color: severityColor, fontWeight: FontWeight.bold)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('Status: ', style: TextStyle(color: Colors.grey)),
                                Text(alert['status'] ?? 'OPEN', style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text('Amount: ', style: TextStyle(color: Colors.grey)),
                                Text('${alert['amountInvolved'] ?? 0} coins', style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Created: ${alert['createdAt'] ?? ''}', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            if (alert['status'] == 'OPEN')
                              ElevatedButton(
                                onPressed: () => _resolveAlert(alert['_id']?.toString() ?? ''),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text('Mark Resolved'),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _resolveAlert(String alertId) async {
    if (alertId.isEmpty) return;
    final ctrl = Get.find<SecurityController>();
    await ctrl.updateFraudAlert(alertId, {'status': 'RESOLVED_FRAUD', 'resolvedAt': DateTime.now().toIso8601String(), 'resolutionNote': 'Resolved by owner via web panel.'});
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3: DEVICES & IPS
// ─────────────────────────────────────────────────────────────────────────────
class _DevicesAndIpsTab extends StatelessWidget {
  const _DevicesAndIpsTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SecurityController>();
    return Column(
      children: [
        Expanded(child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.bannedDevices.length + ctrl.blockedIps.length,
            itemBuilder: (_, i) {
              if (i < ctrl.bannedDevices.length) {
                final device = ctrl.bannedDevices[i];
                return Card(
                  color: Colors.red.withValues(alpha: 0.1),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.phonelink_erase, color: Colors.redAccent),
                    title: Text('Device: ${device['deviceId']}', style: const TextStyle(color: Colors.white)),
                    subtitle: Text(device['reason'] ?? '', style: const TextStyle(color: Colors.grey)),
                    trailing: IconButton(
                      onPressed: () => ctrl.unbanDevice(device['_id'].toString()),
                      icon: const Icon(Icons.lock_open, color: Colors.green),
                      tooltip: 'Unban device',
                    ),
                  ),
                );
              }
              final ip = ctrl.blockedIps[i - ctrl.bannedDevices.length];
              return Card(
                color: Colors.orange.withValues(alpha: 0.08),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.lock, color: Colors.orange),
                  title: Text('IP: ${ip['ipAddress']}', style: const TextStyle(color: Colors.white)),
                  subtitle: Text(ip['reason'] ?? '', style: const TextStyle(color: Colors.grey)),
                  trailing: IconButton(
                    onPressed: () => ctrl.unblockIp(ip['_id'].toString()),
                    icon: const Icon(Icons.lock_open, color: Colors.green),
                    tooltip: 'Unblock IP',
                  ),
                ),
              );
            },
          );
        })),
        Padding(
          padding: const EdgeInsets.all(12),
        child: ElevatedButton.icon(
            onPressed: () => _quickBlockDialog(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            icon: const Icon(Icons.add),
            label: const Text('Add Block Rule'),
          ),
        ),
      ],
    );
  }

  void _quickBlockDialog() {
    final targetController = TextEditingController();
    final reasonController = TextEditingController();
    showDialog(
      context: Get.context!,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D24),
        title: const Text('New Block Rule', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: targetController,
              decoration: const InputDecoration(labelText: 'Device ID or IP Address', labelStyle: TextStyle(color: Colors.grey)),
            ),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason', labelStyle: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
            onPressed: () async {
              final target = targetController.text.trim();
              final reason = reasonController.text.trim();
              final ctrl = Get.find<SecurityController>();
              if (target.isEmpty) return;
              if (target.contains('.')) {
                await ctrl.blockIp(target, reason.isEmpty ? 'Security violation' : reason);
              } else {
                await ctrl.banDevice(target, reason.isEmpty ? 'Violation of platform policies.' : reason);
              }
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 4: AUDIT LOGS
// ─────────────────────────────────────────────────────────────────────────────
class _AuditLogsTab extends StatelessWidget {
  const _AuditLogsTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SecurityController>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  value: 'ALL',
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('All Actions')),
                    DropdownMenuItem(value: 'LOGIN', child: Text('LOGIN')),
                    DropdownMenuItem(value: 'LOGOUT', child: Text('LOGOUT')),
                    DropdownMenuItem(value: 'SUSPICIOUS_ACTIVITY', child: Text('SUSPICIOUS_ACTIVITY')),
                    DropdownMenuItem(value: 'USER_BANNED', child: Text('USER_BANNED')),
                    DropdownMenuItem(value: 'DEVICE_FLAGGED', child: Text('DEVICE_FLAGGED')),
                    DropdownMenuItem(value: 'INVALID_PAYMENT_CLAIM', child: Text('INVALID_PAYMENT_CLAIM')),
                  ],
                  onChanged: (v) async => await ctrl.loadAuditLogs(action: v == 'ALL' ? null : v),
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                )),
              ),
              const SizedBox(width: 12),
              IconButton(onPressed: () => ctrl.loadAuditLogs(), icon: const Icon(Icons.refresh, color: Colors.white)),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (ctrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
            }
            if (ctrl.auditLogs.isEmpty) {
              return const Center(child: Text('No audit logs found.', style: TextStyle(color: Colors.grey)));
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ctrl.auditLogs.length,
              itemBuilder: (_, i) {
                final log = ctrl.auditLogs[i];
                final action = (log['action'] ?? 'UNKNOWN').toString();
                return Card(
                  color: const Color(0xFF1A1D24),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.history, color: Colors.blueGrey),
                    title: Text(action, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${log['reason'] ?? ''}\nBy: ${log['executorUid'] ?? 'system'} | ${log['createdAt'] ?? ''}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      log['ipAddress'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}