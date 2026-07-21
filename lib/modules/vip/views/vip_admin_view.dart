import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/role_permission_service.dart';
import '../models/vip_level_helper.dart';

class VipAdminView extends StatefulWidget {
  const VipAdminView({super.key});

  @override
  State<VipAdminView> createState() => _VipAdminViewState();
}

class _VipAdminViewState extends State<VipAdminView> with SingleTickerProviderStateMixin {
  final _apiService = Get.find<ApiService>();
  final _permService = Get.find<RolePermissionService>();

  late TabController _tabController;
  final List<String> _tabs = ['All VIP Users', 'SVIP Managers', 'Manage Cosmetics', 'Statistics'];

  List<Map<String, dynamic>> _allVipUsers = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  String _filterSvip = 'all';
  String _filterPremium = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadAllVIPUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllVIPUsers() async {
    setState(() => _isLoading = true);
    try {
      final queryParams = <String, String>{
        'page': _currentPage.toString(),
        'limit': '20',
      };
      if (_filterSvip != 'all') queryParams['is_svip'] = _filterSvip;
      if (_filterPremium != 'all') queryParams['is_premium'] = _filterPremium;

      final response = await _apiService.get('/vip-system/admin/list', queryParams: queryParams);
      if (response['success'] == true) {
        _allVipUsers = List<Map<String, dynamic>>.from(response['data'] ?? []);
        _totalPages = response['pagination']?['pages'] ?? 1;
      }
    } catch (e) {
      debugPrint('Error loading VIP users: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _permService.hasPermission('vip.edit');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super VIP Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.grey,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          if (canEdit) _buildAllVipTab() else _buildAccessDenied(),
          if (canEdit) _buildSviptab() else _buildAccessDenied(),
          if (canEdit) _buildCosmeticsTab() else _buildAccessDenied(),
          _buildStatisticsTab(),
        ],
      ),
      floatingActionButton: canEdit && _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showActivateSvipDialog,
              backgroundColor: Colors.amber.shade700,
              child: const Icon(Icons.auto_awesome, color: Colors.black),
            )
          : null,
    );
  }

  Widget _buildAccessDenied() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('Access Denied', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAllVipTab() {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadAllVIPUsers,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: _allVipUsers.length,
                    itemBuilder: (ctx, i) => _buildVipUserCard(_allVipUsers[i]),
                  ),
                ),
        ),
        _buildPagination(),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade900,
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _filterSvip,
              isExpanded: true,
              dropdownColor: Colors.grey.shade800,
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Users')),
                DropdownMenuItem(value: 'true', child: Text('SVIP Only')),
                DropdownMenuItem(value: 'false', child: Text('Normal VIP Only')),
              ],
              onChanged: (v) {
                if (v != null) {
                  _filterSvip = v;
                  _currentPage = 1;
                  _loadAllVIPUsers();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: _filterPremium,
              isExpanded: true,
              dropdownColor: Colors.grey.shade800,
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Premium')),
                DropdownMenuItem(value: 'true', child: Text('Premium Only')),
                DropdownMenuItem(value: 'false', child: Text('Non-Premium')),
              ],
              onChanged: (v) {
                if (v != null) {
                  _filterPremium = v;
                  _currentPage = 1;
                  _loadAllVIPUsers();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVipUserCard(Map<String, dynamic> vip) {
    final user = vip['user_details'] ?? {};
    final isSvip = vip['is_svip'] ?? false;
    final level = isSvip ? (vip['svip_level'] ?? 0) : (vip['vip_level'] ?? 0);
    final levelColor = isSvip ? VipLevelHelper.getSvipColor(level) : VipLevelHelper.getColor(level);

    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: levelColor.withValues(alpha: 0.3),
          child: Text(
            '${vip['vip_level'] ?? 0}',
            style: TextStyle(color: levelColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        title: Text(
          user['username'] ?? 'Unknown',
          style: TextStyle(
            color: isSvip ? Colors.amber : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSvip) Text('👑 SVIP Level ${vip['svip_level']}', style: TextStyle(color: Colors.amber.shade400, fontSize: 12)),
            Text('XP: ${vip['vip_xp'] ?? 0}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            if (vip['is_premium'] == true) Text('⭐ Premium', style: TextStyle(color: Colors.purple.shade300, fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(isSvip ? Icons.auto_awesome : Icons.star_border, color: Colors.amber),
              onPressed: () => _showUserDetail(vip),
            ),
            if (!isSvip)
              IconButton(
                icon: const Icon(Icons.arrow_upward, color: Colors.blue),
                onPressed: () => _showUpdateLevelDialog(vip),
              ),
          ],
        ),
      ),
    );
  }

  void _showUserDetail(Map<String, dynamic> vip) {
    final user = vip['user_details'] ?? {};
    final isSvip = vip['is_svip'] ?? false;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Color(0xFF1A1A2E), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade600, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(user['username'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(user['fullName'] ?? '', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
            const SizedBox(height: 12),
            _detailRow('VIP Level', '${vip['vip_level'] ?? 0}${isSvip ? ' (SVIP ${vip['svip_level']})' : ''}'),
            _detailRow('VIP XP', '${vip['vip_xp'] ?? 0}'),
            _detailRow('Premium', vip['is_premium'] == true ? 'Active' : 'No'),
            if (vip['premium_expiry'] != null) _detailRow('Premium Expiry', _formatDate(vip['premium_expiry'])),
            _detailRow('Total Recharge', '${vip['total_recharge_amount'] ?? 0}'),
            if (isSvip) ...[
              _detailRow('Activated By', vip['svip_activated_by']?['username'] ?? 'Unknown'),
              _detailRow('Package', vip['svip_package_name'] ?? ''),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (!isSvip)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _showActivateSvipDialog(userUid: vip['user_uid']);
                      },
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Activate SVIP'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700, foregroundColor: Colors.black),
                    ),
                  ),
                if (!isSvip) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      _showUpdateLevelDialog(vip);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    return date.toString().split('T')[0];
  }

  void _showActivateSvipDialog({String? userUid}) {
    final uidCtrl = TextEditingController(text: userUid ?? '');
    final packageCtrl = TextEditingController();
    int selectedLevel = 1;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Color(0xFF1A1A2E), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Activate SVIP', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: uidCtrl,
              decoration: const InputDecoration(labelText: 'User UID', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: packageCtrl,
              decoration: const InputDecoration(labelText: 'Package Name', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: selectedLevel,
              items: const [1, 2, 3, 4, 5].map((l) => DropdownMenuItem(value: l, child: Text('SVIP $l'))).toList(),
              onChanged: (v) => selectedLevel = v ?? 1,
              decoration: const InputDecoration(labelText: 'SVIP Level', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: () => Get.back(), child: const Text('Cancel'))),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (uidCtrl.text.isEmpty) return;
                      Get.back();
                      await _activateSvip(uidCtrl.text.trim(), selectedLevel, packageCtrl.text.trim());
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
                    child: const Text('Activate', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _activateSvip(String userUid, int level, String package) async {
    try {
      await _apiService.post('/vip-system/svip/activate', {
        'user_uid': userUid,
        'svip_level': level,
        'package_name': package.isEmpty ? 'SVIP $level Package' : package,
      });
      Get.snackbar('Success', 'SVIP activated!', backgroundColor: Colors.amber, colorText: Colors.black);
      _loadAllVIPUsers();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
    }
  }

  void _showUpdateLevelDialog(Map<String, dynamic> vip) {
    final levelCtrl = TextEditingController(text: '${vip['vip_level'] ?? 0}');
    final xpCtrl = TextEditingController(text: '${vip['vip_xp'] ?? 0}');

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Color(0xFF1A1A2E), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Update VIP', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: levelCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'VIP Level (0-15)', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: xpCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'VIP XP', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: () => Get.back(), child: const Text('Cancel'))),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (levelCtrl.text.isEmpty) return;
                      Get.back();
                      await _updateVip(vip['user_uid'], int.tryParse(levelCtrl.text) ?? 0, int.tryParse(xpCtrl.text) ?? 0);
                    },
                    child: const Text('Update'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateVip(String userUid, int level, int xp) async {
    try {
      await _apiService.post('/vip-system/admin/update-level', {'user_uid': userUid, 'vip_level': level, 'vip_xp': xp});
      Get.snackbar('Success', 'VIP updated!', backgroundColor: Colors.green);
      _loadAllVIPUsers();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
    }
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade900,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1 ? () {
              _currentPage--;
              _loadAllVIPUsers();
            } : null,
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Text('$_currentPage / $_totalPages', style: const TextStyle(color: Colors.white)),
          IconButton(
            onPressed: _currentPage < _totalPages ? () {
              _currentPage++;
              _loadAllVIPUsers();
            } : null,
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSviptab() {
    return FutureBuilder(
      future: _apiService.get('/vip-system/svip/users'),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        if (data['success'] != true || (data['data'] as List).isEmpty) return _buildEmptyState('No SVIP users found');

        final svipUsers = data['data'] as List;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: svipUsers.length,
          itemBuilder: (ctx, i) => _buildSviUserCard(svipUsers[i]),
        );
      },
    );
  }

  Widget _buildSviUserCard(Map<String, dynamic> svip) {
    final user = svip['user_details'] ?? {};
    final config = svip['svip_config'] ?? {};

    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.amber, Colors.deepOrange]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white),
        ),
        title: Text('👑 ${user['username'] ?? 'Unknown'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SVIP Level ${svip['svip_level']}', style: const TextStyle(color: Colors.amber)),
            Text('Package: ${svip['svip_package_name'] ?? 'N/A'}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
        trailing: IconButton(
          onPressed: () async {
            Get.defaultDialog(
              title: 'Deactivate SVIP',
              content: const Text('Are you sure?', style: TextStyle(color: Colors.white)),
              textConfirm: 'Deactivate',
              textCancel: 'Cancel',
              confirmTextColor: Colors.white,
              buttonColor: Colors.red,
              onConfirm: () async {
                Get.back();
                await _apiService.post('/vip-system/svip/deactivate', {'user_uid': svip['user_uid']});
                Get.snackbar('Done', 'SVIP deactivated', backgroundColor: Colors.orange);
                setState(() {});
              },
            );
          },
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildCosmeticsTab() {
    return FutureBuilder(
      future: _apiService.get('/vip-system/admin/cosmetics?action=list'),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        if (data['success'] != true) return _buildEmptyState('Failed to load cosmetics');

        final items = (data['data'] as List) ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (ctx, i) => _buildCosmeticCard(items[i]),
        );
      },
    );
  }

  Widget _buildCosmeticCard(Map<String, dynamic> item) {
    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: Colors.pink.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.shopping_bag, color: Colors.pink),
        ),
        title: Text(item['item_name'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text('${item['rarity']?.toUpperCase() ?? 'COMMON'} • ${item['item_type']}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditCosmeticDialog(item),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                try {
                  await _apiService.post('/vip-system/admin/cosmetics', {'action': 'delete', 'item_data': {'item_id': item['item_id']}});
                  Get.snackbar('Deleted', 'Cosmetic removed', backgroundColor: Colors.green);
                  setState(() {});
                } catch (e) {
                  Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCosmeticDialog(Map<String, dynamic> item) {
    final nameCtrl = TextEditingController(text: item['item_name'] ?? '');
    final costCtrl = TextEditingController(text: '${item['coin_cost'] ?? 0}');
    final vipReqCtrl = TextEditingController(text: '${item['vip_level_required'] ?? 0}');

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Color(0xFF1A1A2E), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Cosmetic', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Coin Cost', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: vipReqCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'VIP Level Required', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: () => Get.back(), child: const Text('Cancel'))),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      try {
                        await _apiService.post('/vip-system/admin/cosmetics', {
                          'action': 'update',
                          'item_data': {
                            'item_id': item['item_id'],
                            'item_name': nameCtrl.text.trim(),
                            'coin_cost': int.tryParse(costCtrl.text) ?? 0,
                            'vip_level_required': int.tryParse(vipReqCtrl.text) ?? 0,
                          },
                        });
                        Get.snackbar('Updated', 'Cosmetic updated', backgroundColor: Colors.green);
                        setState(() {});
                      } catch (e) {
                        Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('VIP System Overview', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          FutureBuilder(
            future: _apiService.get('/vip-system/admin/list?limit=1000'),
            builder: (ctx, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final allVips = (snap.data?['data'] ?? []) as List;
              final totalVIP = allVips.where((v) => (v['vip_level'] ?? 0) > 0).length;
              final totalSVIP = allVips.where((v) => v['is_svip'] == true).length;
              final totalPremium = allVips.where((v) => v['is_premium'] == true).length;

              return Column(
                children: [
                  Row(
                    children: [
                      _statCard('Total VIP', '$totalVIP', Colors.amber),
                      const SizedBox(width: 12),
                      _statCard('SVIP', '$totalSVIP', Colors.deepOrange),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _statCard('Premium', '$totalPremium', Colors.purple),
                      const SizedBox(width: 12),
                      _statCard('Total Users', '$totalVIP', Colors.blue),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey.shade300, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}