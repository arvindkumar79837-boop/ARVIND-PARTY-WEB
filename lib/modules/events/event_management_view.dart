// ═══════════════════════════════════════════════════════════════════════════
// VIEW: EventManagementView — Event CRUD with new schema support
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class EventManagementView extends StatefulWidget {
  final String initialType;
  const EventManagementView({super.key, this.initialType = ''});

  @override
  State<EventManagementView> createState() => _EventManagementViewState();
}

class _EventManagementViewState extends State<EventManagementView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String _selectedTab = 'events';

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coinsRewardController = TextEditingController();
  final _diamondsRewardController = TextEditingController();
  final _xpRewardController = TextEditingController();
  String _selectedType = 'DAILY_TASK';

  static const _tabNames = ['TOURNAMENT', 'CHAMPIONSHIP', 'TREASURE_HUNT'];
  String _selectedRecurrence = 'none';

  final List<Map<String, String>> _eventTypes = [
    {'value': 'LOGIN', 'label': 'Login Event'},
    {'value': 'DAILY_TASK', 'label': 'Daily Task'},
    {'value': 'RECHARGE', 'label': 'Recharge Bonus'},
    {'value': 'FESTIVAL', 'label': 'Festival Event'},
    {'value': 'ANNIVERSARY', 'label': 'Anniversary'},
    {'value': 'LUCKY_DRAW', 'label': 'Lucky Draw'},
    {'value': 'TREASURE_HUNT', 'label': 'Treasure Hunt'},
    {'value': 'TOURNAMENT', 'label': 'Tournament'},
    {'value': 'CHAMPIONSHIP', 'label': 'Championship'},
  ];

  @override
  void initState() {
    super.initState();
    if (_tabNames.contains(widget.initialType)) {
      _selectedType = widget.initialType;
    }
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _coinsRewardController.dispose();
    _diamondsRewardController.dispose();
    _xpRewardController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/events/admin/list');
      if (response['success'] == true) {
        _events = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar('Error', 'Failed to load events', backgroundColor: Colors.red);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _createEvent() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Error', 'Event name required', backgroundColor: Colors.red);
      return;
    }

    try {
      await _apiService.post('/events/admin/create', {
        'event_name': name,
        'event_type': _selectedType,
        'description': _descriptionController.text.trim(),
        'start_time': DateTime.now().toIso8601String(),
        'end_time': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'reward_details': {
          'coins': int.tryParse(_coinsRewardController.text.trim()) ?? 0,
          'diamonds': int.tryParse(_diamondsRewardController.text.trim()) ?? 0,
          'xp': int.tryParse(_xpRewardController.text.trim()) ?? 0,
        },
        'is_recurring': _selectedRecurrence != 'none',
        'recurrence_pattern': _selectedRecurrence,
      });
      Get.snackbar('Success', 'Event created successfully', backgroundColor: Colors.green);
      _clearControllers();
      _loadData();
    } catch (e) {
      Get.snackbar('Error', 'Creation failed', backgroundColor: Colors.red);
    }
  }

  void _clearControllers() {
    _nameController.clear();
    _descriptionController.clear();
    _coinsRewardController.clear();
    _diamondsRewardController.clear();
    _xpRewardController.clear();
  }

  Future<void> _toggleEventStatus(String eventId, bool isActive) async {
    try {
      await _apiService.put('/events/admin/$eventId', {'is_active': !isActive});
      Get.snackbar('Success', 'Event ${!isActive ? 'activated' : 'deactivated'}', backgroundColor: Colors.green);
      _loadData();
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar('Error', 'Failed to toggle event status', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _permService.hasPermission('events.create');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management'),
        bottom: TabBar(
          onTap: (index) => setState(() => _selectedTab = index == 0 ? 'events' : 'scheduler'),
          tabs: const [
            Tab(text: 'Events'),
            Tab(text: 'Active Cron Jobs'),
          ],
        ),
      ),
      body: _selectedTab == 'events' ? _buildEventsTab(canEdit) : _buildSchedulerTab(),
    );
  }

  Widget _buildEventsTab(bool canEdit) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (canEdit) ...[
                  const Text('Create New Event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Event Name', border: OutlineInputBorder())),
                  const SizedBox(height: 8),
                  TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 2),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: 'Event Type', border: OutlineInputBorder()),
                    items: _eventTypes.map((t) => DropdownMenuItem(value: t['value'], child: Text(t['label']!))).toList(),
                    onChanged: (v) => setState(() => _selectedType = v ?? 'DAILY_TASK'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _coinsRewardController, decoration: const InputDecoration(labelText: 'Coins Reward', border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _diamondsRewardController, decoration: const InputDecoration(labelText: 'Diamonds Reward', border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _xpRewardController, decoration: const InputDecoration(labelText: 'XP Reward', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedRecurrence,
                    decoration: const InputDecoration(labelText: 'Recurrence', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'none', child: Text('No Repeat')),
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                      DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                    ],
                    onChanged: (v) => setState(() => _selectedRecurrence = v ?? 'none'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _createEvent,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Event'),
                    ),
                  ),
                  const Divider(height: 32),
                ],
                Text('All Events (${_events.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _events.isEmpty
                    ? const Center(child: Text('No events found'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _events.length,
                        itemBuilder: (ctx, i) {
                          final event = _events[i];
                          final isActive = event['is_active'] == true;
                          final eventType = event['event_type'] ?? 'UNKNOWN';
                          final rewardDetails = event['reward_details'] as Map<String, dynamic>? ?? {};
                          final rewardsStr = 'Coins: ${rewardDetails['coins'] ?? 0}, Dia: ${rewardDetails['diamonds'] ?? 0}, XP: ${rewardDetails['xp'] ?? 0}';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isActive ? Colors.green : Colors.grey,
                                child: Text(eventType.substring(0, 2), style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                              title: Text(event['event_name'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Type: $eventType'),
                                  Text(rewardsStr),
                                  Text('Start: ${event['start_time'] ?? 'N/A'}'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(isActive ? Icons.toggle_on : Icons.toggle_off_outlined, color: isActive ? Colors.green : Colors.red),
                                onPressed: () => _toggleEventStatus(event['_id'], isActive),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
  }

  Widget _buildSchedulerTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Auto Cron Job Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text('Event Scheduler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('• Auto-activates events when start_time arrives'),
                  const Text('• Auto-expires events when end_time passes'),
                  const Text('• Opens tournament registration on scheduled date'),
                  const Text('• Starts tournaments automatically'),
                  const Text('• Completes tournaments and distributes rewards'),
                  const Text('• Manages championship qualification period'),
                  const Text('• Automatically declares champions'),
                  const Text('• Renews recurring events (daily/weekly/monthly/yearly)'),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text('Active Cron Intervals:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('• Event Scheduler: Every 60 seconds'),
                  const Text('• Daily Attendance Reset: Every 24 hours'),
                  const Text('• Monthly Salary: 1st of every month at midnight'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}