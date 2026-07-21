import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class CoinPricingView extends StatefulWidget {
  const CoinPricingView({super.key});

  @override
  State<CoinPricingView> createState() => _CoinPricingViewState();
}

class _CoinPricingViewState extends State<CoinPricingView> {
  final _apiService = Get.find<ApiService>();
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/recharge-plans/admin/all');
      if (response['success'] == true) {
        _plans = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (e) { debugPrint('Error: $e'); }
    setState(() => _isLoading = false);
  }

  void _showAddPlanDialog() {
    final priceController = TextEditingController();
    final coinsController = TextEditingController();
    final labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Price Tier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (₹)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.currency_rupee)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: coinsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Coins Awarded', border: OutlineInputBorder(), prefixIcon: Icon(Icons.monetization_on)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Label (optional)', border: OutlineInputBorder(), hintText: 'e.g. Best Value'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (priceController.text.isEmpty || coinsController.text.isEmpty) {
                Get.snackbar('Error', 'Fill price and coins', backgroundColor: Colors.red);
                return;
              }
              try {
                await _apiService.post('/recharge-plans/admin/create', {
                  'priceINR': int.parse(priceController.text),
                  'coinsAwarded': int.parse(coinsController.text),
                  'label': labelController.text,
                  'displayOrder': _plans.length + 1,
                });
                Get.back();
                _loadPlans();
                Get.snackbar('Success', 'Plan created', backgroundColor: Colors.green);
              } catch (e) {
                Get.snackbar('Error', 'Failed: $e', backgroundColor: Colors.red);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditPlanDialog(Map<String, dynamic> plan) {
    final coinsController = TextEditingController(text: '${plan['coinsAwarded'] ?? ''}');
    final priceController = TextEditingController(text: '${plan['priceINR'] ?? ''}');
    final labelController = TextEditingController(text: plan['label'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Plan: ₹${plan['priceINR']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (₹)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: coinsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Coins Awarded', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Label', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Active: '),
                  Switch(
                    value: plan['isActive'] ?? true,
                    onChanged: (val) {
                      plan['isActive'] = val;
                      (ctx as Element).markNeedsBuild();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.put('/recharge-plans/admin/${plan['_id']}', {
                  'priceINR': int.parse(priceController.text),
                  'coinsAwarded': int.parse(coinsController.text),
                  'label': labelController.text,
                  'isActive': plan['isActive'] ?? true,
                });
                Get.back();
                _loadPlans();
                Get.snackbar('Success', 'Plan updated', backgroundColor: Colors.green);
              } catch (e) {
                Get.snackbar('Error', 'Failed: $e', backgroundColor: Colors.red);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Pricing Control'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPlans),
          IconButton(icon: const Icon(Icons.add), tooltip: 'Add New Tier', onPressed: _showAddPlanDialog),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plans.isEmpty
              ? const Center(child: Text('No pricing tiers. Tap + to add one.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _plans.length,
                  itemBuilder: (ctx, i) {
                    final plan = _plans[i];
                    final isActive = plan['isActive'] ?? true;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isActive ? Colors.green : Colors.grey,
                          child: const Icon(Icons.currency_rupee, color: Colors.white),
                        ),
                        title: Text(
                          '₹${plan['priceINR'] ?? 0}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${plan['coinsAwarded'] ?? 0} coins',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if ((plan['label'] ?? '').isNotEmpty)
                              Text(plan['label'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(isActive ? 'Active' : 'Inactive', style: TextStyle(color: isActive ? Colors.green : Colors.grey, fontSize: 11)),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditPlanDialog(plan),
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
