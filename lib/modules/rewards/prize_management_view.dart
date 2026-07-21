// ═══════════════════════════════════════════════════════════════════════════
// VIEW: PrizeManagementView — Manage reward items and probabilities
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class PrizeManagementView extends StatefulWidget {
  final String configId;
  
  const PrizeManagementView({super.key, required this.configId});

  @override
  State<PrizeManagementView> createState() => _PrizeManagementViewState();
}

class _PrizeManagementViewState extends State<PrizeManagementView> {
  final _apiService = Get.find<ApiService>();
  
  List<Map<String, dynamic>> _prizes = [];
  List<Map<String, dynamic>> _tiers = [];
  bool _isLoading = false;
  Map<String, dynamic>? _config;

  // Form controllers
  final _itemNameController = TextEditingController();
  final _itemIdController = TextEditingController();
  final _itemValueController = TextEditingController(text: '0');
  final _probabilityController = TextEditingController(text: '10');
  final _weightController = TextEditingController(text: '10');
  final _assetUrlController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();

  String _selectedItemType = 'coins';
  String _selectedTier = 'common';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemIdController.dispose();
    _itemValueController.dispose();
    _probabilityController.dispose();
    _weightController.dispose();
    _assetUrlController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  /// Load prizes and tiers
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load config details
      final configResponse = await _apiService.get('/admin/reward-configs/${widget.configId}');
      if (configResponse['success'] == true) {
        setState(() => _config = configResponse['data']);
        _prizes = List<Map<String, dynamic>>.from(_config?['rewardItems'] ?? []);
      }

      // Load tiers
      final tiersResponse = await _apiService.get('/admin/reward-configs/tiers');
      if (tiersResponse['success'] == true) {
        _tiers = List<Map<String, dynamic>>.from(tiersResponse['data'] ?? []);
      }

      _sortPrizes();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: $e', backgroundColor: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Sort prizes by tier
  void _sortPrizes() {
    final tierOrder = {'common': 0, 'uncommon': 1, 'rare': 2, 'epic': 3, 'legendary': 4, 'mythic': 5};
    _prizes.sort((a, b) {
      final tierA = tierOrder[a['tier'] ?? 'common'] ?? 0;
      final tierB = tierOrder[b['tier'] ?? 'common'] ?? 0;
      return tierA.compareTo(tierB);
    });
  }

  /// Validate total probability
  double get _totalProbability {
    return _prizes.fold(0.0, (sum, prize) => sum + (prize['probability']?.toDouble() ?? 0.0));
  }

  /// Check if probabilities sum to 100
  bool get _isProbabilityValid {
    return (_totalProbability - 100.0).abs() < 0.01;
  }

