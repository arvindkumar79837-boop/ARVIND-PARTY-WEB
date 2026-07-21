// ═══════════════════════════════════════════════════════════════════════════
// VIEW: RewardConfigAdminView — Admin interface for managing dynamic rewards
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class RewardConfigAdminView extends StatefulWidget {
  const RewardConfigAdminView({super.key});

  @override
  State<RewardConfigAdminView> createState() => _RewardConfigAdminViewState();
}

class _RewardConfigAdminViewState extends State<RewardConfigAdminView> {
  final _apiService = Get.find<ApiService>();
  
  List<Map<String, dynamic>> _configs = [];
  List<Map<String, dynamic>> _filteredConfigs = [];
  bool _isLoading = false;
  String _selectedGameType = 'all';
  String _searchQuery = '';
  Map<String, dynamic>? _selectedConfig;

  // Form controllers
  final _configNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _spinCostController = TextEditingController(text: '100');
  final _maxSpinsController = TextEditingController(text: '10');
  final _totalSpinsController = TextEditingController(text: '1000');
  final _jackpotPrizeController = TextEditingController(text: '10000');
  final _jackpotRateController = TextEditingController(text: '0.01');

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  @override
  void dispose() {
    _configNameController.dispose();
    _descriptionController.dispose();
    _spinCostController.dispose();
    _maxSpinsController.dispose();
    _totalSpinsController.dispose();
    _jackpotPrizeController.dispose();
    _jackpotRateController.dispose();
    super.dispose();
  }

