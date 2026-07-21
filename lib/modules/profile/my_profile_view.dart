import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';
import '../../core/constants/auth_controller.dart';
import '../../core/theme/web_theme.dart';

class MyProfileView extends StatefulWidget {
  const MyProfileView({super.key});

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  final _permService = Get.find<RolePermissionService>();
  final _authController = Get.find<AuthController>();
  final _apiService = Get.find<ApiService>();

  bool _isLoading = true;
  Map<String, dynamic> _profile = {};
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/staff/me');
      if (response['success'] == true) {
        _profile = Map<String, dynamic>.from(response['data'] ?? {});
        _nameController.text = _profile['name'] ?? '';
        _bioController.text = _profile['bio'] ?? '';
      }
    } catch (e) { debugPrint('Error: $e'); }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    try {
      final response = await _apiService.put('/staff/update/${_profile['_id']}', {
        'name': _nameController.text,
        'bio': _bioController.text,
      });
      if (response['success'] == true) {
        Get.snackbar('Success', 'Profile updated', backgroundColor: Colors.green);
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
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: WebTheme.primaryOrange,
                    backgroundImage: _profile['avatar'] != null
                        ? NetworkImage(_profile['avatar'])
                        : null,
                    child: _profile['avatar'] == null
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Display Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _bioController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Bio',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.info_outline),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saveProfile,
                            icon: const Icon(Icons.save),
                            label: const Text('Save Changes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: WebTheme.primaryOrange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: Colors.orange),
                    title: const Text('Role'),
                    subtitle: Text(_permService.currentRoleLabel),
                  ),
                ),
                if (isOwner)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.star, color: Colors.yellow),
                      title: const Text('Owner'),
                      subtitle: const Text('Full access — God Mode'),
                    ),
                  ),
                if (!isOwner)
                  Card(
                    color: Colors.orange.withValues(alpha: 0.1),
                    child: const ListTile(
                      leading: Icon(Icons.lock, color: Colors.orange),
                      title: Text('Password locked'),
                      subtitle: Text('Only Owner can change your password.'),
                    ),
                  ),
              ],
            ),
    );
  }
}