  /// Add new prize
  Future<void> _addPrize() async {
    if (_itemNameController.text.isEmpty) {
      Get.snackbar('Error', 'Item name is required', backgroundColor: Colors.red);
      return;
    }

    if (_itemIdController.text.isEmpty) {
      Get.snackbar('Error', 'Item ID is required', backgroundColor: Colors.red);
      return;
    }

    final newProbability = double.tryParse(_probabilityController.text) ?? 0;
    if (newProbability <= 0 || newProbability > 100) {
      Get.snackbar('Error', 'Probability must be between 0 and 100', backgroundColor: Colors.red);
      return;
    }

    // Check if total would exceed 100%
    final newTotal = _totalProbability + newProbability;
    if (newTotal > 100.01) {
      Get.snackbar(
        'Error',
        'Total probability would exceed 100%. Current: ${_totalProbability.toStringAsFixed(1)}%',
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      final newPrize = {
        'itemId': _itemIdController.text,
        'itemName': _itemNameController.text,
        'itemType': _selectedItemType,
        'itemValue': int.tryParse(_itemValueController.text) ?? 0,
        'probability': newProbability,
        'weight': int.tryParse(_weightController.text) ?? 10,
        'tier': _selectedTier,
        'assetUrl': _assetUrlController.text,
        'thumbnailUrl': _thumbnailUrlController.text,
        'isActive': true,
        'isJackpot': false,
      };

      setState(() {
        _prizes.add(newPrize);
        _sortPrizes();
      });

      _clearForm();
      Get.snackbar('Success', 'Prize added', backgroundColor: Colors.green);
      
      // Auto-save
      await _savePrizes();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add prize: $e', backgroundColor: Colors.red);
    }
  }

  /// Delete prize
  Future<void> _deletePrize(int index) async {
    final confirm = await Get.dialog(
      AlertDialog(
        title: const Text('Delete Prize'),
        content: Text('Are you sure you want to delete "${_prizes[index]['itemName']}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _prizes.removeAt(index);
    });

    Get.snackbar('Success', 'Prize deleted', backgroundColor: Colors.green);
    await _savePrizes();
  }

  /// Save prizes to backend
  Future<void> _savePrizes() async {
    try {
      await _apiService.put('/admin/reward-configs/${widget.configId}', {
        'rewardItems': _prizes,
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e', backgroundColor: Colors.red);
    }
  }

  /// Clear form
  void _clearForm() {
    _itemNameController.clear();
    _itemIdController.clear();
    _itemValueController.text = '0';
    _probabilityController.text = '10';
    _weightController.text = '10';
    _assetUrlController.clear();
    _thumbnailUrlController.clear();
    _selectedItemType = 'coins';
    _selectedTier = 'common';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prize Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          if (!_isProbabilityValid)
            IconButton(
              icon: const Icon(Icons.warning, color: Colors.orange),
              onPressed: () => Get.snackbar(
                'Warning',
                'Total probability must equal 100%. Current: ${_totalProbability.toStringAsFixed(1)}%',
                backgroundColor: Colors.orange,
              ),
            ),
        ],
      ),
      body: Row(
        children: [
          // Left panel - Prize list
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Probability indicator
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isProbabilityValid 
                        ? Colors.green.withValues(alpha: 0.1) 
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isProbabilityValid ? Colors.green : Colors.orange,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Probability',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_totalProbability.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _isProbabilityValid ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _totalProbability / 100.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isProbabilityValid ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

                // Prize list
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _prizes.isEmpty
                          ? const Center(child: Text('No prizes configured'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _prizes.length,
                              itemBuilder: (context, index) {
                                final prize = _prizes[index];
                                return _buildPrizeCard(prize, index);
                              },
                            ),
                ),
              ],
            ),
          ),

          // Right panel - Add prize form
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add New Prize',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _itemNameController,
                        decoration: const InputDecoration(
                          labelText: 'Prize Name *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _itemIdController,
                        decoration: const InputDecoration(
                          labelText: 'Prize ID *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedItemType,
                        decoration: const InputDecoration(
                          labelText: 'Prize Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'coins', child: Text('Coins')),
                          DropdownMenuItem(value: 'diamonds', child: Text('Diamonds')),
                          DropdownMenuItem(value: 'xp', child: Text('XP')),
                          DropdownMenuItem(value: 'frame', child: Text('Frame')),
                          DropdownMenuItem(value: 'badge', child: Text('Badge')),
                          DropdownMenuItem(value: 'mount', child: Text('Mount')),
                          DropdownMenuItem(value: 'entry_effect', child: Text('Entry Effect')),
                          DropdownMenuItem(value: 'avatar_decoration', child: Text('Avatar Decoration')),
                          DropdownMenuItem(value: 'chat_bubble', child: Text('Chat Bubble')),
                          DropdownMenuItem(value: 'seat_frame', child: Text('Seat Frame')),
                          DropdownMenuItem(value: 'vip_days', child: Text('VIP Days')),
                          DropdownMenuItem(value: 'rocket', child: Text('Rocket')),
                          DropdownMenuItem(value: 'entry_car', child: Text('Entry Car')),
                          DropdownMenuItem(value: 'nothing', child: Text('Nothing')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedItemType = value ?? 'coins');
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _itemValueController,
                        decoration: const InputDecoration(
                          labelText: 'Prize Value',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedTier,
                        decoration: const InputDecoration(
                          labelText: 'Rarity Tier',
                          border: OutlineInputBorder(),
                        ),
                        items: _tiers.map<DropdownMenuItem<String>>((tier) {
                          return DropdownMenuItem<String>(
                            value: tier['rarity'] as String,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(tier['color'].replaceAll('#', '0xFF'))),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(tier['label'] as String),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedTier = value ?? 'common');
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _probabilityController,
                        decoration: const InputDecoration(
                          labelText: 'Probability (%)',
                          border: OutlineInputBorder(),
                          helperText: 'Must total 100% with all prizes',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: 'Weight (for randomization)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _assetUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Asset URL (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _thumbnailUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Thumbnail URL (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addPrize,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Prize'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeCard(Map<String, dynamic> prize, int index) {
    final tier = prize['tier'] ?? 'common';
    final tierColor = _getTierColor(tier);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: tierColor.withValues(alpha: 0.2),
          child: Icon(
            _getPrizeIcon(prize['itemType']),
            color: tierColor,
            size: 20,
          ),
        ),
        title: Text(
          prize['itemName'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${prize['itemType']} | Value: ${prize['itemValue']}'),
            Text('Probability: ${prize['probability']?.toStringAsFixed(1) ?? '0'}% | Weight: ${prize['weight'] ?? 10}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tierColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tier.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: tierColor,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _deletePrize(index),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'common': return Colors.grey;
      case 'uncommon': return Colors.green;
      case 'rare': return Colors.blue;
      case 'epic': return Colors.purple;
      case 'legendary': return Colors.orange;
      case 'mythic': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getPrizeIcon(String? type) {
    switch (type) {
      case 'coins': return Icons.monetization_on;
      case 'diamonds': return Icons.diamond;
      case 'xp': return Icons.trending_up;
      case 'frame': return Icons.photo;
      case 'badge': return Icons.verified;
      case 'mount': return Icons.directions_bike;
      case 'entry_effect': return Icons.auto_awesome;
      case 'avatar_decoration': return Icons.brush;
      case 'chat_bubble': return Icons.chat_bubble;
      case 'seat_frame': return Icons.event_seat;
      case 'vip_days': return Icons.card_membership;
      case 'rocket': return Icons.rocket_launch;
      case 'entry_car': return Icons.drive_eta;
      default: return Icons.card_giftcard;
    }
  }
}