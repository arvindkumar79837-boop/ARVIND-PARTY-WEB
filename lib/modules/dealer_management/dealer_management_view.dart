// ═══════════════════════════════════════════════════════════════════════════
// VIEW: DealerManagementView — Admin/Owner dealer wallet management
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class DealerManagementView extends StatefulWidget {
  const DealerManagementView({super.key});

  @override
  State<DealerManagementView> createState() => _DealerManagementViewState();
}

class _DealerManagementViewState extends State<DealerManagementView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _dealers = [];
  bool _isLoading = true;
  String _levelFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadDealers();
  }

  Future<void> _loadDealers() async {
    setState(() => _isLoading = true);
    try {
      final queryParams = <String, String>{};
      if (_levelFilter != 'all') queryParams['level'] = _levelFilter;

      final response = await _apiService.get('/dealer/list', queryParams: queryParams);
      if (response['success'] == true) {
        _dealers = List<Map<String, dynamic>>.from(response['data']['dealers'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading dealers: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _createDealerWallet() async {
    final uidController = TextEditingController();
    final levelController = TextEditingController(text: 'silver');
    final commissionController = TextEditingController();
    final notesController = TextEditingController();

    await Get.dialog(
      AlertDialog(
        title: const Text('Create Dealer Wallet'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: uidController, decoration: const InputDecoration(labelText: 'User UID', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: levelController.text,
                decoration: const InputDecoration(labelText: 'Level', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'silver', child: Text('Silver')),
                  DropdownMenuItem(value: 'gold', child: Text('Gold')),
                  DropdownMenuItem(value: 'diamond', child: Text('Diamond')),
                ],
                onChanged: (v) => levelController.text = v ?? 'silver',
              ),
              const SizedBox(height: 8),
              TextField(controller: commissionController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Commission % (optional)', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder()), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(onPressed: () async {
            if (uidController.text.isEmpty) return;
            Get.back();
            await _apiService.post('/dealer/wallet/create', {
              'uid': uidController.text.trim(),
              'level': levelController.text.trim(),
              'commissionPercent': int.tryParse(commissionController.text.trim()) ?? 0,
              'notes': notesController.text.trim(),
            });
            _loadDealers();
            Get.snackbar('Success', 'Dealer wallet created', backgroundColor: Colors.green);
          }, child: const Text('Create')),
        ],
      ),
    );
  }

  Future<void> _creditDealer(String dealerUid) async {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();

    await Get.dialog(
      AlertDialog(
        title: Text('Credit Dealer: $dealerUid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (coins)', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: reasonController, decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(onPressed: () async {
            if (amountController.text.isEmpty) return;
            Get.back();
            await _apiService.post('/dealer/wallet/credit', {
              'dealerUid': dealerUid,
              'amount': int.parse(amountController.text.trim()),
              'reason': reasonController.text.trim(),
            });
            _loadDealers();
            Get.snackbar('Success', 'Wallet credited', backgroundColor: Colors.green);
          }, child: const Text('Credit')),
        ],
      ),
    );
  }

  Future<void> _updateDealerLevel(String dealerUid, String currentLevel) async {
    final levelController = TextEditingController(text: currentLevel);

    await Get.dialog(
      AlertDialog(
        title: Text('Update Level: $dealerUid'),
        content: DropdownButtonFormField<String>(
          initialValue: levelController.text,
          decoration: const InputDecoration(labelText: 'Level', border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'silver', child: Text('Silver')),
            DropdownMenuItem(value: 'gold', child: Text('Gold')),
            DropdownMenuItem(value: 'diamond', child: Text('Diamond')),
          ],
          onChanged: (v) => levelController.text = v ?? 'silver',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(onPressed: () async {
            Get.back();
            await _apiService.put('/dealer/level/$dealerUid', {
              'level': levelController.text.trim(),
            });
            _loadDealers();
            Get.snackbar('Success', 'Level updated', backgroundColor: Colors.green);
          }, child: const Text('Update')),
        ],
      ),
    );
  }

  Future<void> _toggleDealerStatus(String dealerUid, bool currentStatus) async {
    final confirmed = await Get.dialog(
      AlertDialog(
        title: Text(currentStatus ? 'Deactivate Dealer' : 'Activate Dealer'),
        content: Text('Are you sure you want to ${currentStatus ? 'deactivate' : 'activate'} $dealerUid?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: Text(currentStatus ? 'Deactivate' : 'Activate')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _apiService.put('/dealer/status/$dealerUid', {
      'isActive': !currentStatus,
      'notes': 'Status changed via admin panel',
    });
    _loadDealers();
    Get.snackbar('Success', 'Dealer status updated', backgroundColor: Colors.green);
  }

  Color _levelColor(String level) {
    if (level == 'gold') return Colors.amber;
    if (level == 'diamond') return Colors.blue;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final canManage = _permService.hasPermission('dealers.manage');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealer Management'),
        actions: [
          if (canManage)
            IconButton(onPressed: _loadDealers, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('All')),
                    ButtonSegment(value: 'silver', label: Text('Silver')),
                    ButtonSegment(value: 'gold', label: Text('Gold')),
                    ButtonSegment(value: 'diamond', label: Text('Diamond')),
                  ],
                  selected: {_levelFilter},
                  onSelectionChanged: (v) {
                    setState(() => _levelFilter = v.first);
                    _loadDealers();
                  },
                ),
                const Spacer(),
                if (canManage)
                  ElevatedButton.icon(onPressed: _createDealerWallet, icon: const Icon(Icons.add), label: const Text('Create Dealer')),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _dealers.isEmpty
                    ? const Center(child: Text('No dealers found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _dealers.length,
                        itemBuilder: (ctx, i) {
                          final dealer = _dealers[i];
                          final wallet = dealer['wallet'] ?? dealer;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.workspace_premium, color: _levelColor(wallet['level'] ?? 'silver')),
                                      const SizedBox(width: 8),
                                      Text(wallet['username'] ?? dealer['username'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _levelColor(wallet['level'] ?? 'silver').withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text((wallet['level'] ?? 'silver').toUpperCase(), style: TextStyle(color: _levelColor(wallet['level'] ?? 'silver'), fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                      const Spacer(),
                                      if (dealer['isActive'] == true)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                                          child: const Text('Active', style: TextStyle(color: Colors.green, fontSize: 12)),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                                          child: const Text('Inactive', style: TextStyle(color: Colors.red, fontSize: 12)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('UID: ${wallet['uid'] ?? dealer['uid'] ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(child: Text('Balance: ${wallet['balance'] ?? 0} coins', style: const TextStyle(fontWeight: FontWeight.w600))),
                                      Expanded(child: Text('Commission: ${wallet['commissionPercent'] ?? 0}%', style: const TextStyle(fontSize: 12))),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(child: Text('Transferred: ${wallet['totalTransferred'] ?? 0} coins', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                                      Expanded(child: Text('Customers: ${wallet['totalCustomersServed'] ?? 0}', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                                    ],
                                  ),
                                  if (canManage) ...[
                                    const SizedBox(height: 12),
                                    const Divider(),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextButton.icon(
                                            onPressed: () => _creditDealer(wallet['uid'] ?? ''),
                                            icon: const Icon(Icons.account_balance_wallet, size: 18),
                                            label: const Text('Credit'),
                                          ),
                                        ),
                                        Expanded(
                                          child: TextButton.icon(
                                            onPressed: () => _updateDealerLevel(wallet['uid'] ?? '', wallet['level'] ?? 'silver'),
                                            icon: const Icon(Icons.upgrade, size: 18),
                                            label: const Text('Level'),
                                          ),
                                        ),
                                        Expanded(
                                          child: TextButton.icon(
                                            onPressed: () => _toggleDealerStatus(wallet['uid'] ?? '', dealer['isActive'] == true),
                                            icon: Icon(dealer['isActive'] == true ? Icons.pause : Icons.play_arrow, size: 18),
                                            label: Text(dealer['isActive'] == true ? 'Disable' : 'Enable'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
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