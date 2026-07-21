import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';
import '../../core/constants/auth_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();
  final _authController = Get.find<AuthController>();

  bool _isLoading = true;
  Map<String, dynamic> _profile = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/staff/me');
      if (response['success'] == true) {
        _profile = Map<String, dynamic>.from(response['data'] ?? {});
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.put('/staff/update/${_profile['_id']}', updates);
      if (response['success'] == true) {
        Get.snackbar('Success', 'Profile updated', backgroundColor: Colors.green);
        _loadProfile();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Update failed', backgroundColor: Colors.red);
      }
    } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Update failed', backgroundColor: Colors.red); }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _authController.isOwner.value;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.orange,
                              backgroundImage: _profile['avatar'] != null
                                  ? NetworkImage(_profile['avatar'])
                                  : null,
                              child: _profile['avatar'] == null
                                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_profile['name'] ?? 'Staff', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  Text('Role: ${_permService.currentRoleLabel}', style: const TextStyle(color: Colors.grey)),
                                  Text('ID: ${_profile['loginId'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _EditableField(
                          label: 'Display Name',
                          value: _profile['name'] ?? '',
                          onSave: (v) => _updateProfile({'name': v}),
                        ),
                        const SizedBox(height: 12),
                        _EditableField(
                          label: 'Bio',
                          value: _profile['bio'] ?? '',
                          onSave: (v) => _updateProfile({'bio': v}),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Role & Permissions (Read-Only) ─────────────────
                const Text('My Role & Permissions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.admin_panel_settings, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(_permService.currentRoleLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_permService.permissions.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: _permService.permissions.map((p) => Chip(
                              label: Text(p, style: const TextStyle(fontSize: 11)),
                              backgroundColor: Colors.orange.withValues(alpha: 0.15),
                              side: BorderSide.none,
                            )).toList(),
                          )
                        else
                          const Text('No special permissions', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),

                // ── Password Section (Owner Only) ──────────────────
                if (isOwner) ...[
                  const SizedBox(height: 24),
                  const Text('Password Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.lock, color: Colors.orange),
                      title: const Text('Change Password'),
                      subtitle: const Text('Owner can change own password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showChangePasswordDialog(),
                    ),
                  ),
                ],

                if (!isOwner) ...[
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.orange.withValues(alpha: 0.1),
                    child: const ListTile(
                      leading: Icon(Icons.lock, color: Colors.orange),
                      title: Text('Password locked'),
                      subtitle: Text('Only Owner can change your password. Contact Owner for password reset.'),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPw = TextEditingController();
    final newPw = TextEditingController();
    final confirmPw = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: currentPw, obscureText: true, decoration: const InputDecoration(labelText: 'Current Password')),
            const SizedBox(height: 8),
            TextField(controller: newPw, obscureText: true, decoration: const InputDecoration(labelText: 'New Password')),
            const SizedBox(height: 8),
            TextField(controller: confirmPw, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (newPw.text != confirmPw.text) {
                Get.snackbar('Error', 'Passwords do not match', backgroundColor: Colors.red);
                return;
              }
              if (newPw.text.length < 6) {
                Get.snackbar('Error', 'Min 6 characters', backgroundColor: Colors.red);
                return;
              }
              try {
                await _apiService.post('/staff/change-password/${_profile['_id']}', {
                  'currentPassword': currentPw.text,
                  'newPassword': newPw.text,
                });
                Get.snackbar('Success', 'Password changed', backgroundColor: Colors.green);
                Get.back();
              } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Password change failed', backgroundColor: Colors.red); }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

class _EditableField extends StatefulWidget {
  final String label;
  final String value;
  final Function(String) onSave;
  final int maxLines;

  const _EditableField({
    required this.label,
    required this.value,
    required this.onSave,
    this.maxLines = 1,
  });

  @override
  State<_EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<_EditableField> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            maxLines: widget.maxLines,
            enabled: _isEditing,
            decoration: InputDecoration(
              labelText: widget.label,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(_isEditing ? Icons.check : Icons.edit),
          onPressed: () {
            if (_isEditing) {
              widget.onSave(_controller.text);
            }
            setState(() => _isEditing = !_isEditing);
          },
        ),
      ],
    );
  }
}
