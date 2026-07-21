// ═══════════════════════════════════════════════════════════════════════════
// VIEW: ReportsView — Report management and resolution
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final queryParams = <String, String>{};
      if (_filter == 'resolved') queryParams['status'] = 'resolved';
      if (_filter == 'pending') queryParams['status'] = 'pending';

      final response = await _apiService.get('/admin/reports', queryParams: queryParams);
      if (response['success'] == true) {
        _reports = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading reports: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _resolveReport(String reportId) async {
    try {
      await _apiService.post('/admin/reports/resolve/$reportId', {'status': 'resolved'});
      Get.snackbar('Success', 'Report resolved', backgroundColor: Colors.green);
      _loadReports();
    } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Failed to resolve', backgroundColor: Colors.red); }
  }

  @override
  Widget build(BuildContext context) {
    final canResolve = _permService.hasPermission('reports.resolve');

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('All')),
                    ButtonSegment(value: 'pending', label: Text('Pending')),
                    ButtonSegment(value: 'resolved', label: Text('Resolved')),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (v) { setState(() => _filter = v.first); _loadReports(); },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reports.isEmpty
                    ? const Center(child: Text('No reports found'))
                    : ListView.builder(
                        itemCount: _reports.length,
                        itemBuilder: (ctx, i) {
                          final report = _reports[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: Icon(Icons.flag, color: report['status'] == 'resolved' ? Colors.green : Colors.orange),
                              title: Text(report['type'] ?? 'Unknown type'),
                              subtitle: Text('Reporter: ${report['reporterId'] ?? ''} | ${report['createdAt'] ?? ''}'),
                              trailing: canResolve && report['status'] != 'resolved'
                                  ? ElevatedButton(onPressed: () => _resolveReport(report['_id']), child: const Text('Resolve'))
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}