// ═══════════════════════════════════════════════════════════════════════════
// VIEW: VipManagementView — VIP plan CRUD
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class VipManagementView extends StatefulWidget {
  const VipManagementView({super.key});

  @override
  State<VipManagementView> createState() => _VipManagementViewState();
}

class _VipManagementViewState extends State<VipManagementView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _benefitsController = TextEditingController();
  final _levelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _benefitsController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/vip/plans');
      if (response['success'] == true) {
        _plans = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading VIP plans: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _addPlan() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text);
    final duration = int.tryParse(_durationController.text);
    final level = int.tryParse(_levelController.text);

    if (name.isEmpty || price == null || duration == null || level == null) {
      Get.snackbar('Error', 'All fields required with valid values', backgroundColor: Colors.red);
      return;
    }

    try {
      await _apiService.post('/admin/vip/plans/create', {
        'name': name,
        'price': price,
        'durationDays': duration,
        'level': level,
        'benefits': _benefitsController.text.trim(),
        'isActive': true,
      });
      Get.snackbar('Success', 'VIP plan created', backgroundColor: Colors.green);
      _clearControllers();
      _loadPlans();
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar('Error', 'Creation failed', backgroundColor: Colors.red);
    }
  }

  void _clearControllers() {
    _nameController.clear();
    _priceController.clear();
    _durationController.clear();
    _benefitsController.clear();
    _levelController.clear();
  }

  Future<void> _togglePlan(String planId, bool currentStatus) async {
    try {
      await _apiService.put('/admin/vip/plans/update/$planId', {'isActive': !currentStatus});
      Get.snackbar('Success', currentStatus ? 'Plan deactivated' : 'Plan activated', backgroundColor: Colors.green);
      _loadPlans();
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar('Error', 'Operation failed', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _permService.hasPermission('vip.edit');

    return Scaffold(
      appBar: AppBar(title: const Text('VIP Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canEdit) ...[
                    const Text('Create VIP Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Plan Name', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _durationController, decoration: const InputDecoration(labelText: 'Duration (days)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _levelController, decoration: const InputDecoration(labelText: 'VIP Level', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: _benefitsController, decoration: const InputDecoration(labelText: 'Benefits (comma separated)', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(onPressed: _addPlan, icon: const Icon(Icons.add), label: const Text('Create Plan')),
                    const SizedBox(height: 24),
                  ],
                  const Text('All VIP Plans', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _plans.isEmpty
                      ? const Text('No plans found')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _plans.length,
                          itemBuilder: (ctx, i) {
                            final plan = _plans[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.stars, color: Colors.amber),
                                title: Text(plan['name'] ?? 'Unnamed'),
                                subtitle: Text('Price: ${plan['price']} | Level: ${plan['level']} | ${plan['durationDays']} days'),
                                trailing: canEdit
                                    ? IconButton(
                                        icon: Icon(plan['isActive'] == true ? Icons.visibility : Icons.visibility_off),
                                        onPressed: () => _togglePlan(plan['_id'], plan['isActive'] == true),
                                      )
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