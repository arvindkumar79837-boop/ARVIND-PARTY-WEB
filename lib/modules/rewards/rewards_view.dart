import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class RewardsView extends StatefulWidget {
  const RewardsView({super.key});

  @override
  State<RewardsView> createState() => _RewardsViewState();
}

class _RewardsViewState extends State<RewardsView> {
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

  Future<void> _sendReward() async {
    final userId = _userIdController.text.trim();
    final amount = int.tryParse(_amountController.text) ?? 0;
    final reason = _reasonController.text.trim();

    if (userId.isEmpty || amount <= 0) {
      Get.snackbar('Error', 'User ID and valid amount are required', backgroundColor: Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _apiService.post('/admin/rewards/send', {
        'userId': userId,
        'amount': amount,
        'reason': reason.isNotEmpty ? reason : 'Admin reward',
      });
      if (response['success'] == true) {
        Get.snackbar('Success', 'Reward of $amount coins sent to $userId', backgroundColor: Colors.green);
        _userIdController.clear();
        _amountController.clear();
        _reasonController.clear();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to send reward', backgroundColor: Colors.red);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send reward', backgroundColor: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reward Injector')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send Coins to User', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _userIdController,
                      decoration: const InputDecoration(
                        labelText: 'User ID (uid)',
                        border: OutlineInputBorder(),
                        hintText: 'Enter the user UID',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Coin Amount',
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
                        hintText: 'e.g. Bonus, Compensation, Event Prize',
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _sendReward,
                        icon: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.send),
                        label: const Text('Send Reward'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _quickChip('100 Coins', 100),
                        _quickChip('500 Coins', 500),
                        _quickChip('1000 Coins', 1000),
                        _quickChip('5000 Coins', 5000),
                        _quickChip('10000 Coins', 10000),
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

  Widget _quickChip(String label, int amount) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _amountController.text = '$amount';
      },
      backgroundColor: Colors.amber.withValues(alpha: 0.1),
      side: const BorderSide(color: Colors.amber),
    );
  }
}
