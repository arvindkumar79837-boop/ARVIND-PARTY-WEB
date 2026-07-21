// ═══════════════════════════════════════════════════════════════════════════
// VIEW: FamilyManagementView — Admin panel for managing families
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/web_theme.dart';
import 'family_controller.dart';

class FamilyManagementView extends StatefulWidget {
  const FamilyManagementView({super.key});

  @override
  State<FamilyManagementView> createState() => _FamilyManagementViewState();
}

class _FamilyManagementViewState extends State<FamilyManagementView> {
  final FamilyController _controller = Get.put(FamilyController());
  final _apiService = Get.find<ApiService>();
  final TextEditingController _searchController = TextEditingController();
  final int _currentPage = 1;
  final int _limit = 20;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFamilies();
  }

  Future<void> _loadFamilies() async {
    setState(() => _isLoading = true);
    await _controller.fetchAllFamilies(page: _currentPage);
    setState(() => _isLoading = false);
  }

  Future<void> _searchFamilies(String query) async {
    if (query.isEmpty) {
      _loadFamilies();
      return;
    }
    setState(() => _isLoading = true);
    await _controller.searchFamilies(query);
    setState(() => _isLoading = false);
  }

  Future<void> _toggleFamilyStatus(String familyId, bool isActive) async {
    await _controller.updateFamilyStatus(familyId, !isActive, null);
    _loadFamilies();
  }

  Future<void> _banFamily(String familyId) async {
    final reason = await _showBanDialog();
    if (reason != null) {
      await _controller.updateFamilyStatus(familyId, true, reason);
      _loadFamilies();
    }
  }

  Future<void> _deleteFamily(String familyId) async {
    final confirmed = await _showConfirmDialog('Delete Family', 'Are you sure you want to permanently delete this family?');
    if (confirmed == true) {
      await _controller.deleteFamily(familyId);
      _loadFamilies();
    }
  }

  Future<String?> _showBanDialog() async {
    final TextEditingController reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ban Family'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Reason for ban'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: reasonController.text),
            child: const Text('Ban', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Family Management'),
        backgroundColor: WebTheme.backgroundLight,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildFamilyList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: WebTheme.backgroundLight,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search families by name or badge...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchFamilies('');
                  },
                )
              : null,
          filled: true,
          fillColor: WebTheme.backgroundDark,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: _searchFamilies,
      ),
    );
  }

  Widget _buildFamilyList() {
    return Obx(() {
      if (_isLoading && _controller.allFamilies.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.allFamilies.isEmpty) {
        return const Center(
          child: Text('No families found', style: TextStyle(color: Colors.white70)),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.allFamilies.length,
        itemBuilder: (context, index) {
          final family = _controller.allFamilies[index];
          return _buildFamilyCard(family);
        },
      );
    });
  }

  Widget _buildFamilyCard(Map<String, dynamic> family) {
    final isActive = family['is_active'] ?? true;
    final isBanned = family['is_banned'] ?? false;
    final memberCount = family['members_list']?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WebTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBanned ? Colors.red : (isActive ? Colors.green : Colors.orange),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      family['family_name'] ?? 'Unnamed Family',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${family['familyId']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isBanned ? Colors.red.withValues(alpha: 0.2) : (isActive ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isBanned ? 'BANNED' : (isActive ? 'ACTIVE' : 'INACTIVE'),
                  style: TextStyle(
                    color: isBanned ? Colors.red : (isActive ? Colors.green : Colors.orange),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip('Members', '$memberCount', Icons.people),
              const SizedBox(width: 8),
              _buildInfoChip('Level', '${family['current_level'] ?? 1}', Icons.star),
              const SizedBox(width: 8),
              _buildInfoChip('XP', '${family['total_xp'] ?? 0}', Icons.bolt),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
                ElevatedButton.icon(
                onPressed: () => _toggleFamilyStatus(family['familyId'], isActive),
                icon: Icon(isActive ? Icons.block : Icons.check_circle, size: 16),
                label: Text(isActive ? 'Deactivate' : 'Activate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              if (!isBanned)
                ElevatedButton.icon(
                  onPressed: () => _banFamily(family['familyId']),
                  icon: const Icon(Icons.gavel, size: 16),
                  label: const Text('Ban'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _deleteFamily(family['familyId']),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 4),
          Text('$label: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
          Text(value, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}