  /// Load all reward configurations
  Future<void> _loadConfigs() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/admin/reward-configs');
      if (response['success'] == true) {
        _configs = List<Map<String, dynamic>>.from(response['data'] ?? []);
        _applyFilters();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load configs: $e', backgroundColor: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Apply filters to configs list
  void _applyFilters() {
    setState(() {
      _filteredConfigs = _configs.where((config) {
        final matchesGameType = _selectedGameType == 'all' || 
                                config['gameType'] == _selectedGameType;
        final matchesSearch = _searchQuery.isEmpty ||
                             (config['configName'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesGameType && matchesSearch;
      }).toList();
    });
  }

  /// Create new reward configuration
  Future<void> _createConfig() async {
    if (_configNameController.text.isEmpty) {
      Get.snackbar('Error', 'Config name is required', backgroundColor: Colors.red);
      return;
    }

    try {
      final payload = {
        'configName': _configNameController.text,
        'gameType': _selectedGameType == 'all' ? 'lucky_spin' : _selectedGameType,
        'description': _descriptionController.text,
        'spinCostCoins': int.tryParse(_spinCostController.text) ?? 100,
        'maxSpinsPerUser': int.tryParse(_maxSpinsController.text) ?? 10,
        'totalSpinsAllowed': int.tryParse(_totalSpinsController.text) ?? 1000,
        'jackpotPrize': {
          'prizeValue': int.tryParse(_jackpotPrizeController.text) ?? 10000,
          'prizeName': 'JACKPOT',
        },
        'jackpotTriggerRate': double.tryParse(_jackpotRateController.text) ?? 0.01,
        'rewardItems': [],
        'startTime': DateTime.now().toIso8601String(),
        'endTime': DateTime(2099, 12, 31).toIso8601String(),
      };

      final response = await _apiService.post('/admin/reward-configs', payload);
      if (response['success'] == true) {
        Get.snackbar('Success', 'Config created', backgroundColor: Colors.green);
        _clearForm();
        _loadConfigs();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create config: $e', backgroundColor: Colors.red);
    }
  }

  /// Deploy config as active
  Future<void> _deployConfig(String configId) async {
    try {
      final response = await _apiService.post('/admin/reward-configs/$configId/deploy', {});
      if (response['success'] == true) {
        Get.snackbar('Success', 'Config deployed successfully', backgroundColor: Colors.green);
        _loadConfigs();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to deploy: $e', backgroundColor: Colors.red);
    }
  }

  /// Delete configuration
  Future<void> _deleteConfig(String configId) async {
    final confirm = await Get.dialog(
      AlertDialog(
        title: const Text('Delete Config'),
        content: const Text('Are you sure you want to delete this configuration?'),
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

    try {
      final response = await _apiService.delete('/admin/reward-configs/$configId');
      if (response['success'] == true) {
        Get.snackbar('Success', 'Config deleted', backgroundColor: Colors.green);
        _loadConfigs();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e', backgroundColor: Colors.red);
    }
  }

  /// Clear form
  void _clearForm() {
    _configNameController.clear();
    _descriptionController.clear();
    _spinCostController.text = '100';
    _maxSpinsController.text = '10';
    _totalSpinsController.text = '1000';
    _jackpotPrizeController.text = '10000';
    _jackpotRateController.text = '0.01';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Configuration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConfigs,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left panel - Config list
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Filters
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _searchQuery = value;
                          _applyFilters();
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedGameType,
                        decoration: const InputDecoration(
                          labelText: 'Game Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All')),
                          DropdownMenuItem(value: 'lucky_spin', child: Text('Lucky Spin')),
                          DropdownMenuItem(value: 'treasure_hunt', child: Text('Treasure Hunt')),
                          DropdownMenuItem(value: 'scratch_card', child: Text('Scratch Card')),
                          DropdownMenuItem(value: 'custom', child: Text('Custom')),
                        ],
                        onChanged: (value) {
                          _selectedGameType = value ?? 'all';
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                ),
                
                // Config list
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredConfigs.isEmpty
                          ? const Center(child: Text('No configurations found'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredConfigs.length,
                              itemBuilder: (context, index) {
                                final config = _filteredConfigs[index];
                                return _buildConfigCard(config);
                              },
                            ),
                ),
              ],
            ),
          ),

          // Right panel - Config details / editors
          Expanded(
            flex: 2,
            child: _selectedConfig == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.settings, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Select a configuration to view details',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _buildConfigEditor(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(),
        tooltip: 'Create New Config',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildConfigCard(Map<String, dynamic> config) {
    final isActive = config['isActive'] == true;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isActive ? Colors.green.withValues(alpha: 0.1) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.green : Colors.grey,
          child: Icon(
            config['gameType'] == 'lucky_spin' ? Icons.casino
                : config['gameType'] == 'treasure_hunt' ? Icons.search
                : Icons.card_giftcard,
            color: Colors.white,
          ),
        ),
        title: Text(
          config['configName'] ?? 'Unnamed',
          style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${config['gameType']}'),
            Text('v${config['version'] ?? '1.0.0'}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive)
              const Chip(
                label: Text('ACTIVE', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              ),
            const SizedBox(height: 4),
            IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.green),
              onPressed: () => _deployConfig(config['_id']),
              tooltip: 'Deploy',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteConfig(config['_id']),
              tooltip: 'Delete',
            ),
          ],
        ),
        onTap: () {
          setState(() => _selectedConfig = config);
        },
      ),
    );
  }

  Widget _buildConfigEditor() {
    final config = _selectedConfig!;
    final isActive = config['isActive'] == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  config['configName'] ?? 'Configuration',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              if (!isActive)
                ElevatedButton.icon(
                  onPressed: () => _deployConfig(config['_id']),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Deploy'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isActive)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Currently Active', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Basic info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text('Game Type: ${config['gameType']}'),
                  Text('Version: ${config['version'] ?? '1.0.0'}'),
                  Text('Status: ${isActive ? "Active" : "Inactive"}'),
                  if (config['description'] != null) ...[
                    const SizedBox(height: 8),
                    Text('Description: ${config['description']}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Economy settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Economy Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text('Entry Fee: ${config['spinCostCoins'] ?? 0} coins'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Max Spins Per User: ${config['maxSpinsPerUser'] ?? 0}'),
                  Text('Total Spins Allowed: ${config['totalSpinsAllowed'] ?? 0}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Analytics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Economy Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text('Total Spins Used: ${config['totalSpinsUsed'] ?? 0}'),
                  Text('Total Winners: ${config['totalWinners'] ?? 0}'),
                  Row(
                    children: [
                      const Text('Total Coins In: ', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '${config['totalCoinsIn'] ?? 0}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Total Rewards Out: ', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '${config['totalRewardsOut'] ?? 0}',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (config['totalCoinsIn'] != null && config['totalCoinsIn'] > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'ROI: ${((config['totalCoinsIn'] - config['totalRewardsOut']) / config['totalCoinsIn'] * 100).toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (config['totalCoinsIn'] - config['totalRewardsOut']) / config['totalCoinsIn'] > 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show create config dialog
  void _showCreateDialog() {
    _selectedGameType = 'lucky_spin';
    _clearForm();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Create Reward Configuration'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _configNameController,
                decoration: const InputDecoration(
                  labelText: 'Config Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: 'lucky_spin',
                decoration: const InputDecoration(
                  labelText: 'Game Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'lucky_spin', child: Text('Lucky Spin')),
                  DropdownMenuItem(value: 'treasure_hunt', child: Text('Treasure Hunt')),
                  DropdownMenuItem(value: 'scratch_card', child: Text('Scratch Card')),
                ],
                onChanged: (value) {
                  _selectedGameType = value ?? 'lucky_spin';
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _spinCostController,
                decoration: const InputDecoration(
                  labelText: 'Spin Cost (coins)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _maxSpinsController,
                decoration: const InputDecoration(
                  labelText: 'Max Spins Per User',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _totalSpinsController,
                decoration: const InputDecoration(
                  labelText: 'Total Spins Allowed',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _jackpotPrizeController,
                decoration: const InputDecoration(
                  labelText: 'Jackpot Prize',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _jackpotRateController,
                decoration: const InputDecoration(
                  labelText: 'Jackpot Trigger Rate (0-1)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _createConfig();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}