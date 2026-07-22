import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/web_theme.dart';

class MonitoringDashboardView extends StatefulWidget {
  const MonitoringDashboardView({super.key});

  @override
  State<MonitoringDashboardView> createState() => _MonitoringDashboardViewState();
}

class _MonitoringDashboardViewState extends State<MonitoringDashboardView> {
  final ApiService _apiService = Get.put(ApiService());
  bool _isLoading = true;
  Map<String, dynamic>? _healthData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
    _startAutoRefresh();
  }

  Future<void> _loadHealthData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final healthResponse = await _apiService.get('/health/detailed');

      setState(() {
        _healthData = healthResponse['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadHealthData();
        _startAutoRefresh();
      }
    });
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorWidget()
                : _buildDashboard(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load health data',
                style: Get.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(_error ?? 'Unknown error', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadHealthData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final services = _healthData?['services'] as Map<String, dynamic>?;
    final checks = _healthData?['checks'] as List<dynamic>?;
    final system = services?['system'] as Map<String, dynamic>?;

    return RefreshIndicator(
      onRefresh: _loadHealthData,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatusCard(),
          const SizedBox(height: 24),
          if (system != null) _buildSystemMetricsCard(system),
          const SizedBox(height: 24),
          _buildServicesGrid(services),
          const SizedBox(height: 24),
          _buildHealthChecksCard(checks),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(backgroundColor: Colors.white24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'Server Health & Monitoring',
            style: Get.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        IconButton(
          onPressed: _loadHealthData,
          icon: const Icon(Icons.refresh),
          style: IconButton.styleFrom(backgroundColor: Colors.white24),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final status = _healthData?['status'] ?? 'unknown';
    final uptime = _healthData?['uptime'] ?? 0;
    final responseTime = _healthData?['responseTime'] ?? 'N/A';

    Color statusColor;
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'healthy':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'degraded':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'unhealthy':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(statusIcon, size: 48, color: statusColor),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Status',
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildMetricChip('Uptime', _formatUptime(uptime)),
                const SizedBox(height: 8),
                _buildMetricChip('Response', responseTime),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMetricsCard(Map<String, dynamic> system) {
    final memory = system['memory'] as Map<String, dynamic>?;
    final cpu = system['cpu'] as Map<String, dynamic>?;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Resources',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (memory != null) _buildProgressIndicator(
              'Memory Usage',
              '${memory['percentage']}%',
              memory['percentage'] / 100,
              memory['percentage'] > 85 ? Colors.red : memory['percentage'] > 75 ? Colors.orange : Colors.green,
            ),
            const SizedBox(height: 16),
            if (cpu != null) _buildProgressIndicator(
              'CPU Usage',
              '${cpu['usage']?.toStringAsFixed(1)}%',
              (cpu['usage'] ?? 0) / 100,
              (cpu['usage'] ?? 0) > 80 ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    'Cores',
                    '${cpu?['cores'] ?? 'N/A'}',
                    Icons.memory,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoChip(
                    'Total RAM',
                    '${memory?['total'] ?? 'N/A'} MB',
                    Icons.storage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesGrid(Map<String, dynamic>? services) {
    if (services == null) return const SizedBox.shrink();

    final serviceItems = <Widget>[];

    if (services.containsKey('database')) {
      serviceItems.add(_buildServiceCard(
        'Database',
        services['database']['connected'] == true ? 'Connected' : 'Disconnected',
        services['database']['connected'] == true ? Colors.green : Colors.red,
        Icons.storage,
      ));
    }

    if (services.containsKey('redis')) {
      serviceItems.add(_buildServiceCard(
        'Redis Cache',
        services['redis']['connected'] == true ? 'Connected' : 'Disconnected',
        services['redis']['connected'] == true ? Colors.green : Colors.red,
        Icons.speed,
      ));
    }

    if (services.containsKey('queue')) {
      serviceItems.add(_buildServiceCard(
        'Queue Service',
        services['queue']['healthy'] == true ? 'Healthy' : 'Degraded',
        services['queue']['healthy'] == true ? Colors.green : Colors.orange,
        Icons.queue,
      ));
    }

    if (services.containsKey('websocket')) {
      serviceItems.add(_buildServiceCard(
        'WebSocket',
        '${services['websocket']['activeConnections'] ?? 0} connections',
        Colors.blue,
        Icons.cable,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services Status',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: serviceItems,
        ),
      ],
    );
  }

  Widget _buildHealthChecksCard(List<dynamic>? checks) {
    if (checks == null || checks.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Checks',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...checks.map((check) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    check['status'] == 'pass'
                        ? Icons.check_circle
                        : check['status'] == 'warning'
                            ? Icons.warning
                            : Icons.error,
                    color: check['status'] == 'pass'
                        ? Colors.green
                        : check['status'] == 'warning'
                            ? Colors.orange
                            : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      check['name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    check['message'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(String title, String status, Color statusColor, IconData icon) {
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (days > 0) return '${days}d ${hours}h';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  @override
  void dispose() {
    super.dispose();
  }
}