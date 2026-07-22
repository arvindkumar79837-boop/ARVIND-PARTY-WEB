import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class WithdrawalsView extends StatefulWidget {
  const WithdrawalsView({super.key});

  @override
  State<WithdrawalsView> createState() => _WithdrawalsViewState();
}

class _WithdrawalsViewState extends State<WithdrawalsView> {
  final _apiService = Get.find<ApiService>();
  List<Map<String, dynamic>> _withdrawals = [];
  bool _isLoading = true;
  final String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() => _isLoading = true);
    try {
      final endpoint = _statusFilter.isEmpty
          ? '/admin/withdrawals/pending'
          : '/admin/withdrawals/pending?status=$_statusFilter';
      final response = await _apiService.get(endpoint);
      if (response['success'] == true) {
        _withdrawals = List<Map<String, dynamic>>.from(response['data'] ?? response['withdrawals'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading withdrawals: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _approve(String id) async {
    try {
      await _apiService.post('/admin/withdrawals/approve/$id', {});
      Get.snackbar('Success', 'Withdrawal approved', backgroundColor: Colors.green);
      _loadPending();
    } catch (e) {
      Get.snackbar('Error', 'Approval failed', backgroundColor: Colors.red);
    }
  }

  Future<void> _reject(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reject Withdrawal'),
        content: const Text('Are you sure you want to reject this withdrawal?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _apiService.post('/admin/withdrawals/reject/$id', {});
        Get.snackbar('Success', 'Withdrawal rejected', backgroundColor: Colors.orange);
        _loadPending();
      } catch (e) {
        Get.snackbar('Error', 'Rejection failed', backgroundColor: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Withdrawals'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPending),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _withdrawals.isEmpty
              ? const Center(child: Text('No pending withdrawals'))
              : ListView.builder(
                  itemCount: _withdrawals.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (ctx, i) {
                    final w = _withdrawals[i];
                    final user = w['userId'] ?? {};
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text((user['name'] ?? 'U')[0].toUpperCase()),
                        ),
                        title: Text(user['name'] ?? 'Unknown User'),
                        subtitle: Text(
                          'Diamonds: ${w['diamondsRequested'] ?? 0} | Amount: ₹${w['amountINR'] ?? 0} | Status: ${w['status'] ?? 'PENDING'}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () => _approve(w['_id']),
                              tooltip: 'Approve',
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => _reject(w['_id']),
                              tooltip: 'Reject',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
