import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/auth_controller.dart';
import '../../routes/app_routes.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _apiService = Get.find<ApiService>();
  final _authController = Get.find<AuthController>();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _apiService.get('/admin/stats');
      if (response['success'] == true) {
        _stats = Map<String, dynamic>.from(response['data'] ?? {});
      } else {
        _error = response['message'] ?? 'Failed to load dashboard';
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _authController.isOwner.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwner ? 'Owner Dashboard' : 'Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDashboard),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadDashboard, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isOwner) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.orange.shade800, Colors.deepOrange.shade600]),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Owner Control Center', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('Full access to all modules', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          children: [
                            Expanded(child: _buildStatCard('Total Users', '${_stats['totalUsers'] ?? 0}', Colors.blue, Icons.people)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStatCard('Live Rooms', '${_stats['liveRooms'] ?? 0}', Colors.red, Icons.meeting_room)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildStatCard('Revenue (₹)', '${_stats['totalRevenue'] ?? 0}', Colors.green, Icons.monetization_on)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStatCard('Active Today', '${_stats['activeToday'] ?? 0}', Colors.orange, Icons.trending_up)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildStatCard('Total Diamonds', '${_stats['totalDiamonds'] ?? 0}', Colors.cyan, Icons.diamond)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStatCard('New Today', '${_stats['newUsersToday'] ?? 0}', Colors.purple, Icons.person_add)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        if (isOwner) ...[
                          const Text('Owner Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _quickAction('Coin Pricing', Icons.price_check, AppRoutes.coinPricing),
                              _quickAction('Coin Distribution', Icons.send, AppRoutes.coinDistribution),
                              _quickAction('Gift Economy', Icons.savings, AppRoutes.giftEconomySettings),
                              _quickAction('Diamond Withdrawals', Icons.diamond, AppRoutes.diamondWithdrawals),
                              _quickAction('Agency Targets', Icons.flag, AppRoutes.agencyTargets),
                              _quickAction('Staff Invitation', Icons.people, AppRoutes.staff),
                              _quickAction('Treasury', Icons.monetization_on, AppRoutes.treasury),
                              _quickAction('Game Center', Icons.games, AppRoutes.gameCenter),
                              _quickAction('Content Reports', Icons.report, AppRoutes.contentReports),
                              _quickAction('Legal Docs', Icons.gavel, AppRoutes.legalDocuments),
                              _quickAction('Support', Icons.support_agent, AppRoutes.supportTickets),
                              _quickAction('Withdrawals', Icons.money_off, AppRoutes.withdrawals),
                              _quickAction('Broadcast', Icons.campaign, AppRoutes.broadcasts),
                            ],
                          ),
                        ] else ...[
                          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _quickAction('Users', Icons.people, AppRoutes.users),
                              _quickAction('Rooms', Icons.meeting_room, AppRoutes.rooms),
                              _quickAction('Withdrawals', Icons.money_off, AppRoutes.withdrawals),
                              _quickAction('Broadcast', Icons.campaign, AppRoutes.broadcasts),
                              _quickAction('Treasury', Icons.monetization_on, AppRoutes.treasury),
                              _quickAction('Rewards', Icons.auto_awesome, AppRoutes.rewards),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _quickAction(String label, IconData icon, String route) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () => Get.toNamed(route),
      backgroundColor: Colors.grey.withValues(alpha: 0.1),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                Icon(icon, color: color.withValues(alpha: 0.5), size: 28),
              ],
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
