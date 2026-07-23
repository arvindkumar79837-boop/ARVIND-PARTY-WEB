import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/web_theme.dart';

class AgencyTargetView extends StatefulWidget {
  const AgencyTargetView({super.key});

  @override
  State<AgencyTargetView> createState() => _AgencyTargetViewState();
}

class _AgencyTargetViewState extends State<AgencyTargetView> {
  final _apiService = Get.find<ApiService>();
  List<Map<String, dynamic>> _targets = [];
  List<Map<String, dynamic>> _agencies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final targetRes = await _apiService.get('/admin/agency-targets');
      if (targetRes['success'] == true) {
        _targets = List<Map<String, dynamic>>.from(targetRes['data'] ?? []);
      }
      try {
        final agencyRes = await _apiService.get('/agency/list');
        if (agencyRes['success'] == true) {
          _agencies = List<Map<String, dynamic>>.from(agencyRes['data'] ?? []);
        }
      } catch (e) { debugPrint('Error: $e'); }
    } catch (e) { debugPrint('Error: $e'); }
    setState(() => _isLoading = false);
  }

  void _showCreateTargetDialog() {
    String? selectedAgencyId;
    String? selectedMetric = 'COINS_SPENT';
    String? selectedDuration = 'WEEKLY';
    final amountController = TextEditingController();
    final customDaysController = TextEditingController();
    final rewardController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create Agency Target'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Agency', border: OutlineInputBorder()),
                  items: _agencies.map<DropdownMenuItem<String>>((a) => DropdownMenuItem(value: a['_id']?.toString(), child: Text(a['name'] ?? 'Unknown'))).toList(),
                  onChanged: (val) => setDialogState(() => selectedAgencyId = val),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedMetric,
                  decoration: const InputDecoration(labelText: 'Target Metric', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem<String>(value: 'COINS_SPENT', child: Text('Coins Spent')),
                    DropdownMenuItem<String>(value: 'REVENUE_USD', child: Text('Revenue (\$)')),
                  ],
                  onChanged: (val) => setDialogState(() => selectedMetric = val),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Target Amount',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(selectedMetric == 'COINS_SPENT' ? Icons.monetization_on : Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedDuration,
                  decoration: const InputDecoration(labelText: 'Duration', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem<String>(value: 'WEEKLY', child: Text('1 Week (7 days)')),
                    DropdownMenuItem<String>(value: 'MONTHLY', child: Text('1 Month (30 days)')),
                    DropdownMenuItem<String>(value: 'CUSTOM_DAYS', child: Text('Custom Days')),
                  ],
                  onChanged: (val) => setDialogState(() => selectedDuration = val),
                ),
                if (selectedDuration == 'CUSTOM_DAYS') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: customDaysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Number of Days', border: OutlineInputBorder()),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: rewardController,
                  decoration: const InputDecoration(labelText: 'Reward (optional)', border: OutlineInputBorder(), hintText: 'e.g. 5000 coins or Special Frame'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (selectedAgencyId == null || amountController.text.isEmpty) {
                  Get.snackbar('Error', 'Select agency and enter amount', backgroundColor: Colors.red);
                  return;
                }
                try {
                  final body = <String, dynamic>{
                    'agencyId': selectedAgencyId,
                    'targetType': selectedMetric,
                    'targetAmount': int.parse(amountController.text),
                    'durationType': selectedDuration,
                    'rewardType': 'custom',
                    'rewardValue': rewardController.text.isNotEmpty ? rewardController.text : null,
                  };
                  if (selectedDuration == 'CUSTOM_DAYS' && customDaysController.text.isNotEmpty) {
                    body['durationDays'] = int.parse(customDaysController.text);
                  }
                  final response = await _apiService.post('/admin/agency-targets', body);
                  if (response['success'] == true) {
                    Get.back();
                    _loadData();
                    Get.snackbar('Success', 'Target created', backgroundColor: Colors.green);
                  } else {
                    Get.snackbar('Error', response['message'] ?? 'Failed', backgroundColor: Colors.red);
                  }
                } catch (e) {
                  Get.snackbar('Error', 'Failed: $e', backgroundColor: Colors.red);
                }
              },
              child: const Text('Create Target'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'ACTIVE': return Colors.blue;
      case 'COMPLETED': return Colors.green;
      case 'FAILED': return Colors.red;
      case 'EXPIRED': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agency Targets'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(icon: const Icon(Icons.add), tooltip: 'Create Target', onPressed: _showCreateTargetDialog),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _targets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flag, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No agency targets yet', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _showCreateTargetDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Create First Target'),
                        style: ElevatedButton.styleFrom(backgroundColor: WebTheme.primaryOrange, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _targets.length,
                  itemBuilder: (ctx, i) {
                    final target = _targets[i];
                    final agencyName = target['agencyId'] is Map ? target['agencyId']['name'] : 'Agency';
                    final progress = (target['currentProgress'] ?? 0).toDouble();
                    final targetAmount = (target['targetAmount'] ?? 1).toDouble();
                    final percent = targetAmount > 0 ? (progress / targetAmount * 100).clamp(0, 100) : 0.0;
                    final status = target['status'] ?? 'ACTIVE';
                    final now = DateTime.now();
                    final endDate = target['endDate'] != null ? DateTime.tryParse(target['endDate']) : null;
                    final daysRemaining = endDate != null ? endDate.difference(now).inDays : 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(agencyName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      Text('${target['targetType'] ?? 'COINS_SPENT'} Target: ${target['targetAmount'] ?? 0}',
                                          style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(status, style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: percent / 100,
                                      minHeight: 12,
                                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(status)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('${percent.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text('${progress.toInt()} / ${targetAmount.toInt()}',
                                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                const Spacer(),
                                if (status == 'ACTIVE')
                                  Text('Days remaining: $daysRemaining',
                                      style: TextStyle(color: daysRemaining < 3 ? Colors.red : Colors.grey, fontSize: 13)),
                                if (target['rewardValue'] != null) ...[
                                  const SizedBox(width: 12),
                                  Icon(Icons.card_giftcard, size: 14, color: Colors.orange.shade700),
                                  const SizedBox(width: 4),
                                  Text('Reward: ${target['rewardValue']}', style: TextStyle(fontSize: 13, color: Colors.orange.shade700)),
                                ],
                              ],
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
