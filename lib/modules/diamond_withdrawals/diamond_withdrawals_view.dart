import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/auth_controller.dart';

class DiamondWithdrawalsView extends StatefulWidget {
  const DiamondWithdrawalsView({super.key});

  @override
  State<DiamondWithdrawalsView> createState() => _DiamondWithdrawalsViewState();
}

class _DiamondWithdrawalsViewState extends State<DiamondWithdrawalsView> {
  final _apiService = Get.find<ApiService>();
  final _authController = Get.find<AuthController>();
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String _filterStatus = 'ALL';
  final _amountCtrl = TextEditingController();
  double _myBalance = 0;
  double _payoutRatio = 1.0;

  bool get _isOwner => _authController.isOwner.value;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (_isOwner) {
        final res = await _apiService.get('/admin/diamond-withdrawals/all');
        if (res['success'] == true) _requests = List.from(res['data'] ?? []);
      } else {
        final res = await _apiService.get('/admin/diamond-withdrawals/my-requests');
        if (res['success'] == true) _requests = List.from(res['data'] ?? []);
        final balRes = await _apiService.get('/economy/balance');
        if (balRes['success'] == true) _myBalance = (balRes['data']['diamonds'] ?? 0).toDouble();
      }
      final settingsRes = await _apiService.get('/admin/system-settings');
      if (settingsRes['success'] == true) {
        _payoutRatio = (settingsRes['data']['diamond_to_payout_ratio'] ?? 1.0).toDouble();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _requestWithdrawal() async {
    final amount = int.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Enter a valid amount');
      return;
    }
    try {
      final res = await _apiService.post('/admin/diamond-withdrawals/request', {
        'diamondsRequested': amount,
      });
      if (res['success'] == true) {
        Get.snackbar('Success', 'Withdrawal request submitted');
        _amountCtrl.clear();
        _loadData();
      } else {
        Get.snackbar('Error', res['message'] ?? 'Failed');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _action(String requestId, String action) async {
    try {
      final res = await _apiService.put('/admin/diamond-withdrawals/$requestId/$action', {});
      if (res['success'] == true) {
        Get.snackbar('Done', 'Request $action');
        _loadData();
      } else {
        Get.snackbar('Error', res['message'] ?? 'Failed');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _clearNotification(String requestId) async {
    try {
      await _apiService.put('/admin/diamond-withdrawals/$requestId/clear-notification', {});
      _loadData();
    } catch (e) { debugPrint('Error: $e'); }
  }

  List<dynamic> get _filteredRequests {
    if (_filterStatus == 'ALL') return _requests;
    return _requests.where((r) => r['status'] == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isOwner ? 'Diamond Withdrawals' : 'My Withdrawals'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!_isOwner) _buildRequestForm(),
                if (_isOwner) _buildFilters(),
                Expanded(child: _buildRequestsList()),
              ],
            ),
    );
  }

  Widget _buildRequestForm() {
    final preview = (_amountCtrl.text.isNotEmpty ? (int.tryParse(_amountCtrl.text) ?? 0) : 0) * _payoutRatio;
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Balance: ${_myBalance.toStringAsFixed(0)} diamonds', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Diamonds to withdraw', border: OutlineInputBorder()),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _requestWithdrawal, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white), child: const Text('Request')),
              ],
            ),
            if (preview > 0) ...[
              const SizedBox(height: 8),
              Text('Payout preview: ₹${preview.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: ['ALL', 'PENDING', 'APPROVED', 'PAID', 'REJECTED'].map((s) {
          final selected = _filterStatus == s;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(s),
              selected: selected,
              onSelected: (_) => setState(() => _filterStatus = s),
              selectedColor: Colors.orange.shade100,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRequestsList() {
    final items = _filteredRequests;
    if (items.isEmpty) return const Center(child: Text('No requests found'));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final r = items[index];
        final status = r['status'] ?? 'PENDING';
        final statusColor = {
          'PENDING': Colors.orange, 'APPROVED': Colors.blue, 'PAID': Colors.green, 'REJECTED': Colors.red,
        }[status] ?? Colors.grey;

        final staffName = r['staffId'] is Map ? (r['staffId']['name'] ?? r['staffId']['loginId'] ?? 'Unknown') : 'Staff';

        return Card(
          child: ListTile(
            leading: CircleAvatar(backgroundColor: statusColor.withValues(alpha: 0.2), child: Icon(Icons.diamond, color: statusColor, size: 20)),
            title: Text(_isOwner ? staffName : 'Withdrawal Request'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${r['diamondsRequested']} diamonds → ₹${r['payoutAmount']}'),
                Text('Status: $status', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
              ],
            ),
            isThreeLine: true,
            trailing: _isOwner ? _buildOwnerActions(r) : _buildStaffActions(r),
          ),
        );
      },
    );
  }

  Widget _buildOwnerActions(Map<String, dynamic> r) {
    final status = r['status'];
    if (status == 'PENDING') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => _action(r['_id'], 'approve'), tooltip: 'Approve'),
          IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => _action(r['_id'], 'reject'), tooltip: 'Reject'),
        ],
      );
    }
    if (status == 'APPROVED') {
      return IconButton(icon: const Icon(Icons.payments, color: Colors.blue), onPressed: () => _action(r['_id'], 'mark-paid'), tooltip: 'Mark Paid');
    }
    return const SizedBox.shrink();
  }

  Widget _buildStaffActions(Map<String, dynamic> r) {
    final status = r['status'];
    if ((status == 'PAID' || status == 'REJECTED') && r['notificationClearedByRequester'] != true) {
      return IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => _clearNotification(r['_id']), tooltip: 'Dismiss');
    }
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }
}
