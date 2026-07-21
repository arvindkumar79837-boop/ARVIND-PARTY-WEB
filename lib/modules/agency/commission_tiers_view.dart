// ═══════════════════════════════════════════════════════════════════════════
// VIEW: CommissionTiersView — Agency commission tier CRUD
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class CommissionTiersView extends StatefulWidget {
  final String agencyId;
  final String agencyName;

  const CommissionTiersView({super.key, required this.agencyId, required this.agencyName});

  @override
  State<CommissionTiersView> createState() => _CommissionTiersViewState();
}

class _CommissionTiersViewState extends State<CommissionTiersView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _tiers = [];
  bool _isLoading = true;

  final _tierNameController = TextEditingController();
  final _minEarningsController = TextEditingController();
  final _commissionPercentController = TextEditingController();
  final _bonusPercentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTiers();
  }

  @override
  void dispose() {
    _tierNameController.dispose();
    _minEarningsController.dispose();
    _commissionPercentController.dispose();
    _bonusPercentController.dispose();
    super.dispose();
  }

  Future<void> _loadTiers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/agency/commission-tiers/${widget.agencyId}');
      if (response['success'] == true) {
        _tiers = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading tiers: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _addTier() async {
    final name = _tierNameController.text.trim();
    final minEarnings = int.tryParse(_minEarningsController.text) ?? 0;
    final commission = double.tryParse(_commissionPercentController.text);
    final bonus = double.tryParse(_bonusPercentController.text) ?? 0;

    if (name.isEmpty || commission == null || commission <= 0) {
      Get.snackbar('Error', 'Tier name and valid commission % required', backgroundColor: Colors.red);
      return;
    }

    try {
      await _apiService.post('/agency/commission-tiers', {
        'agencyId': widget.agencyId,
        'tierName': name,
        'minEarnings': minEarnings,
        'commissionPercent': commission,
        'bonusPercent': bonus,
      });
      Get.snackbar('Success', 'Commission tier created', backgroundColor: Colors.green);
      _clearControllers();
      _loadTiers();
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar('Error', 'Creation failed', backgroundColor: Colors.red);
    }
  }

  void _clearControllers() {
    _tierNameController.clear();
    _minEarningsController.clear();
    _commissionPercentController.clear();
    _bonusPercentController.clear();
  }

  Future<void> _deleteTier(int index) async {
    try {
      await _apiService.delete('/agency/commission-tiers/${widget.agencyId}/$index');
      Get.snackbar('Success', 'Tier deleted', backgroundColor: Colors.green);
      _loadTiers();
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar('Error', 'Delete failed', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _permService.hasPermission('commission.edit');

    return Scaffold(
      appBar: AppBar(title: Text('Commission Tiers: ${widget.agencyName}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canEdit) ...[
                    const Text('Create Tier', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _tierNameController, decoration: const InputDecoration(labelText: 'Tier Name', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _minEarningsController, decoration: const InputDecoration(labelText: 'Min Earnings', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _commissionPercentController, decoration: const InputDecoration(labelText: 'Commission %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _bonusPercentController, decoration: const InputDecoration(labelText: 'Bonus %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(onPressed: _addTier, icon: const Icon(Icons.add), label: const Text('Add Tier')),
                    const SizedBox(height: 24),
                  ],
                  const Text('Existing Tiers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _tiers.isEmpty
                      ? const Text('No tiers yet')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _tiers.length,
                          itemBuilder: (ctx, i) {
                            final tier = _tiers[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.trending_up, color: Colors.green),
                                title: Text(tier['tierName'] ?? 'Tier ${i + 1}'),
                                subtitle: Text('Min: ${tier['minEarnings']} | Commission: ${tier['commissionPercent']}% | Bonus: ${tier['bonusPercent']}%'),
                                trailing: canEdit
                                    ? IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteTier(i))
                                    : null,
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}