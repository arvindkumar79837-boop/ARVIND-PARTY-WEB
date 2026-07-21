import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class InviteManagementView extends StatefulWidget {
  const InviteManagementView({super.key});

  @override
  State<InviteManagementView> createState() => _InviteManagementViewState();
}

class _InviteManagementViewState extends State<InviteManagementView> {
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _invites = [];
  bool _isLoading = true;
  int _totalPages = 1;
  int _currentPage = 1;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final params = <String, String>{'page': '$_currentPage', 'limit': '50'};
      if (_statusFilter != null) params['status'] = _statusFilter!;
      final response = await _apiService.get('/invites/admin/all', queryParams: params);
      if (response['success'] == true) {
        _invites = List<Map<String, dynamic>>.from(response['data'] ?? []);
        final pagination = response['pagination'] as Map<String, dynamic>?;
        if (pagination != null) {
          _totalPages = pagination['pages'] ?? 1;
        }
      }
    } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Failed to load invites', backgroundColor: Colors.red); }
    setState(() => _isLoading = false);
  }

  Future<void> _updateCommission(String inviteId) async {
    final controller = TextEditingController();
    final result = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Update Commission %'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Commission % (1-50)'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: controller.text), child: const Text('Update')),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await _apiService.put('/invites/admin/$inviteId/commission', {
          'commission_percent': int.tryParse(result) ?? 5,
        });
        Get.snackbar('Success', 'Commission updated', backgroundColor: Colors.green);
        _loadData();
      } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Failed to update', backgroundColor: Colors.red); }
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'registered': return 'Registered';
      case 'recharged': return 'Recharged';
      case 'commission_paid': return 'Paid';
      case 'expired': return 'Expired';
      default: return status ?? 'Unknown';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'registered': return Colors.blue;
      case 'recharged': return Colors.purple;
      case 'commission_paid': return Colors.green;
      case 'expired': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite & Referral Management'),
        actions: [
          DropdownButton<String?>(
            value: _statusFilter,
            hint: const Text('All Status'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Status')),
              ...['pending', 'registered', 'recharged', 'commission_paid', 'expired'].map((s) =>
                DropdownMenuItem(value: s, child: Text(_statusLabel(s))),
              ),
            ],
            onChanged: (v) {
              _statusFilter = v;
              _currentPage = 1;
              _loadData();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildStatCard('Total Invites', '${_invites.length}', Colors.blue, Icons.person_add),
                      const SizedBox(width: 16),
                      _buildStatCard('Pending', '${_invites.where((i) => i['status'] == 'pending').length}', Colors.orange, Icons.hourglass_empty),
                      const SizedBox(width: 16),
                      _buildStatCard('Commission Paid', '${_invites.where((i) => i['status'] == 'commission_paid').length}', Colors.green, Icons.paid),
                    ],
                  ),
                ),
                Expanded(
                  child: _invites.isEmpty
                      ? const Center(child: Text('No invites found'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _invites.length,
                          itemBuilder: (ctx, i) {
                            final inv = _invites[i];
                            final inviter = inv['inviter_id'] as Map<String, dynamic>?;
                            final invitee = inv['invitee_id'] as Map<String, dynamic>?;
                            final status = inv['status'] as String?;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _statusColor(status),
                                  child: Text(_statusLabel(status)[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                                title: Text('${inviter?['username'] ?? 'Unknown'} → ${invitee?['username'] ?? 'N/A'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Code: ${inv['invite_code'] ?? ''}'),
                                    Text('Commission: ${inv['commission_percent'] ?? 0}% | Earned: ${inv['commission_coins_earned'] ?? 0} coins'),
                                    Text('Recharge: ${inv['invitee_recharge_amount'] ?? 0} | Status: ${_statusLabel(status)}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _updateCommission(inv['_id']),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (_totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 1 ? () { _currentPage--; _loadData(); } : null,
                        ),
                        Text('Page $_currentPage of $_totalPages'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPage < _totalPages ? () { _currentPage++; _loadData(); } : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}