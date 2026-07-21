import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class ContentReportsView extends StatefulWidget {
  const ContentReportsView({super.key});

  @override
  State<ContentReportsView> createState() => _ContentReportsViewState();
}

class _ContentReportsViewState extends State<ContentReportsView> {
  final _apiService = Get.find<ApiService>();
  List<dynamic> _reports = [];
  bool _isLoading = true;
  String _filterStatus = 'ALL';
  int _page = 1;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final params = <String, dynamic>{'page': _page.toString(), 'limit': '20'};
      if (_filterStatus != 'ALL') params['status'] = _filterStatus;
      final res = await _apiService.get('/moderation/reports', queryParams: params);
      if (res['success'] == true) {
        _reports = List.from(res['data'] ?? []);
        _total = res['pagination']?['total'] ?? 0;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _resolveReport(String reportId, String action) async {
    try {
      final res = await _apiService.put('/moderation/resolve/$reportId', {'actionTaken': action});
      if (res['success'] == true) {
        Get.snackbar('Done', 'Report resolved');
        _loadReports();
      } else {
        Get.snackbar('Error', res['message'] ?? 'Failed');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _dismissReport(String reportId) async {
    try {
      final res = await _apiService.put('/moderation/dismiss/$reportId', {});
      if (res['success'] == true) {
        Get.snackbar('Done', 'Report dismissed');
        _loadReports();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Reports'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadReports)],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: ['ALL', 'PENDING', 'REVIEWED', 'RESOLVED', 'DISMISSED'].map((s) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(s),
                    selected: _filterStatus == s,
                    onSelected: (_) => setState(() { _filterStatus = s; _page = 1; _loadReports(); }),
                    selectedColor: Colors.orange.shade100,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reports.isEmpty
                    ? const Center(child: Text('No reports found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _reports.length,
                        itemBuilder: (context, index) => _buildReportCard(_reports[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final reporter = report['reporterId'] is Map ? report['reporterId']['username'] ?? 'Unknown' : 'Unknown';
    final reported = report['reportedUserId'] is Map ? report['reportedUserId']['username'] ?? 'Unknown' : 'Unknown';
    final status = report['status'] ?? 'PENDING';
    final statusColor = {
      'PENDING': Colors.orange, 'REVIEWED': Colors.blue, 'RESOLVED': Colors.green, 'DISMISSED': Colors.grey,
    }[status] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getReportIcon(report['contentType']), size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(child: Text('$reporter → $reported', style: const TextStyle(fontWeight: FontWeight.bold))),
                Chip(label: Text(status, style: const TextStyle(fontSize: 11)), backgroundColor: statusColor.withValues(alpha: 0.2), visualDensity: VisualDensity.compact),
              ],
            ),
            const SizedBox(height: 8),
            Text('Reason: ${report['reason'] ?? 'N/A'}', style: const TextStyle(color: Colors.grey)),
            Text('Type: ${report['contentType'] ?? 'N/A'}', style: const TextStyle(color: Colors.grey)),
            if (report['description']?.toString().isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('"${report['description']}"', style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            if (status == 'PENDING') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _actionButton('Warn', Icons.warning, Colors.orange, () => _resolveReport(report['_id'], 'WARNING')),
                  const SizedBox(width: 8),
                  _actionButton('Suspend', Icons.block, Colors.red, () => _resolveReport(report['_id'], 'ACCOUNT_SUSPENDED')),
                  const SizedBox(width: 8),
                  _actionButton('Dismiss', Icons.close, Colors.grey, () => _dismissReport(report['_id'])),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(backgroundColor: color.withValues(alpha: 0.15), foregroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
    );
  }

  IconData _getReportIcon(String? type) {
    switch (type) {
      case 'PROFILE_PHOTO': return Icons.photo;
      case 'CHAT_MESSAGE': return Icons.chat;
      case 'ROOM_THUMBNAIL': return Icons.meeting_room;
      case 'MOMENT_POST': return Icons.post_add;
      default: return Icons.report;
    }
  }
}
