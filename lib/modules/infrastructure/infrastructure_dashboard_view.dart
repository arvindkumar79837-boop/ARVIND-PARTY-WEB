import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/web_theme.dart';
import 'infrastructure_controller.dart';

class InfrastructureDashboardView extends StatefulWidget {
  final int initialTab;
  const InfrastructureDashboardView({super.key, this.initialTab = 0});

  @override
  State<InfrastructureDashboardView> createState() => _InfrastructureDashboardViewState();
}

class _InfrastructureDashboardViewState extends State<InfrastructureDashboardView> with SingleTickerProviderStateMixin {
  final InfrastructureController _controller = Get.put(InfrastructureController());
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: widget.initialTab.clamp(0, 4));
    _controller.loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [WebTheme.backgroundDark, WebTheme.backgroundLight],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildScalingTab(),
                  _buildBackupTab(),
                  _buildErrorsTab(),
                  _buildFeatureFlagsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.white24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Infrastructure Management',
                  style: Get.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                  _controller.overallStatus.value,
                  style: TextStyle(
                    color: _getStatusColor(_controller.overallStatus.value),
                    fontWeight: FontWeight.w500,
                  ),
                )),
              ],
            ),
          ),
          IconButton(
            onPressed: _controller.refreshAll,
            icon: const Icon(Icons.refresh, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.white24),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: WebTheme.primaryOrange,
        labelColor: WebTheme.primaryOrange,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Auto Scaling'),
          Tab(text: 'Backup'),
          Tab(text: 'Errors'),
          Tab(text: 'Feature Flags'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => _buildStatusGrid()),
          const SizedBox(height: 24),
          _buildSystemMetricsCard(),
          const SizedBox(height: 24),
          _buildActiveAlertsCard(),
        ],
      ),
    );
  }

  Widget _buildStatusGrid() {
    final services = _controller.services;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _buildServiceCard('Auto Scaling', services['autoScaling'] ?? 'disabled', Icons.expand),
        _buildServiceCard('CDN', services['cdn'] ?? 'disabled', Icons.cloud),
        _buildServiceCard('Backup', services['backup'] ?? 'disabled', Icons.backup),
        _buildServiceCard('Error Reporting', services['errorReporting'] ?? 'disabled', Icons.bug_report),
        _buildServiceCard('Audit Logs', services['auditLog'] ?? 'disabled', Icons.assignment),
        _buildServiceCard('Health Alerts', services['healthAlerts'] ?? 'disabled', Icons.notifications_active),
        _buildServiceCard('Deployment', services['deployment'] ?? 'disabled', Icons.upload),
        _buildServiceCard('Feature Flags', services['featureFlags'] ?? 'disabled', Icons.flag),
      ],
    );
  }

  Widget _buildServiceCard(String title, String status, IconData icon) {
    final statusColor = _getStatusColor(status);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: statusColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMetricsCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('System Overview', style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Obx(() => Column(
              children: [
                _buildMetricRow('Server Status', _controller.overallStatus.value),
                _buildMetricRow('Uptime', _controller.uptime.value),
                _buildMetricRow('Active Connections', _controller.activeConnections.value),
                _buildMetricRow('Queue Jobs', _controller.queueJobs.value),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: WebTheme.primaryOrange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAlertsCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Alerts', style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Obx(() => Text(
                  '${_controller.activeAlerts.length}',
                  style: TextStyle(
                    color: _controller.activeAlerts.isEmpty ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (_controller.activeAlerts.isEmpty) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No active alerts', style: TextStyle(color: Colors.grey)),
                ));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _controller.activeAlerts.length,
                itemBuilder: (context, index) {
                  final alert = _controller.activeAlerts[index];
                  return ListTile(
                    leading: Icon(
                      alert['severity'] == 'critical' ? Icons.error :
                      alert['severity'] == 'error' ? Icons.warning :
                      Icons.info,
                      color: _getSeverityColor(alert['severity']),
                    ),
                    title: Text(alert['message'] ?? 'Unknown alert'),
                    subtitle: Text(_formatTime(alert['timestamp'])),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => _controller.acknowledgeAlert(alert['id']),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildScalingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Auto Scaling', style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Obx(() => Column(
                    children: [
                      _buildInfoCard('Current Instances', _controller.currentInstances.value.toString(), Icons.computer),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard('Min', _controller.minInstances.value.toString(), Icons.minimize),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard('Max', _controller.maxInstances.value.toString(), Icons.maximize),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _controller.scaleUp,
                              icon: const Icon(Icons.arrow_upward),
                              label: const Text('Scale Up'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _controller.scaleDown,
                              icon: const Icon(Icons.arrow_downward),
                              label: const Text('Scale Down'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard('Scale Ups', _controller.scaleUpCount.value.toString(), Icons.trending_up),
                      const SizedBox(height: 8),
                      _buildInfoCard('Scale Downs', _controller.scaleDownCount.value.toString(), Icons.trending_down),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Backup Management', style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: _controller.createBackup,
                        icon: const Icon(Icons.backup),
                        label: const Text('Create Backup'),
                        style: ElevatedButton.styleFrom(backgroundColor: WebTheme.primaryOrange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Obx(() => Column(
                    children: [
                      _buildInfoCard('Total Backups', _controller.totalBackups.value.toString(), Icons.storage),
                      const SizedBox(height: 16),
                      _buildInfoCard('Last Backup', _controller.lastBackup.value ?? 'Never', Icons.access_time),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Error Tracking', style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Obx(() => Column(
                    children: [
                      _buildInfoCard('Recent Errors (1h)', _controller.recentErrors.value.toString(), Icons.bug_report),
                      const SizedBox(height: 16),
                      _buildInfoCard('Critical Count', _controller.criticalErrors.value.toString(), Icons.error),
                      const SizedBox(height: 16),
                      Obx(() {
                        if (_controller.errorHistory.isEmpty) {
                          return const Center(child: Text('No recent errors'));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _controller.errorHistory.length,
                          itemBuilder: (context, index) {
                            final error = _controller.errorHistory[index];
                            return ListTile(
                              leading: Icon(
                                error['severity'] == 'critical' ? Icons.error :
                                error['severity'] == 'error' ? Icons.warning :
                                Icons.info,
                                color: _getSeverityColor(error['severity']),
                              ),
                              title: Text(error['error']?['message'] ?? 'Unknown error'),
                              subtitle: Text(_formatTime(error['timestamp'])),
                            );
                          },
                        );
                      }),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureFlagsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Feature Flags', style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Obx(() => Text(
                '${_controller.featureFlags.length} flags',
                style: const TextStyle(color: Colors.grey),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _controller.featureFlags.length,
            itemBuilder: (context, index) {
              final flag = _controller.featureFlags[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Switch(
                    value: flag['enabled'] ?? false,
                    onChanged: (value) => _controller.toggleFeatureFlag(flag['key'], value),
                  ),
                  title: Text(flag['name'] ?? flag['key']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(flag['description'] ?? ''),
                      if (flag['rolloutPercentage'] != null && flag['rolloutPercentage'] < 100)
                        Text('Rollout: ${flag['rolloutPercentage']}%', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: flag['enabled'] ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      flag['enabled'] ? 'ENABLED' : 'DISABLED',
                      style: TextStyle(
                        color: flag['enabled'] ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          )),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'enabled':
        return Colors.green;
      case 'degraded':
      case 'warning':
        return Colors.orange;
      case 'critical':
      case 'error':
      case 'disabled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'error':
        return Colors.orange;
      case 'warning':
        return Colors.yellow;
      default:
        return Colors.blue;
    }
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