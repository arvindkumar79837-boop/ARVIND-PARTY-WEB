import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class FamilyAdminSlotsView extends StatefulWidget {
  final String familyId;
  final String familyName;

  const FamilyAdminSlotsView({
    super.key,
    required this.familyId,
    required this.familyName,
  });

  @override
  State<FamilyAdminSlotsView> createState() => _FamilyAdminSlotsViewState();
}

class _FamilyAdminSlotsViewState extends State<FamilyAdminSlotsView> {
  final _apiService = Get.find<ApiService>();
  bool _isLoading = true;

  List<Map<String, dynamic>> _admins = [];
  int _maxSlots = 5;
  int _currentLevel = 1;
  int _currentCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/families/admin/list');
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        setState(() {
          _admins = List<Map<String, dynamic>>.from(data['admins_list'] ?? []);
          _maxSlots = data['maxAdminSlots'] ?? 5;
          _currentLevel = data['currentLevel'] ?? 1;
          _currentCount = data['currentAdminCount'] ?? _admins.length;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load admin list: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _removeAdmin(String uid, String username) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252542),
        title: const Text('Remove Admin?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove "$username" from admin positions?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await _apiService.post('/families/admin/remove', {'targetUid': uid});
      if (response['success'] == true) {
        Get.snackbar('Success', 'Admin removed');
        _loadAdmins();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to remove');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove admin: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotsAvailable = _maxSlots - _currentCount;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('Admins: ${widget.familyName}', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF252542),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAdmins,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin Slots Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.withValues(alpha: 0.3),
                          Colors.purple.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Admin Slots',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSlotIndicator('Used', _currentCount, Colors.purple),
                            const SizedBox(width: 20),
                            _buildSlotIndicator('Available', slotsAvailable, Colors.green),
                            const SizedBox(width: 20),
                            _buildSlotIndicator('Max', _maxSlots, Colors.orange),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Family Level $_currentLevel | ${_maxSlots - _currentCount} slots remaining',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Admin Members',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (_admins.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'No admins assigned yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _admins.length,
                      itemBuilder: (context, index) {
                        final admin = _admins[index];
                        return _buildAdminTile(admin, index);
                      },
                    ),

                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252542),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade300, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Level up the family to unlock more admin slots! Higher levels = more leadership positions.',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSlotIndicator(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildAdminTile(Map<String, dynamic> admin, int index) {
    final uid = admin['uid'] ?? '';
    final username = admin['username'] ?? 'Unknown';
    final role = admin['role'] ?? 'admin';
    final avatar = admin['avatar'] ?? '';
    final level = admin['level'] ?? 1;
    final displayName = admin['displayName'] ?? '';

    Color roleColor;
    String roleLabel;
    if (role == 'co_leader') {
      roleColor = Colors.deepPurple;
      roleLabel = 'CO-LEADER';
    } else if (role == 'elder') {
      roleColor = Colors.orange;
      roleLabel = 'ELDER';
    } else {
      roleColor = Colors.blue;
      roleLabel = 'ADMIN';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF252542), Color(0xFF1E1E3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: roleColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [roleColor, roleColor.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipOval(
              child: avatar.isNotEmpty
                  ? Image.network(avatar, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.person, color: Colors.white))
                  : const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.isNotEmpty ? displayName : username,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: roleColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(roleLabel, style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text('Lv.$level', style: TextStyle(color: Colors.green.shade400, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text('UID: $uid', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
            onPressed: () => _removeAdmin(uid, username),
            tooltip: 'Remove Admin',
          ),
        ],
      ),
    );
  }
}