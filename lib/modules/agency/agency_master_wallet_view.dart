import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class AgencyMasterWalletView extends StatefulWidget {
  final String agencyId;
  final String agencyName;

  const AgencyMasterWalletView({super.key, required this.agencyId, required this.agencyName});

  @override
  State<AgencyMasterWalletView> createState() => _AgencyMasterWalletViewState();
}

class _AgencyMasterWalletViewState extends State<AgencyMasterWalletView> {
  final _apiService = Get.find<ApiService>();
  int _currentTabIndex = 0;

  Map<String, dynamic>? _ownerDashboard;
  Map<String, dynamic>? _hostDashboard;
  bool _isLoadingOwner = false;
  bool _isLoadingHost = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOwnerDashboard();
  }

  Future<void> _loadOwnerDashboard() async {
    setState(() {
      _isLoadingOwner = true;
      _errorMessage = null;
    });
    try {
      final response = await _apiService.get('/wallet/agency/owner-dashboard');
      if (response['success'] == true) {
        setState(() {
          _ownerDashboard = response['data'] as Map<String, dynamic>?;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load dashboard';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading dashboard: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingOwner = false;
      });
    }
  }

  Future<void> _loadHostDashboard() async {
    setState(() {
      _isLoadingHost = true;
      _errorMessage = null;
    });
    try {
      final response = await _apiService.get('/wallet/agency/host-dashboard');
      if (response['success'] == true) {
        setState(() {
          _hostDashboard = response['data'] as Map<String, dynamic>?;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load host dashboard';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading host dashboard: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingHost = false;
      });
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });
    if (index == 0 && _ownerDashboard == null) {
      _loadOwnerDashboard();
    } else if (index == 1 && _hostDashboard == null) {
      _loadHostDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agency Master Wallet: ${widget.agencyName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _currentTabIndex == 0 ? _loadOwnerDashboard : _loadHostDashboard,
          ),
        ],
      ),
      body: _errorMessage != null && (_currentTabIndex == 0 ? _ownerDashboard == null : _hostDashboard == null)
          ? _buildErrorWidget()
          : _buildBody(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unknown error',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _currentTabIndex == 0 ? _loadOwnerDashboard : _loadHostDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              _buildTabButton(0, 'Owner Dashboard'),
              _buildTabButton(1, 'Host Dashboard'),
            ],
          ),
        ),
        Expanded(
          child: _currentTabIndex == 0 ? _buildOwnerView() : _buildHostView(),
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isActive = _currentTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onTabChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.blue : Colors.transparent,
                width: 3,
              ),
            ),
            color: isActive ? Colors.blue.withValues(alpha: 0.05) : Colors.transparent,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.blue : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerView() {
    if (_isLoadingOwner) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_ownerDashboard == null) {
      return const Center(child: Text('No owner dashboard data'));
    }

    final agency = _ownerDashboard!['agency'] as Map<String, dynamic>?;
    final hosts = _ownerDashboard!['hosts'] as List<dynamic>? ?? [];
    final currentMonth = _ownerDashboard!['currentMonth'] as Map<String, dynamic>?;
    final lastMonth = _ownerDashboard!['lastMonth'] as Map<String, dynamic>?;
    final twoMonthsAgo = _ownerDashboard!['twoMonthsAgo'] as Map<String, dynamic>?;
    final wallet = _ownerDashboard!['wallet'] as Map<String, dynamic>?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (agency != null) _buildAgencyHeaderCard(agency),
          const SizedBox(height: 24),
          _buildMonthlyTotalsCard(currentMonth, lastMonth, twoMonthsAgo),
          const SizedBox(height: 24),
          if (wallet != null) _buildWalletCard(wallet),
          const SizedBox(height: 24),
          _buildHostsPerformanceCard(hosts),
        ],
      ),
    );
  }

  Widget _buildHostView() {
    if (_isLoadingHost) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hostDashboard == null) {
      return const Center(child: Text('No host dashboard data'));
    }

    final agency = _hostDashboard!['agency'] as Map<String, dynamic>?;
    final host = _hostDashboard!['host'] as Map<String, dynamic>?;
    final currentMonth = _hostDashboard!['currentMonth'] as Map<String, dynamic>?;
    final wallet = _hostDashboard!['wallet'] as Map<String, dynamic>?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (agency != null) _buildAgencyHeaderCard(agency),
          const SizedBox(height: 24),
          if (host != null) _buildHostInfoCard(host),
          const SizedBox(height: 24),
          if (currentMonth != null) _buildHostMonthlyCard(currentMonth),
          const SizedBox(height: 24),
          if (wallet != null) _buildWalletCard(wallet),
        ],
      ),
    );
  }

  Widget _buildAgencyHeaderCard(Map<String, dynamic> agency) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.business, size: 32, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agency['name'] ?? 'Agency',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Commission Rate: ${((agency['commissionRate'] ?? 0.1) * 100).toInt()}%',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostInfoCard(Map<String, dynamic> host) {
    return Card(
      color: Colors.green.withValues(alpha: 0.05),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.green.withValues(alpha: 0.2),
                  child: Text(
                    (host['name'] ?? 'H')[0].toUpperCase(),
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        host['name'] ?? 'Host',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'UID: ${host['uid'] ?? 'N/A'}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Coins', '${host['coins'] ?? 0}', Colors.amber),
                _buildStatItem('Diamonds', '${host['diamonds'] ?? 0}', Colors.cyan),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildHostMonthlyCard(Map<String, dynamic> month) {
    final targetCoins = month['targetCoins'] ?? 0;
    final earningsDiamonds = month['earningsDiamonds'] ?? 0;
    final targetReward = month['targetReward'] ?? 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Month Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildProgressIndicator('Target Coins', targetCoins.toDouble(), 10000),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip('Earnings', '$earningsDiamonds diamonds', Colors.purple),
                _buildInfoChip('Target Reward', '\$$targetReward', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double current, double target) {
    final progress = (current / target).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${current.toInt()} / ${target.toInt()} ($percentage%)'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
          backgroundColor: Colors.grey[200],
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTotalsCard(Map<String, dynamic>? current, Map<String, dynamic>? last, Map<String, dynamic>? twoMonthsAgo) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.purple[700]),
                const SizedBox(width: 8),
                const Text(
                  'Global Agency Totals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildMonthTotalsRow('Current Month', current),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _buildMonthTotalsRow('Last Month', last),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _buildMonthTotalsRow('2 Months Ago', twoMonthsAgo),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthTotalsRow(String label, Map<String, dynamic>? month) {
    if (month == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(color: Colors.grey[600])),
      );
    }

    final targetCoins = month['totalHostTargetCoins'] ?? 0;
    final hostEarnings = month['totalHostEarningsDiamonds'] ?? 0;
    final ownerCommission = month['ownerCommissionDiamonds'] ?? 0;
    final activeHosts = month['activeHostsCount'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricItem('Target Coins', '$targetCoins')),
              Expanded(child: _buildMetricItem('Earnings', '$hostEarnings')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildMetricItem('Commission', '$ownerCommission')),
              Expanded(child: _buildMetricItem('Active Hosts', '$activeHosts')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildWalletCard(Map<String, dynamic> wallet) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Agency Wallet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildWalletMetric('Balance', wallet['balance'] ?? 0, Colors.green)),
                Expanded(child: _buildWalletMetric('Pending', wallet['pendingWithdrawal'] ?? 0, Colors.orange)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildWalletMetric('Total Earnings', wallet['totalEarnings'] ?? 0, Colors.blue)),
                Expanded(child: _buildWalletMetric('Total Withdrawn', wallet['totalWithdrawn'] ?? 0, Colors.purple)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletMetric(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildHostsPerformanceCard(List<dynamic> hosts) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.people, color: Colors.indigo),
                SizedBox(width: 8),
                Text(
                  'Hosts Performance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hosts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('No hosts found', style: TextStyle(color: Colors.grey[600])),
                ),
              )
            else
              ...hosts.map((host) => _buildHostPerformanceTile(host as Map<String, dynamic>)),
          ],
        ),
      ),
    );
  }

  Widget _buildHostPerformanceTile(Map<String, dynamic> host) {
    final earnings = host['currentMonthEarnings'] ?? 0;
    final commission = host['currentMonthCommission'] ?? 0;
    final target = host['currentMonthTargetCoins'] ?? 0;
    final name = host['name'] ?? 'Unknown';
    final avatar = host['avatar'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar.isEmpty ? Text(name[0]) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Target: $target coins',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$earnings',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              Text(
                '+$commission',
                style: const TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }
}