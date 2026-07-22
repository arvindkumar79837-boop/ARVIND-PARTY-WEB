import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class StaffListView extends StatefulWidget {
  const StaffListView({super.key});

  @override
  State<StaffListView> createState() => _StaffListViewState();
}

class _StaffListViewState extends State<StaffListView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _staff = [];
  List<Map<String, dynamic>> _availableRoles = [];
  List<String> _allPermissions = [];
  Map<String, dynamic> _roleHierarchy = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStaff();
    _loadRoles();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/staff/list');
      if (response['success'] == true) {
        _staff = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading staff: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadRoles() async {
    try {
      final response = await _apiService.get('/staff/roles');
      if (response['success'] == true) {
        _availableRoles = List<Map<String, dynamic>>.from(response['data']['roles'] ?? []);
        _allPermissions = List<String>.from(response['data']['allPermissions'] ?? []);
        _roleHierarchy = Map<String, dynamic>.from(response['data']['hierarchy'] ?? {});
      }
    } catch (e) {
      debugPrint('Error loading roles: $e');
    }
  }

  Future<void> _toggleActive(String staffId, bool currentStatus) async {
    try {
      await _apiService.put('/staff/update/$staffId', {'isActive': !currentStatus});
      Get.snackbar('Success', currentStatus ? 'Staff deactivated' : 'Staff activated', backgroundColor: Colors.green);
      _loadStaff();
    } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Operation failed', backgroundColor: Colors.red); }
  }

  Future<void> _forceChangePassword(String staffId, String loginId) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Force Password: $loginId'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Password'),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: null), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: controller.text), child: const Text('Change')),
        ],
      ),
    );
    if (result != null && result.length >= 6) {
      try {
        await _apiService.post('/staff/change-password/$staffId', {'newPassword': result});
        Get.snackbar('Success', 'Password changed and locked', backgroundColor: Colors.green);
      } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Password change failed', backgroundColor: Colors.red); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _permService.hasPermission('staff.edit') || _permService.isOwner.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Management'), actions: [
        if (canEdit)
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showInviteStaffDialog(),
            tooltip: 'Invite Staff (Search by UID)',
          ),
      ]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _staff.isEmpty
              ? const Center(child: Text('No staff found'))
              : ListView.builder(
                  itemCount: _staff.length,
                  itemBuilder: (ctx, i) {
                    final s = _staff[i];
                    final roleColor = _getRoleColor(s['roleLevel'] ?? 0);
                    final roleInfo = _roleHierarchy[s['role']] ?? {};
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: roleColor,
                          child: Text((s['name'] ?? s['loginId'] ?? 'S')[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(s['name'] ?? s['loginId'] ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${roleInfo['label'] ?? s['role'] ?? ''} | ${s['loginId'] ?? ''} | Level: ${s['roleLevel'] ?? 0}'),
                            if (s['uid'] != null && s['uid'].toString().isNotEmpty)
                              Text('UID: ${s['uid']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: s['isActive'] == true ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(s['isActive'] == true ? 'Active' : 'Inactive', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                            if (canEdit)
                              IconButton(
                                icon: const Icon(Icons.lock_reset, color: Colors.orange),
                                onPressed: () => _forceChangePassword(s['_id'], s['loginId']),
                                tooltip: 'Force Change Password',
                              ),
                            if (canEdit)
                              IconButton(
                                icon: Icon(s['isActive'] == true ? Icons.toggle_on : Icons.toggle_off, color: s['isActive'] == true ? Colors.green : Colors.grey),
                                onPressed: () => _toggleActive(s['_id'], s['isActive'] == true),
                                tooltip: 'Toggle Active',
                              ),
                          ],
                        ),
                        onTap: canEdit ? () => _showEditStaffDialog(s) : null,
                      ),
                    );
                  },
                ),
    );
  }

  void _showInviteStaffDialog() {
    final uidController = TextEditingController();
    final nameController = TextEditingController();
    final loginIdController = TextEditingController();
    final passwordController = TextEditingController();
    String? selectedRole;
    List<String> selectedPermissions = [];
    Map<String, dynamic>? searchResult;
    bool isSearching = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Invite Staff'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: uidController,
                        decoration: const InputDecoration(
                          labelText: 'Search by UID / Name / Phone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: isSearching
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.search),
                      onPressed: isSearching ? null : () async {
                        if (uidController.text.trim().isEmpty) return;
                        setDialogState(() => isSearching = true);
                        try {
                          final response = await _apiService.get('/staff/search', queryParams: {'query': uidController.text.trim()});
                          if (response['success'] == true && response['data'] != null) {
                            final results = response['data'];
                            if (results is List && results.isNotEmpty) {
                              searchResult = Map<String, dynamic>.from(results[0]);
                              nameController.text = searchResult!['name'] ?? '';
                            } else if (results is Map) {
                              searchResult = Map<String, dynamic>.from(results);
                              nameController.text = searchResult!['name'] ?? '';
                            } else {
                              Get.snackbar('Not Found', 'No user found with this UID', backgroundColor: Colors.orange);
                            }
                          } else {
                            Get.snackbar('Not Found', 'No user found with this UID', backgroundColor: Colors.orange);
                          }
                        } catch (e) {
                          Get.snackbar('Error', 'Search failed: $e', backgroundColor: Colors.red);
                        }
                        setDialogState(() => isSearching = false);
                      },
                    ),
                  ],
                ),
                if (searchResult != null) ...[
                  const SizedBox(height: 12),
                  Card(
                    color: Colors.green.withValues(alpha: 0.1),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: searchResult!['avatar'] != null
                            ? NetworkImage(searchResult!['avatar'])
                            : null,
                        child: searchResult!['avatar'] == null ? const Icon(Icons.person) : null,
                      ),
                      title: Text(searchResult!['name'] ?? 'Unknown'),
                      subtitle: Text('UID: ${searchResult!['uid'] ?? uidController.text}'),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: loginIdController,
                    decoration: const InputDecoration(
                      labelText: 'Login ID (for staff login)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.alternate_email),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password (min 6 characters)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                    items: _availableRoles.map((role) {
                      return DropdownMenuItem<String>(
                        value: role['role'],
                        child: Text('${role['label']} ${role['labelHi'] ?? ''}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedRole = value;
                      final role = _availableRoles.firstWhereOrNull((r) => r['role'] == value);
                      if (role != null && role['defaultPermissions'] != null) {
                        selectedPermissions = List<String>.from(role['defaultPermissions']);
                      }
                      setDialogState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  if (selectedPermissions.isNotEmpty) ...[
                    const Text('Permissions:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _allPermissions.map((perm) {
                        final isSelected = selectedPermissions.contains(perm);
                        return FilterChip(
                          label: Text(perm, style: const TextStyle(fontSize: 10)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                selectedPermissions.add(perm);
                              } else {
                                selectedPermissions.remove(perm);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            if (searchResult != null)
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty || selectedRole == null) {
                    Get.snackbar('Error', 'Fill name and select role', backgroundColor: Colors.red);
                    return;
                  }
                  if (loginIdController.text.isEmpty) {
                    Get.snackbar('Error', 'Login ID is required', backgroundColor: Colors.red);
                    return;
                  }
                  if (passwordController.text.length < 6) {
                    Get.snackbar('Error', 'Password must be at least 6 characters', backgroundColor: Colors.red);
                    return;
                  }
                  try {
                    final response = await _apiService.post('/staff/create', {
                      'uid': searchResult!['uid'] ?? uidController.text.trim(),
                      'loginId': loginIdController.text.trim(),
                      'password': passwordController.text,
                      'name': nameController.text,
                      'role': selectedRole,
                      'permissions': selectedPermissions,
                    });
                    if (response['success'] == true) {
                      Get.snackbar('Success', 'Staff member invited', backgroundColor: Colors.green);
                      Get.back();
                      _loadStaff();
                    } else {
                      Get.snackbar('Error', response['message'] ?? 'Failed', backgroundColor: Colors.red);
                    }
                  } catch (e) {
                    Get.snackbar('Error', 'Failed to create staff: $e', backgroundColor: Colors.red);
                  }
                },
                child: const Text('Invite Staff'),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditStaffDialog(Map<String, dynamic> staff) {
    final nameController = TextEditingController(text: staff['name'] ?? '');
    String? selectedRole = staff['role'];
    List<String> selectedPermissions = List<String>.from(staff['permissions'] ?? []);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit: ${staff['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                initialValue: selectedRole,
                items: _availableRoles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role['role'],
                    child: Text('${role['label']} ${role['labelHi'] ?? ''}'),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedRole = value;
                  final role = _availableRoles.firstWhereOrNull((r) => r['role'] == value);
                  if (role != null && role['defaultPermissions'] != null) {
                    selectedPermissions = List<String>.from(role['defaultPermissions']);
                  }
                },
              ),
              const SizedBox(height: 12),
              const Text('Permissions:', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _allPermissions.map((perm) {
                  final isSelected = selectedPermissions.contains(perm);
                  return FilterChip(
                    label: Text(perm, style: const TextStyle(fontSize: 10)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedPermissions.add(perm);
                        } else {
                          selectedPermissions.remove(perm);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final response = await _apiService.put('/staff/update/${staff['_id']}', {
                  'name': nameController.text,
                  'role': selectedRole,
                  'permissions': selectedPermissions,
                });
                if (response['success'] == true) {
                  Get.snackbar('Success', 'Staff updated', backgroundColor: Colors.green);
                  Get.back();
                  _loadStaff();
                } else {
                  Get.snackbar('Error', response['message'] ?? 'Failed', backgroundColor: Colors.red);
                }
              } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Failed to update staff', backgroundColor: Colors.red); }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(int level) {
    if (level >= 100) return Colors.purple;
    if (level >= 80) return Colors.red;
    if (level >= 60) return Colors.orange;
    if (level >= 40) return Colors.blue;
    if (level >= 20) return Colors.green;
    return Colors.grey;
  }
}
