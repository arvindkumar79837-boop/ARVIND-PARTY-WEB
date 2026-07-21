// ═══════════════════════════════════════════════════════════════════════════
// FILE: arvind_party_web/lib/modules/pk_battle/pk_battle_management_view.dart
// ARVIND PARTY - Web Admin Panel: PK Battle Management
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class PkBattleManagementView extends StatefulWidget {
  const PkBattleManagementView({super.key});

  @override
  State<PkBattleManagementView> createState() => _PkBattleManagementViewState();
}

class _PkBattleManagementViewState extends State<PkBattleManagementView> {
  final ApiService _api = Get.find<ApiService>();
  final RxList<Map<String, dynamic>> battles = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedFilter = 'all'.obs;

  @override
  void initState() {
    super.initState();
    fetchBattles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PK Battle Management'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => fetchBattles(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return battles.isEmpty
                  ? const Center(
                      child: Text('No battles found', style: TextStyle(fontSize: 18, color: Colors.grey)))
                  : ListView.builder(
                      itemCount: battles.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) => _buildBattleCard(battles[index]),
                    );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('All', 'all'),
            const SizedBox(width: 8),
            _filterChip('Live', 'live'),
            const SizedBox(width: 8),
            _filterChip('Pending', 'pending'),
            const SizedBox(width: 8),
            _filterChip('Finished', 'finished'),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    return Obx(() => ChoiceChip(
      label: Text(label),
      selected: selectedFilter.value == value,
      onSelected: (_) {
        selectedFilter.value = value;
        fetchBattles(status: value);
      },
      selectedColor: Colors.deepPurple[300],
      labelStyle: TextStyle(
        color: selectedFilter.value == value ? Colors.white : Colors.black87,
      ),
    ));
  }

  Widget _buildBattleCard(Map<String, dynamic> battle) {
    final battleId = battle['_id'] ?? '';
    final hostName = battle['hostId']?['name'] ?? 'Unknown';
    final opponentName = battle['opponentId']?['name'] ?? 'Unknown';
    final status = battle['status'] ?? 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status),
          child: Icon(
            _getStatusIcon(status),
            color: Colors.white,
          ),
        ),
        title: Text('Battle ID: $battleId'),
        subtitle: Text('Host: $hostName vs Opponent: $opponentName'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == 'live')
              TextButton.icon(
                onPressed: () => _endBattle(battleId),
                icon: const Icon(Icons.stop_circle_outlined, size: 18),
                label: const Text('End Battle'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'live':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'finished':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'live':
        return Icons.flash_on;
      case 'pending':
        return Icons.hourglass_empty;
      case 'finished':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Future<void> fetchBattles({String status = 'all'}) async {
    isLoading.value = true;
    try {
      String endpoint = '/pk-battles';
      if (status != 'all') {
        endpoint += '?status=$status';
      }
      final response = await _api.get(endpoint);
      if (response['success'] == true) {
        final List<dynamic> battleList = response['data'] ?? [];
        battles.assignAll(battleList.map((e) => Map<String, dynamic>.from(e)).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch battles: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _endBattle(String battleId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('End Battle'),
        content: const Text('Are you sure you want to end this battle?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Battle'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await _api.post('/pk-battles/end', {'battleId': battleId});
        if (response['success'] == true) {
          Get.snackbar('Success', 'Battle has been ended.',
              backgroundColor: Colors.greenAccent, colorText: Colors.black);
          fetchBattles();
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to end battle',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    }
  }

}
