import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class CoinGenerationView extends StatefulWidget {
  const CoinGenerationView({super.key});

  @override
  State<CoinGenerationView> createState() => _CoinGenerationViewState();
}

class _CoinGenerationViewState extends State<CoinGenerationView> {
  final _apiService = Get.find<ApiService>();
  bool _isLoading = false;
  final _userIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _generateCoins() async {
    final userId = _userIdController.text.trim();
    final amount = int.tryParse(_amountController.text) ?? 0;
    final reason = _reasonController.text.trim();

    if (userId.isEmpty || amount <= 0) {
      Get.snackbar('Error', 'User ID and valid amount are required', backgroundColor: Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _apiService.post('/admin/coins/generate', {
        'userId': userId,
        'amount': amount,
        'reason': reason.isNotEmpty ? reason : 'Admin coin generation',
      });
      if (response['success'] == true) {
        Get.snackbar('Success', '$amount coins generated for $userId', backgroundColor: Colors.green);
        _userIdController.clear();
        _amountController.clear();
        _reasonController.clear();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed', backgroundColor: Colors.red);
      }
    } catch (e) {
      Get.snackbar('Error', 'Coin generation failed', backgroundColor: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deductCoins() async {
    final userId = _userIdController.text.trim();
    final amount = int.tryParse(_amountController.text) ?? 0;
    final reason = _reasonController.text.trim();

    if (userId.isEmpty || amount <= 0) {
      Get.snackbar('Error', 'User ID and valid amount are required', backgroundColor: Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _apiService.post('/admin/coins/deduct', {
        'userId': userId,
        'amount': amount,
        'reason': reason.isNotEmpty ? reason : 'Admin coin deduction',
      });
      if (response['success'] == true) {
        Get.snackbar('Success', '$amount coins deducted from $userId', backgroundColor: Colors.orange);
        _userIdController.clear();
        _amountController.clear();
        _reasonController.clear();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed', backgroundColor: Colors.red);
      }
    } catch (e) {
      Get.snackbar('Error', 'Coin deduction failed', backgroundColor: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coin Generation & Deduction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Coin Operations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _userIdController,
                      decoration: const InputDecoration(
                        labelText: 'User ID (uid)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Reason (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _generateCoins,
                              icon: const Icon(Icons.add_circle),
                              label: const Text('Generate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _deductCoins,
                              icon: const Icon(Icons.remove_circle),
                              label: const Text('Deduct'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
