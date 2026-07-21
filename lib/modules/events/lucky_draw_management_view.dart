import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class LuckyDrawManagementView extends StatefulWidget {
  const LuckyDrawManagementView({super.key});

  @override
  State<LuckyDrawManagementView> createState() => _LuckyDrawManagementViewState();
}

class _LuckyDrawManagementViewState extends State<LuckyDrawManagementView> {
  final _apiService = Get.find<ApiService>();
  final _permService = Get.find<RolePermissionService>();

  List<Map<String, dynamic>> _draws = [];
  bool _isLoading = true;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _spinCostController = TextEditingController();
  final _maxSpinsController = TextEditingController();
  final _totalSpinsController = TextEditingController();


  // Segment controllers
  final List<Map<String, dynamic>> _segments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _spinCostController.dispose();
    _maxSpinsController.dispose();
    _totalSpinsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/lucky-draws/admin/all');
      if (response['success'] == true) {
        _draws = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Failed to load lucky draws', backgroundColor: Colors.red); }
    setState(() => _isLoading = false);
  }

  void _addSegment() {
    setState(() {
      _segments.add({
        'label': '',
        'prize_type': 'coins',
        'prize_value': 0,
        'prize_name': '',
        'weight': 10,
        'color': '#FF6B6B'
      });
    });
  }

  void _removeSegment(int index) {
    setState(() => _segments.removeAt(index));
  }

  Future<void> _createLuckyDraw() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _segments.length < 2) {
      Get.snackbar('Error', 'Name and at least 2 segments required', backgroundColor: Colors.red);
      return;
    }

    try {
      await _apiService.post('/lucky-draws/admin/create', {
        'draw_name': name,
        'description': _descriptionController.text.trim(),
        'spin_cost_coins': int.tryParse(_spinCostController.text.trim()) ?? 100,
        'max_spins_per_user': int.tryParse(_maxSpinsController.text.trim()) ?? 10,
        'total_spins_allowed': int.tryParse(_totalSpinsController.text.trim()) ?? 1000,
        'segments': _segments.map((s) => {
          'label': s['label'],
          'prize_type': s['prize_type'],
          'prize_value': s['prize_value'],
          'prize_name': s['prize_name'],
          'weight': s['weight'],
          'color': s['color']
        }).toList(),
        'start_time': DateTime.now().toIso8601String(),
        'end_time': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });
      Get.snackbar('Success', 'Lucky draw created', backgroundColor: Colors.green);
      _nameController.clear();
      _descriptionController.clear();
      _spinCostController.clear();
      _maxSpinsController.clear();
      _totalSpinsController.clear();
      _segments.clear();
      _loadData();
    } catch (e) {
      Get.snackbar('Error', 'Creation failed: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> _toggleDrawStatus(String drawId, bool isActive) async {
    try {
      await _apiService.put('/lucky-draws/admin/$drawId', {'is_active': !isActive});
      Get.snackbar('Success', 'Draw ${!isActive ? 'activated' : 'deactivated'}', backgroundColor: Colors.green);
      _loadData();
    } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Failed to toggle', backgroundColor: Colors.red); }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _permService.hasPermission('events.lucky_draw');
    return Scaffold(
      appBar: AppBar(title: const Text('Lucky Draw Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canEdit) ...[
                    const Text('Create New Lucky Draw', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Draw Name', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 2),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _spinCostController, decoration: const InputDecoration(labelText: 'Spin Cost (Coins)', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _maxSpinsController, decoration: const InputDecoration(labelText: 'Max/User', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _totalSpinsController, decoration: const InputDecoration(labelText: 'Total Spins', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Wheel Segments (min 2):', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._segments.asMap().entries.map((entry) {
                      final i = entry.key;
                      final seg = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(labelText: 'Label', border: OutlineInputBorder()),
                                  onChanged: (v) => seg['label'] = v,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: seg['prize_type'],
                                  decoration: const InputDecoration(labelText: 'Prize Type', border: OutlineInputBorder()),
                                  items: ['coins', 'diamonds', 'xp', 'frame', 'badge', 'rocket', 'vip_days', 'jackpot', 'entry_car', 'nothing']
                                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                      .toList(),
                                  onChanged: (v) => seg['prize_type'] = v ?? 'coins',
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => seg['prize_value'] = int.tryParse(v) ?? 0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  decoration: const InputDecoration(labelText: 'Wt', border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => seg['weight'] = int.tryParse(v) ?? 10,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => _removeSegment(i),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _addSegment,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Segment'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _createLuckyDraw,
                          icon: const Icon(Icons.save),
                          label: const Text('Create Lucky Draw'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                  ],
                  Text('All Lucky Draws (${_draws.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _draws.isEmpty
                      ? const Center(child: Text('No lucky draws found'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _draws.length,
                          itemBuilder: (ctx, i) {
                            final draw = _draws[i];
                            final isActive = draw['is_active'] == true;
                            final segments = draw['segments'] as List<dynamic>? ?? [];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isActive ? Colors.amber : Colors.grey,
                                  child: Text('${segments.length}', style: const TextStyle(color: Colors.white)),
                                ),
                                title: Text(draw['draw_name'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Segments: ${segments.length} | Spin: ${draw['spin_cost_coins'] ?? 0} coins'),
                                    Text('Spins: ${draw['total_spins'] ?? 0} | Users: ${draw['total_users_played'] ?? 0}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(isActive ? Icons.toggle_on : Icons.toggle_off_outlined, color: isActive ? Colors.amber : Colors.red),
                                  onPressed: () => _toggleDrawStatus(draw['_id'], isActive),
                                ),
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