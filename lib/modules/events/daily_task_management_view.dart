import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class DailyTaskManagementView extends StatefulWidget {
  const DailyTaskManagementView({super.key});

  @override
  State<DailyTaskManagementView> createState() => _DailyTaskManagementViewState();
}

class _DailyTaskManagementViewState extends State<DailyTaskManagementView> {
  final _apiService = Get.find<ApiService>();
  final _permService = Get.find<RolePermissionService>();

  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _targetController = TextEditingController();
  final _coinsController = TextEditingController();
  final _diamondsController = TextEditingController();
  final _xpController = TextEditingController();
  String _selectedType = 'LOGIN';

  final List<Map<String, String>> _taskTypes = [
    {'value': 'LOGIN', 'label': 'Daily Login'},
    {'value': 'ROOM_STAY', 'label': 'Room Stay'},
    {'value': 'SEND_MESSAGES', 'label': 'Send Messages'},
    {'value': 'SEND_GIFTS', 'label': 'Send Gifts'},
    {'value': 'JOIN_FAMILY', 'label': 'Join Family'},
    {'value': 'PK_BATTLE', 'label': 'PK Battle'},
    {'value': 'SHOP_PURCHASE', 'label': 'Shop Purchase'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _targetController.dispose();
    _coinsController.dispose();
    _diamondsController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/daily-tasks/admin/all');
      if (response['success'] == true) {
        _tasks = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar('Error', 'Failed to load tasks', backgroundColor: Colors.red);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _createTask() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Error', 'Task name required', backgroundColor: Colors.red);
      return;
    }
    try {
      await _apiService.post('/daily-tasks/admin/create', {
        'task_name': name,
        'description': _descController.text.trim(),
        'task_type': _selectedType,
        'target_value': int.tryParse(_targetController.text.trim()) ?? 1,
        'reward_coins': int.tryParse(_coinsController.text.trim()) ?? 0,
        'reward_diamonds': int.tryParse(_diamondsController.text.trim()) ?? 0,
        'reward_xp': int.tryParse(_xpController.text.trim()) ?? 0,
      });
      Get.snackbar('Success', 'Task created', backgroundColor: Colors.green);
      _nameController.clear();
      _descController.clear();
      _targetController.clear();
      _coinsController.clear();
      _diamondsController.clear();
      _xpController.clear();
      _loadData();
    } catch (e) {
      Get.snackbar('Error', 'Creation failed', backgroundColor: Colors.red);
    }
  }

  Future<void> _toggleTaskStatus(String taskId, bool isActive) async {
    try {
      await _apiService.put('/daily-tasks/admin/$taskId', {'is_active': !isActive});
      _loadData();
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar('Error', 'Failed to toggle', backgroundColor: Colors.red);
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await _apiService.delete('/daily-tasks/admin/$taskId');
      _loadData();
    } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Failed to delete', backgroundColor: Colors.red); }
  }

  Future<void> _seedTasks() async {
    try {
      await _apiService.post('/daily-tasks/admin/seed', {});
      Get.snackbar('Success', 'Default tasks seeded', backgroundColor: Colors.green);
      _loadData();
    } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Failed to seed tasks', backgroundColor: Colors.red); }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _permService.hasPermission('events.daily_tasks');
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Task Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canEdit) ...[
                    const Text('Create New Daily Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Task Name', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 2),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(labelText: 'Task Type', border: OutlineInputBorder()),
                      items: _taskTypes.map((t) => DropdownMenuItem(value: t['value'], child: Text(t['label']!))).toList(),
                      onChanged: (v) => setState(() => _selectedType = v ?? 'LOGIN'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _targetController, decoration: const InputDecoration(labelText: 'Target Value', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _coinsController, decoration: const InputDecoration(labelText: 'Coins Reward', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _diamondsController, decoration: const InputDecoration(labelText: 'Diamonds', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _xpController, decoration: const InputDecoration(labelText: 'XP', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(onPressed: _createTask, icon: const Icon(Icons.add), label: const Text('Create Task')),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(onPressed: _seedTasks, icon: const Icon(Icons.auto_fix_high), label: const Text('Seed Default Tasks'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange)),
                      ],
                    ),
                    const Divider(height: 32),
                  ],
                  Row(
                    children: [
                      Text('All Tasks (${_tasks.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _tasks.isEmpty
                      ? const Center(child: Text('No tasks found'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _tasks.length,
                          itemBuilder: (ctx, i) {
                            final task = _tasks[i];
                            final isActive = task['is_active'] == true;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isActive ? Colors.blue : Colors.grey,
                                  child: Text((task['task_type'] ?? '??').substring(0, 2), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                                title: Text(task['task_name'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Type: ${task['task_type']} | Target: ${task['target_value']}'),
                                    Text('Reward: ${task['reward_coins'] ?? 0} Coins, ${task['reward_xp'] ?? 0} XP'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(isActive ? Icons.toggle_on : Icons.toggle_off_outlined, color: isActive ? Colors.blue : Colors.red),
                                      onPressed: () => _toggleTaskStatus(task['_id'], isActive),
                                    ),
                                    if (canEdit)
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteTask(task['_id']),
                                      ),
                                  ],
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