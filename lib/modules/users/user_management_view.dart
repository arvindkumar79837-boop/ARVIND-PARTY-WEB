// ═══════════════════════════════════════════════════════════════════════════
// VIEW: UserManagementView — Full user CRUD for admin panel
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filter = 'all'; // all, verified, banned, active
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final queryParams = <String, String>{};
      if (_filter == 'verified') queryParams['isVerified'] = 'true';
      if (_filter == 'banned') queryParams['isBanned'] = 'true';
      if (_searchQuery.isNotEmpty) queryParams['search'] = _searchQuery;

      final response = await _apiService.get('/admin/users', queryParams: queryParams);
      if (response['success'] == true) {
        _users = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _toggleBan(String userId, bool isBanned) async {
    try {
      if (isBanned) {
        await _apiService.post('/admin/users/unblock/$userId', {});
      } else {
        await _apiService.post('/admin/users/block/$userId', {});
      }
      Get.snackbar('Success', isBanned ? 'User unbanned' : 'User blocked', backgroundColor: Colors.green);
      _loadUsers();
    } catch (e) {
      Get.snackbar('Error', 'Operation failed: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> _banPermanent(String userId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Permanent Ban'),
        content: const Text('Are you sure? This action is permanent.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ban Permanently'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _apiService.post('/admin/users/ban/$userId', {});
        Get.snackbar('Success', 'User permanently banned', backgroundColor: Colors.red);
        _loadUsers();
      } catch (e) {
        Get.snackbar('Error', 'Ban failed: $e', backgroundColor: Colors.red);
      }
    }
  }

  Future<void> _verifyUser(String userId) async {
    try {
      await _apiService.put('/admin/users/verify/$userId', {});
      Get.snackbar('Success', 'User verified', backgroundColor: Colors.green);
      _loadUsers();
    } catch (e) {
      Get.snackbar('Error', 'Verification failed: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> _adjustCoins(String userId) async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adjust Coins'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Amount (negative to deduct)'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: null), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: int.tryParse(controller.text)), child: const Text('Adjust')),
        ],
      ),
    );
    if (result != null && result != 0) {
      try {
        await _apiService.post('/admin/users/adjust-coins/$userId', {'amount': result, 'reason': 'Admin adjustment'});
        Get.snackbar('Success', 'Coins adjusted by $result', backgroundColor: Colors.green);
        _loadUsers();
      } catch (e) {
        Get.snackbar('Error', 'Adjustment failed: $e', backgroundColor: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canBan = _permService.hasPermission('users.ban');
    final canVerify = _permService.hasPermission('users.verify');
    final canAdjust = _permService.hasPermission('users.adjust_coins');
    final canPermanentBan = _permService.hasPermission('users.ban') || _permService.isOwner.value;

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Column(
        children: [
          // ─── FILTERS ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Search users...', border: OutlineInputBorder()),
                    onChanged: (v) {
                      setState(() => _searchQuery = v);
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () => _loadUsers());
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('All')),
                    ButtonSegment(value: 'verified', label: Text('Verified')),
                    ButtonSegment(value: 'banned', label: Text('Banned')),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (v) { setState(() => _filter = v.first); _loadUsers(); },
                ),
              ],
            ),
          ),

          // ─── USER LIST ────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (ctx, i) {
                          final user = _users[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(child: Text((user['name'] ?? 'U')[0].toUpperCase())),
                              title: Text(user['name'] ?? 'Unknown'),
                              subtitle: Text('UID: ${user['uid']} | Coins: ${user['coins'] ?? 0} | Diamonds: ${user['diamonds'] ?? 0}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (canVerify && user['isVerified'] != true)
                                    IconButton(icon: const Icon(Icons.verified, color: Colors.blue), onPressed: () => _verifyUser(user['_id'])),
                                  if (canAdjust)
                                    IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _adjustCoins(user['_id'])),
                                  if (canBan)
                                    IconButton(
                                      icon: Icon(user['isBanned'] == true ? Icons.lock_open : Icons.block, color: user['isBanned'] == true ? Colors.green : Colors.red),
                                      onPressed: () => _toggleBan(user['_id'], user['isBanned'] == true),
                                      tooltip: user['isBanned'] == true ? 'Unblock' : 'Block',
                                    ),
                                  if (canPermanentBan && user['isBanned'] != true)
                                    IconButton(
                                      icon: const Icon(Icons.gavel, color: Colors.red),
                                      onPressed: () => _banPermanent(user['_id']),
                                      tooltip: 'Permanent Ban',
                                    ),
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