import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:arvind_party_web/modules/shared/admin_shell.dart';
import 'package:arvind_party_web/core/services/api_service.dart';

class RevenueDashboardView extends StatefulWidget {
  const RevenueDashboardView({super.key});

  @override
  State<RevenueDashboardView> createState() => _RevenueDashboardViewState();
}

class _RevenueDashboardViewState extends State<RevenueDashboardView> {
  final _api = Get.find<ApiService>();
  bool _isLoading = true;
  int _totalCoinsSold = 0;
  int _totalDiamondsWithdrawn = 0;
  int _activeSubscriptions = 0;
  double _subscriptionRevenue = 0;
  List<Map<String, dynamic>> _topSpenders = [];
  List<Map<String, dynamic>> _topHosts = [];
  List<Map<String, dynamic>> _revenueByDay = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      final resp = await _api.dio.get('/admin/revenue-dashboard');
      if (resp.data['success'] == true) {
        final data = resp.data['data'];
        _totalCoinsSold = data['totalCoinsSold'] ?? 0;
        _totalDiamondsWithdrawn = data['totalDiamondsWithdrawn'] ?? 0;
        _activeSubscriptions = data['activeSubscriptions'] ?? 0;
        _subscriptionRevenue = (data['subscriptionRevenue'] ?? 0).toDouble();
        _topSpenders = List<Map<String, dynamic>>.from(data['topSpenders'] ?? []);
        _topHosts = List<Map<String, dynamic>>.from(data['topHosts'] ?? []);
        _revenueByDay = List<Map<String, dynamic>>.from(data['revenueByDay'] ?? []);
      }
    } catch (e) { debugPrint('Error: $e'); }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Color(0xFFFF8906), size: 28),
                const SizedBox(width: 12),
                const Text('Revenue Overview', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(onPressed: _loadDashboard, icon: const Icon(Icons.refresh, color: Colors.white54)),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildStatsRow(),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildRevenueChart()),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: _buildTopSpenders()),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: _buildTopHosts()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard('🪙', 'Coins Sold', '$_totalCoinsSold', const Color(0xFFFF8906)),
        const SizedBox(width: 16),
        _buildStatCard('💎', 'Diamonds Withdrawn', '$_totalDiamondsWithdrawn', const Color(0xFF00BCD4)),
        const SizedBox(width: 16),
        _buildStatCard('👑', 'Active Subscriptions', '$_activeSubscriptions', const Color(0xFF9C27B0)),
        const SizedBox(width: 16),
        _buildStatCard('💰', 'Subscription Revenue', '₹${_subscriptionRevenue.toStringAsFixed(0)}', const Color(0xFF4CAF50)),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return _buildCard('Revenue (7 Days)', SizedBox(
      height: 220,
      child: _revenueByDay.isEmpty
          ? const Center(child: Text('No data', style: TextStyle(color: Colors.white38)))
          : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _revenueByDay.fold<double>(0, (max, d) => (d['amount'] ?? 0) > max ? (d['amount'] ?? 0).toDouble() : max) * 1.2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < _revenueByDay.length) {
                          final label = (_revenueByDay[idx]['date'] ?? '').toString();
                          return Text(label.length > 5 ? label.substring(5) : label, style: const TextStyle(color: Colors.white38, fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _revenueByDay.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: (entry.value['amount'] ?? 0).toDouble(),
                        color: const Color(0xFFFF8906),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    ));
  }

  Widget _buildTopSpenders() {
    return _buildCard('Top Spenders', SizedBox(
      height: 220,
      child: _topSpenders.isEmpty
          ? const Center(child: Text('No data', style: TextStyle(color: Colors.white38)))
          : ListView.builder(
              itemCount: _topSpenders.length.clamp(0, 5),
              itemBuilder: (ctx, i) {
                final user = _topSpenders[i];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFFFF8906).withValues(alpha: 0.2),
                    child: Text('${i + 1}', style: const TextStyle(color: Color(0xFFFF8906), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(user['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 13)),
                  trailing: Text('${user['totalSpent'] ?? 0} coins', style: const TextStyle(color: Color(0xFFFF8906), fontSize: 12)),
                );
              },
            ),
    ));
  }

  Widget _buildTopHosts() {
    return _buildCard('Top Earning Hosts', SizedBox(
      height: 220,
      child: _topHosts.isEmpty
          ? const Center(child: Text('No data', style: TextStyle(color: Colors.white38)))
          : ListView.builder(
              itemCount: _topHosts.length.clamp(0, 5),
              itemBuilder: (ctx, i) {
                final host = _topHosts[i];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                    child: Text('${i + 1}', style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(host['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 13)),
                  trailing: Text('${host['totalEarned'] ?? 0} coins', style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 12)),
                );
              },
            ),
    ));
  }

  Widget _buildCard(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}
