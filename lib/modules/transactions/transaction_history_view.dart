// ═══════════════════════════════════════════════════════════════════════════
// VIEW: TransactionHistoryView — Full wallet ledger
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class TransactionHistoryView extends StatefulWidget {
  const TransactionHistoryView({super.key});

  @override
  State<TransactionHistoryView> createState() => _TransactionHistoryViewState();
}

class _TransactionHistoryViewState extends State<TransactionHistoryView> {
  final _apiService = Get.find<ApiService>();
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/wallet/transactions');
      if (response['success'] == true) {
        _transactions = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadDealerTransactions(String dealerUid) async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/dealer/transactions/$dealerUid');
      if (response['success'] == true) {
        _transactions = List<Map<String, dynamic>>.from(response['data']['transactions'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading dealer transactions: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const Center(child: Text('No transactions found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _transactions.length,
                  itemBuilder: (ctx, i) {
                    final tx = _transactions[i];
                    final isCredit = tx['type'] == 'credit' || tx['type'] == 'recharge' || tx['type'] == 'settlement';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: isCredit ? Colors.green : Colors.red),
                        title: Text(tx['description'] ?? 'Transaction'),
                        subtitle: Text('${tx['type'] ?? ''} | ${tx['createdAt'] ?? ''}'),
                        trailing: Text('${isCredit ? '+' : '-'}${tx['amount'] ?? 0}', style: TextStyle(color: isCredit ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
    );
  }
}