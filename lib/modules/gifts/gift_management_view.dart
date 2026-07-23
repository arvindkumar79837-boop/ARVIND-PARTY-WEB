// ═══════════════════════════════════════════════════════════════════════════
// FILE: arvind_party_web/lib/modules/gifts/gift_management_view.dart
// ARVIND PARTY - Web Admin Panel: Gift Store, Festival Gifts, Inventory, Ranking
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class GiftManagementView extends StatefulWidget {
  const GiftManagementView({super.key});

  @override
  State<GiftManagementView> createState() => _GiftManagementViewState();
}

class _GiftManagementViewState extends State<GiftManagementView> {
  final ApiService _api = Get.find<ApiService>();
  final RxList<Map<String, dynamic>> gifts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> leaderboard = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedTypeFilter = 'all'.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Management'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => _showLeaderboardDialog(context),
            tooltip: 'Gift Leaderboard',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateGiftDialog(context),
            tooltip: 'Create Gift',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => fetchGifts(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: Obx(() {
            if (isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (gifts.isEmpty) {
              return const Center(child: Text('No gifts found', style: TextStyle(fontSize: 18, color: Colors.grey)));
            }
            return ListView.builder(
              itemCount: gifts.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) => _buildGiftCard(context, gifts[index]),
            );
          })),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search gifts by name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true, fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => fetchGifts(search: searchController.text),
              ),
            ),
            onSubmitted: (v) => fetchGifts(search: v),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All', 'all'),
                const SizedBox(width: 6),
                _filterChip('STATIC', 'STATIC'),
                _filterChip('SVGA', 'SVGA'),
                _filterChip('3D', '3D'),
                _filterChip('LUCKY', 'LUCKY'),
                _filterChip('TREASURE', 'TREASURE'),
                _filterChip('VEHICLE', 'VEHICLE'),
                _filterChip('CASTLE', 'CASTLE'),
                _filterChip('FRAME', 'FRAME'),
                _filterChip('FESTIVAL', 'FESTIVAL'),
                _filterChip('COMBO', 'COMBO'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Obx(() => ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selectedTypeFilter.value == value,
        onSelected: (_) {
          selectedTypeFilter.value = value;
          if (value == 'all') {
            fetchGifts();
          } else {
            fetchGifts(type: value);
          }
        },
        selectedColor: Colors.deepOrange[300],
        labelStyle: TextStyle(color: selectedTypeFilter.value == value ? Colors.white : Colors.black87),
      )),
    );
  }

  Widget _buildGiftCard(BuildContext context, Map<String, dynamic> gift) {
    final id = gift['_id'] ?? '';
    final name = gift['giftName'] ?? 'Unnamed';
    final type = gift['giftType'] ?? 'STATIC';
    final category = gift['category'] ?? 'BASIC';
    final coinPrice = gift['coinPrice'] ?? 0;
    final diamondValue = gift['diamondValue'] ?? 0;
    final isAvailable = gift['isAvailable'] ?? true;
    final isLucky = gift['isLucky'] ?? false;
    final isTreasure = gift['isTreasure'] ?? false;
    final comboEnabled = gift['comboEnabled'] ?? false;
    final isLimitedEdition = gift['isLimitedEdition'] ?? false;
    final festivalName = gift['festivalName'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isAvailable ? Colors.green : Colors.red,
          child: Icon(
            _getGiftIcon(type),
            color: Colors.white, size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getGiftTypeColor(type),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(type, style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
            if (isLucky) ...[
              const SizedBox(width: 6),
              const Chip(label: Text('LUCKY', style: TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
            ],
            if (isTreasure) ...[
              const SizedBox(width: 6),
              const Chip(label: Text('TREASURE', style: TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact, backgroundColor: Colors.amber),
            ],
          ],
        ),
        subtitle: Text('\$${coinPrice.toInt()} coins | \$${diamondValue.toInt()} diamonds | $category'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (comboEnabled) ...[
                  Row(children: [
                    const Icon(Icons.flash_on, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text('Combo: ${gift['comboMultipliers']?.join('x, ') ?? ''}x',
                        style: const TextStyle(color: Colors.orange)),
                  ]),
                  const SizedBox(height: 4),
                ],
                if (isLucky) ...[
                  Row(children: [
                    const Icon(Icons.casino, size: 16, color: Colors.purple),
                    const SizedBox(width: 4),
                    Text('Lucky Multiplier: ${gift['luckyMultiplier']?.join('x, ') ?? ''}x',
                        style: const TextStyle(color: Colors.purple)),
                  ]),
                  const SizedBox(height: 4),
                ],
                if (isTreasure) ...[
                  Row(children: [
                    const Icon(Icons.inventory_2, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('Treasure Pool: ${gift['treasurePoolCoins'] ?? 0} coins | Duration: ${gift['treasureDurationSeconds'] ?? 30}s | Max Claimers: ${gift['treasureMaxClaimers'] ?? 10}'),
                  ]),
                  const SizedBox(height: 4),
                ],
                if (isLimitedEdition || festivalName.isNotEmpty) ...[
                  Row(children: [
                    const Icon(Icons.event, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text('Festival: $festivalName${isLimitedEdition ? " (Limited Edition)" : ""}',
                        style: const TextStyle(color: Colors.red)),
                  ]),
                  const SizedBox(height: 4),
                ],
                if (gift['frameId'] != null && gift['frameId'].isNotEmpty) ...[
                  Row(children: [
                    const Icon(Icons.filter_frames, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text('Frame: ${gift['frameId']} (${gift['frameDurationDays'] ?? 7} days)'),
                  ]),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Sort: ${gift['sortOrder'] ?? 0}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () => _toggleAvailability(id, isAvailable),
                      icon: Icon(isAvailable ? Icons.visibility_off : Icons.visibility, size: 18),
                      label: Text(isAvailable ? 'Disable' : 'Enable'),
                      style: TextButton.styleFrom(foregroundColor: isAvailable ? Colors.red : Colors.green),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showEditGiftDialog(context, gift),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _deleteGift(id, name),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGiftIcon(String type) {
    switch (type) {
      case 'SVGA': return Icons.animation;
      case '3D': return Icons.threed_rotation;
      case 'LUCKY': return Icons.casino;
      case 'TREASURE': return Icons.inventory_2;
      case 'VEHICLE': return Icons.directions_car;
      case 'CASTLE': return Icons.account_balance;
      case 'FRAME': return Icons.filter_frames;
      case 'AVATAR': return Icons.face;
      case 'FESTIVAL': return Icons.celebration;
      case 'COMBO': return Icons.flash_on;
      default: return Icons.card_giftcard;
    }
  }

  Color _getGiftTypeColor(String type) {
    switch (type) {
      case 'SVGA': return Colors.purple;
      case '3D': return Colors.indigo;
      case 'LUCKY': return Colors.orange;
      case 'TREASURE': return Colors.amber;
      case 'VEHICLE': return Colors.blue;
      case 'CASTLE': return Colors.brown;
      case 'FRAME': return Colors.pink;
      case 'AVATAR': return Colors.teal;
      case 'FESTIVAL': return Colors.red;
      case 'COMBO': return Colors.deepOrange;
      default: return Colors.grey;
    }
  }

  Future<void> fetchGifts({String? type, String? search}) async {
    isLoading.value = true;
    try {
      final query = <String, dynamic>{};
      if (type != null) query['type'] = type;
      if (search != null && search.isNotEmpty) query['search'] = search;

      final response = await _api.get('/gifts', query: query);
      if (response['success'] == true) {
        final List<dynamic> giftList = response['gifts'] ?? response['data'] ?? [];
        gifts.assignAll(giftList.map((e) => Map<String, dynamic>.from(e)).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch gifts: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _toggleAvailability(String giftId, bool current) async {
    try {
      final response = await _api.put('/gifts/admin/$giftId', {'isAvailable': !current});
      if (response['success'] == true) {
        Get.snackbar('Updated', 'Gift ${current ? "disabled" : "enabled"}',
            backgroundColor: Colors.greenAccent, colorText: Colors.black);
        fetchGifts();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle gift', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> _deleteGift(String giftId, String name) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Gift'),
        content: Text('Permanently delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _api.delete('/gifts/admin/$giftId');
        Get.snackbar('Deleted', 'Gift deleted successfully',
            backgroundColor: Colors.greenAccent, colorText: Colors.black);
        fetchGifts();
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete gift', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    }
  }

  void _showCreateGiftDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController(text: '10');
    final diamondController = TextEditingController(text: '7');
    final sortController = TextEditingController(text: '0');
    String selectedType = 'STATIC';
    String selectedCategory = 'BASIC';
    bool isLucky = false;
    bool isTreasure = false;

    bool isLimitedEdition = false;
    final treasurePoolController = TextEditingController(text: '1000');
    final treasureDurationController = TextEditingController(text: '30');
    final treasureClaimersController = TextEditingController(text: '10');

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Gift'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Gift Name *', border: OutlineInputBorder())),
                  const SizedBox(height: 8),
                  TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 2),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Coin Price *', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: diamondController, decoration: const InputDecoration(labelText: 'Diamond Value', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Gift Type', border: OutlineInputBorder()),
                      items: 'STATIC,ANIMATED,SVGA,3D,LUCKY,TREASURE,VEHICLE,CASTLE,FRAME,AVATAR,FESTIVAL,COMBO'.split(',').map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setDialogState(() => selectedType = v ?? 'STATIC'),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      items: 'HOT,BASIC,PREMIUM,LUXURY,VIP,LUCKY,FESTIVAL'.split(',').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setDialogState(() => selectedCategory = v ?? 'BASIC'),
                    )),
                  ]),
                  const SizedBox(height: 8),
                  TextField(controller: sortController, decoration: const InputDecoration(labelText: 'Sort Order', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Lucky Gift'),
                    value: isLucky,
                    onChanged: (v) => setDialogState(() => isLucky = v ?? false),
                    dense: true,
                  ),
                  if (isLucky)
                    const Text('Lucky multipliers will be set to [1, 5, 10, 100, 500] by default',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  CheckboxListTile(
                    title: const Text('Treasure Gift'),
                    value: isTreasure,
                    onChanged: (v) => setDialogState(() => isTreasure = v ?? false),
                    dense: true,
                  ),
                  if (isTreasure) ...[
                    TextField(controller: treasurePoolController, decoration: const InputDecoration(labelText: 'Pool Coins', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    Row(children: [
                      Expanded(child: TextField(controller: treasureDurationController, decoration: const InputDecoration(labelText: 'Duration (sec)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: treasureClaimersController, decoration: const InputDecoration(labelText: 'Max Claimers', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                    ]),
                  ],
                  CheckboxListTile(
                    title: const Text('Limited Edition / Festival'),
                    value: isLimitedEdition,
                    onChanged: (v) => setDialogState(() => isLimitedEdition = v ?? false),
                    dense: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  Get.snackbar('Error', 'Gift name required', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }
                try {
                  final body = <String, dynamic>{
                    'giftName': nameController.text.trim(),
                    'description': descController.text.trim(),
                    'coinPrice': int.tryParse(priceController.text) ?? 10,
                    'diamondValue': int.tryParse(diamondController.text) ?? 7,
                    'giftType': selectedType,
                    'category': selectedCategory,
                    'sortOrder': int.tryParse(sortController.text) ?? 0,
                    'isLucky': isLucky,
                    'isTreasure': isTreasure,
                    'isLimitedEdition': isLimitedEdition,
                    'isAvailable': true,
                    'isActive': true,
                  };
                  if (isTreasure) {
                    body['treasurePoolCoins'] = int.tryParse(treasurePoolController.text) ?? 1000;
                    body['treasureDurationSeconds'] = int.tryParse(treasureDurationController.text) ?? 30;
                    body['treasureMaxClaimers'] = int.tryParse(treasureClaimersController.text) ?? 10;
                  }
                  final response = await _api.post('/gifts/admin/create', body);
                  if (response['success'] == true) {
                    Get.back();
                    Get.snackbar('Created', 'Gift created successfully',
                        backgroundColor: Colors.greenAccent, colorText: Colors.black);
                    fetchGifts();
                  }
                } catch (e) {
                  Get.snackbar('Error', 'Failed to create gift: $e',
                      backgroundColor: Colors.redAccent, colorText: Colors.white);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              child: const Text('Create Gift', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGiftDialog(BuildContext context, Map<String, dynamic> gift) {
    final nameController = TextEditingController(text: gift['giftName'] ?? '');
    final priceController = TextEditingController(text: '${gift['coinPrice'] ?? 0}');
    final diamondController = TextEditingController(text: '${gift['diamondValue'] ?? 0}');
    final sortController = TextEditingController(text: '${gift['sortOrder'] ?? 0}');
    String selectedType = gift['giftType'] ?? 'STATIC';
    final giftId = gift['_id'] ?? '';

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Gift'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Gift Name', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Coin Price', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: diamondController, decoration: const InputDecoration(labelText: 'Diamond Value', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                  items: 'STATIC,ANIMATED,SVGA,3D,LUCKY,TREASURE,VEHICLE,CASTLE,FRAME,AVATAR,FESTIVAL,COMBO'.split(',').map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => selectedType = v ?? 'STATIC',
                )),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: sortController, decoration: const InputDecoration(labelText: 'Sort Order', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await _api.put('/gifts/admin/$giftId', {
                  'giftName': nameController.text.trim(),
                  'coinPrice': int.tryParse(priceController.text) ?? 0,
                  'diamondValue': int.tryParse(diamondController.text) ?? 0,
                  'giftType': selectedType,
                  'sortOrder': int.tryParse(sortController.text) ?? 0,
                });
                Get.back();
                Get.snackbar('Updated', 'Gift updated successfully',
                    backgroundColor: Colors.greenAccent, colorText: Colors.black);
                fetchGifts();
              } catch (e) {
                Get.snackbar('Error', 'Failed to update gift',
                    backgroundColor: Colors.redAccent, colorText: Colors.white);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLeaderboardDialog(BuildContext context) {
    fetchLeaderboard();


    Get.dialog(
      AlertDialog(
        title: const Text('Gift Leaderboard'),
        content: SizedBox(
          width: 500, height: 400,
          child: Obx(() {
            if (leaderboard.isEmpty) return const Center(child: Text('No data yet'));
            return ListView.builder(
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                final rank = index + 1;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rank <= 3 ? Colors.amber : Colors.grey[300],
                    child: Text('$rank', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: rank <= 3 ? Colors.white : Colors.black87,
                    )),
                  ),
                  title: Text(entry['userName'] ?? 'Unknown'),
                  subtitle: Text('Quantity: ${entry['totalQuantity'] ?? 0} | Spent: \$${entry['totalSpent'] ?? 0}'),
                  trailing: Text('${entry['uniqueGiftsCount'] ?? 0} unique',
                      style: const TextStyle(color: Colors.grey)),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> fetchLeaderboard() async {
    try {
      final response = await _api.get('/gifts/leaderboard', query: {'type': 'sender', 'limit': '50'});
      if (response['success'] == true) {
        final List<dynamic> data = response['leaderboard'] ?? response['data'] ?? [];
        leaderboard.assignAll(data.map((e) => Map<String, dynamic>.from(e)).toList());
      }
    } catch (e) {
      debugPrint('Leaderboard fetch error: $e');
    }
  }

}
