import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/error_handler.dart';

class WithdrawalsView extends StatefulWidget {
  const WithdrawalsView({super.key});

  @override
  State<WithdrawalsView> createState() => _WithdrawalsViewState();
}

class _WithdrawalsViewState extends State<WithdrawalsView> {
  final _apiService = Get.find<ApiService>();
  List<Map<String, dynamic>> _withdrawals = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isApproving = false;
  final String _statusFilter = '';
  int _currentPage = 1;
  static const int _pageSize = 20;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() => _isLoading = true);
    _currentPage = 1;
    _hasMoreData = true;
    try {
      final endpoint = _statusFilter.isEmpty
          ? '/admin/withdrawals/pending'
          : '/admin/withdrawals/pending?status=$_statusFilter';
      final response = await _apiService.get(endpoint, queryParams: {'page': '$_currentPage', 'limit': '$_pageSize'});
      if (response['success'] == true) {
        _withdrawals = List<Map<String, dynamic>>.from(response['data'] ?? response['withdrawals'] ?? []);
        _hasMoreData = _withdrawals.length >= _pageSize;
      }
    } catch (e) {
      Get.snackbar('Error', ErrorHandler.getMessage(e), backgroundColor: Colors.red.shade700, colorText: Colors.white);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMoreData) return;
    setState(() => _isLoadingMore = true);
    _currentPage++;
    try {
      final endpoint = _statusFilter.isEmpty
          ? '/admin/withdrawals/pending'
          : '/admin/withdrawals/pending?status=$_statusFilter';
      final response = await _apiService.get(endpoint, queryParams: {'page': '$_currentPage', 'limit': '$_pageSize'});
      if (response['success'] == true) {
        final newItems = List<Map<String, dynamic>>.from(response['data'] ?? response['withdrawals'] ?? []);
        _withdrawals.addAll(newItems);
        _hasMoreData = newItems.length >= _pageSize;
      }
    } catch (e) {
      Get.snackbar('Error', ErrorHandler.getMessage(e), backgroundColor: Colors.red.shade700, colorText: Colors.white);
    }
    setState(() => _isLoadingMore = false);
  }

  Future<void> _approve(String id, Map<String, dynamic> w) async {
    if (_isApproving) return;
    final amount = w['amountINR'] ?? 0;
    final user = w['userId'] ?? {};
    final userName = user['name'] ?? 'Unknown';
    final bankDetails = w['bankDetails'] ?? {};
    final kycStatus = w['kycStatus'] ?? 'unverified';

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Approve Withdrawal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: $userName', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Amount: ₹$amount'),
            Text('Bank: ${bankDetails['bankName'] ?? 'N/A'} - ${bankDetails['accountNumber'] ?? 'N/A'}'),
            Text('KYC Status: $kycStatus'),
            const SizedBox(height: 12),
            const Text('This action cannot be undone.', style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Approve ₹$amount'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _isApproving = true);
      try {
        await _apiService.post('/admin/withdrawals/approve/$id', {});
        Get.snackbar('Success', 'Withdrawal approved', backgroundColor: Colors.green, colorText: Colors.white);
        _loadPending();
      } catch (e) {
        Get.snackbar('Error', 'Approval failed: ${ErrorHandler.getMessage(e)}', backgroundColor: Colors.red.shade700, colorText: Colors.white);
      }
      setState(() => _isApproving = false);
    }
  }

  Future<void> _reject(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reject Withdrawal'),
        content: const Text('Are you sure you want to reject this withdrawal? This action cannot be undone.'),
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
        Get.snackbar('Success', 'Withdrawal rejected', backgroundColor: Colors.orange, colorText: Colors.white);
        _loadPending();
      } catch (e) {
        Get.snackbar('Error', 'Rejection failed: ${ErrorHandler.getMessage(e)}', backgroundColor: Colors.red.shade700, colorText: Colors.white);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Withdrawals'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _isLoading ? null : _loadPending, tooltip: 'Refresh'),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _withdrawals.isEmpty
              ? const Center(child: Text('No pending withdrawals'))
              : NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                      _loadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: _withdrawals.length + (_hasMoreData ? 1 : 0),
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (ctx, i) {
                      if (i >= _withdrawals.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final w = _withdrawals[i];
                      final user = w['userId'] ?? {};
                      final amount = w['amountINR'] ?? 0;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text((user['name'] ?? 'U')[0].toUpperCase()),
                          ),
                          title: Text(user['name'] ?? 'Unknown User'),
                          subtitle: Text(
                            'Diamonds: ${w['diamondsRequested'] ?? 0} | Amount: ₹$amount | Status: ${w['status'] ?? 'PENDING'}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: _isApproving
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.check_circle, color: Colors.green),
                                onPressed: _isApproving ? null : () => _approve(w['_id'], w),
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
                ),
    );
  }
}
