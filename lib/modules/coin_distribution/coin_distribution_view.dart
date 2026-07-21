import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/auth_controller.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/web_theme.dart';

class CoinDistributionView extends StatefulWidget {
  const CoinDistributionView({super.key});

  @override
  State<CoinDistributionView> createState() => _CoinDistributionViewState();
}

class _CoinDistributionViewState extends State<CoinDistributionView> {
  final _apiService = Get.find<ApiService>();
  final _authController = Get.find<AuthController>();
  List<Map<String, dynamic>> _recentTxns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/wallet/wallet/transactions', queryParams: {'limit': 20});
      if (response['success'] == true) {
        _recentTxns = List<Map<String, dynamic>>.from(response['data']['transactions'] ?? []);
      }
    } catch (e) { debugPrint('Error: $e'); }
    setState(() => _isLoading = false);
  }

  void _showGenerateDialog() {
    final uidController = TextEditingController();
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    Map<String, dynamic>? searchResult;
    bool isSearching = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Generate & Send Coins'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: uidController,
                        decoration: const InputDecoration(
                          labelText: 'Target UID',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: isSearching
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.search),
                      onPressed: isSearching ? null : () async {
                        if (uidController.text.trim().isEmpty) return;
                        setDialogState(() => isSearching = true);
                        try {
                          final response = await _apiService.get('/staff/search', queryParams: {'query': uidController.text.trim()});
                          if (response['success'] == true && response['data'] != null) {
                            final results = response['data'];
                            if (results is List && results.isNotEmpty) {
                              searchResult = Map<String, dynamic>.from(results[0]);
                            } else if (results is Map) {
                              searchResult = Map<String, dynamic>.from(results);
                            }
                          } else {
                            Get.snackbar('Not Found', 'No user found', backgroundColor: Colors.orange);
                          }
                        } catch (e) {
                          Get.snackbar('Error', 'Search failed: $e', backgroundColor: Colors.red);
                        }
                        setDialogState(() => isSearching = false);
                      },
                    ),
                  ],
                ),
                if (searchResult != null) ...[
                  const SizedBox(height: 12),
                  Card(
                    color: Colors.green.withValues(alpha: 0.1),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: searchResult!['avatar'] != null ? NetworkImage(searchResult!['avatar']) : null,
                        child: searchResult!['avatar'] == null ? const Icon(Icons.person) : null,
                      ),
                      title: Text(searchResult!['name'] ?? 'Unknown'),
                      subtitle: Text('UID: ${searchResult!['uid'] ?? uidController.text}'),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Coin Amount',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monetization_on),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason (audit trail)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (amountController.text.isEmpty) {
                  Get.snackbar('Error', 'Enter coin amount', backgroundColor: Colors.red);
                  return;
                }
                try {
                  final response = await _apiService.post('/admin/wallet/generate-for-user', {
                    'uid': uidController.text.trim(),
                    'amount': int.parse(amountController.text),
                    'reason': reasonController.text.isNotEmpty ? reasonController.text : 'Owner direct credit',
                  });
                  if (response['success'] == true) {
                    Get.back();
                    Get.snackbar('Success', '${amountController.text} coins sent to ${uidController.text}', backgroundColor: Colors.green);
                    _loadHistory();
                  } else {
                    Get.snackbar('Error', response['message'] ?? 'Failed', backgroundColor: Colors.red);
                  }
                } catch (e) {
                  Get.snackbar('Error', 'Failed: $e', backgroundColor: Colors.red);
                }
              },
              child: const Text('Generate & Send'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _authController.isOwner.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Distribution'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHistory),
          if (isOwner)
            IconButton(icon: const Icon(Icons.add_circle), tooltip: 'Generate Coins', onPressed: _showGenerateDialog),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (isOwner)
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: ListTile(
                      leading: const Icon(Icons.monetization_on, color: Colors.orange, size: 40),
                      title: const Text('Generate Coins for User', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Directly credit coins to any user wallet'),
                      trailing: ElevatedButton.icon(
                        onPressed: _showGenerateDialog,
                        icon: const Icon(Icons.send),
                        label: const Text('Generate'),
                        style: ElevatedButton.styleFrom(backgroundColor: WebTheme.primaryOrange, foregroundColor: Colors.white),
                      ),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _recentTxns.isEmpty
                      ? const Center(child: Text('No transactions found'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _recentTxns.length,
                          itemBuilder: (ctx, i) {
                            final txn = _recentTxns[i];
                            final isCredit = (txn['amount'] ?? 0) > 0;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: ListTile(
                                leading: Icon(
                                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isCredit ? Colors.green : Colors.red,
                                ),
                                title: Text(txn['description'] ?? txn['type'] ?? 'Transaction'),
                                subtitle: Text('${txn['type'] ?? ''} • ${txn['createdAt'] ?? ''}'),
                                trailing: Text(
                                  '${isCredit ? '+' : ''}${txn['amount'] ?? 0}',
                                  style: TextStyle(
                                    color: isCredit ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
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
