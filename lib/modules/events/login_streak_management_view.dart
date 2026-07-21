import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class LoginStreakManagementView extends StatefulWidget {
  const LoginStreakManagementView({super.key});

  @override
  State<LoginStreakManagementView> createState() => _LoginStreakManagementViewState();
}

class _LoginStreakManagementViewState extends State<LoginStreakManagementView> {
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _streaks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/login-streak/admin/all');
      if (response['success'] == true) {
        _streaks = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Failed to load streaks', backgroundColor: Colors.red); }
    setState(() => _isLoading = false);
  }

  Future<void> _resetStreak(String userId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reset Streak?'),
        content: const Text('This will reset the user\'s login streak to 0'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Reset')),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _apiService.put('/login-streak/admin/reset/$userId', {});
        Get.snackbar('Success', 'Streak reset', backgroundColor: Colors.green);
        _loadData();
      } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Failed to reset', backgroundColor: Colors.red); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Streak Management'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _streaks.isEmpty
              ? const Center(child: Text('No streak data found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _streaks.length,
                  itemBuilder: (ctx, i) {
                    final s = _streaks[i];
                    final user = s['userId'] as Map<String, dynamic>?;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: (s['current_streak'] ?? 0) >= 7 ? Colors.amber : Colors.blueGrey,
                          child: Text('${s['current_streak'] ?? 0}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(user?['username'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('UID: ${user?['uid'] ?? 'N/A'}'),
                            Text('Current Streak: ${s['current_streak'] ?? 0} | Longest: ${s['longest_streak'] ?? 0}'),
                            Text('Total Logins: ${s['total_logins'] ?? 0} | Rewards Claimed: ${s['total_rewards_claimed'] ?? 0}'),
                            Text('Day 7: ${s['day_7_reward_claimed'] == true ? 'Claimed' : 'Not Claimed'} | Day 30: ${s['day_30_reward_claimed'] == true ? 'Claimed' : 'Not Claimed'}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.restart_alt, color: Colors.red),
                          onPressed: () => _resetStreak(s['userId'] is Map ? (user?['_id'] ?? '') : (s['userId'] is String ? s['userId'] : '')),
                          tooltip: 'Reset Streak',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}