import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class AgencyDashboardView extends StatefulWidget {
  final String agencyId;
  final String agencyName;

  const AgencyDashboardView({super.key, required this.agencyId, required this.agencyName});

  @override
  State<AgencyDashboardView> createState() => _AgencyDashboardViewState();
}

class _AgencyDashboardViewState extends State<AgencyDashboardView> {
  final _apiService = Get.find<ApiService>();

  Map<String, dynamic>? _analytics;
  bool _isLoading = true;
  final List<Map<String, dynamic>> _liveHosts = [];
  final List<Map<String, dynamic>> _recentGifts = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _processAttendanceData(List<Map<String, dynamic>> attendance) {
    _liveHosts.clear();
    _recentGifts.clear();

    for (final att in attendance) {
      final user = att['userId'] as Map<String, dynamic>?;
      if (user == null) continue;

      if (att['sessionStart'] != null && att['sessionEnd'] == null) {
        _liveHosts.add({
          'userId': user['_id'] ?? '',
          'name': user['name'] ?? 'Unknown',
          'avatar': user['avatar'] ?? '',
          'roomId': att['roomId'] ?? '',
          'minutes': att['totalDailyMinutes'] ?? 0,
        });
      }

      final recentGifts = att['recentGifts'] as List<dynamic>? ?? [];
      for (final gift in recentGifts) {
        _recentGifts.add(gift as Map<String, dynamic>);
      }
    }

    if (mounted) setState(() {});
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/agency/reports/realtime');
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>?;
        if (data != null && mounted) {
          setState(() => _analytics = data);
          _processAttendanceData(
            List<Map<String, dynamic>>.from(data['todayAttendance'] ?? []),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Failed to load analytics: $e', backgroundColor: Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _triggerLiveUpdate() async {
    try {
      await _apiService.get('/agency/reports/realtime');
      _loadAnalytics();
    } catch (e) {
      Get.snackbar('Error', 'Failed to refresh: $e', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agency Dashboard: ${widget.agencyName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading && _analytics == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStatsGrid(),
                  const SizedBox(height: 20),
                  _buildLiveHostsSection(),
                  const SizedBox(height: 20),
                  _buildTodayEarningsSection(),
                  const SizedBox(height: 20),
                  _buildMonthlyChartPlaceholder(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsGrid() {
    if (_analytics == null) return const SizedBox.shrink();

    final liveNow = _analytics!['liveNow'] ?? 0;
    final doneToday = _analytics!['doneToday'] ?? 0;
    final notStarted = _analytics!['notStarted'] ?? 0;
    final totalHosts = _analytics!['totalHosts'] ?? 0;
    final todayGiftValue = _analytics!['todayGiftValue'] ?? 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          title: 'Live Now',
          value: '$liveNow',
          subtitle: 'of $totalHosts hosts',
          icon: Icons.live_tv,
          color: Colors.green,
        ),
        _StatCard(
          title: 'Done Today',
          value: '$doneToday',
          subtitle: 'valid days (2h+)',
          icon: Icons.check_circle,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'Not Started',
          value: '$notStarted',
          subtitle: 'yet today',
          icon: Icons.pending,
          color: Colors.orange,
        ),
        _StatCard(
          title: 'Today Gifts',
          value: '$todayGiftValue',
          subtitle: 'diamonds',
          icon: Icons.card_giftcard,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildLiveHostsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Live Hosts Right Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_liveHosts.isNotEmpty)
                  TextButton.icon(
                    onPressed: _triggerLiveUpdate,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_liveHosts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text('No hosts live at the moment', style: TextStyle(color: Colors.grey))),
              )
            else
              ..._liveHosts.map((host) => _LiveHostTile(
                    hostName: host['name'] ?? 'Unknown',
                    avatar: host['avatar'] ?? '',
                    roomId: host['roomId'] ?? '',
                    minutes: host['minutes'] ?? 0,
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayEarningsSection() {
    if (_analytics == null) return const SizedBox.shrink();

    final totalHosts = _analytics!['totalHosts'] ?? 0;
    final doneHosts = _analytics!['doneHosts'] ?? 0;
    final monthGiftValue = _analytics!['monthGiftValue'] ?? 0;
    final agencyCommission = monthGiftValue * 0.1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Business Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'Total Hosts Online',
              value: '$totalHosts',
              color: Colors.blue,
            ),
            _SummaryRow(
              label: 'Valid Attendance Days',
              value: '$doneHosts',
              color: Colors.green,
            ),
            _SummaryRow(
              label: 'Agency Commission (Month)',
              value: '$agencyCommission diamonds',
              color: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChartPlaceholder() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Earnings Chart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Daily earnings chart will render here\n(Integrate fl_chart package)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveHostTile extends StatelessWidget {
  final String hostName;
  final String avatar;
  final String roomId;
  final int minutes;

  const _LiveHostTile({
    required this.hostName,
    required this.avatar,
    required this.roomId,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar.isEmpty ? Text(hostName[0]) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hostName, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  'Room: ${roomId.isNotEmpty ? roomId.substring(0, roomId.length.clamp(0, 8)) : "Unknown"}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.live_tv, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  '$minutes m',
                  style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}