// ═══════════════════════════════════════════════════════════════════════════
// VIEW: RewardInjectorView — UID-targeted asset injection for VIP frames/effects
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class RewardInjectorView extends StatefulWidget {
  const RewardInjectorView({super.key});

  @override
  State<RewardInjectorView> createState() => _RewardInjectorViewState();
}

class _RewardInjectorViewState extends State<RewardInjectorView> {
  final _apiService = Get.find<ApiService>();

  final _targetUidController = TextEditingController();
  final _reasonController = TextEditingController();
  final _assetTypeController = TextEditingController();
  final _assetIdController = TextEditingController();
  final _assetNameController = TextEditingController();
  final _assetUrlController = TextEditingController();
  final _durationDaysController = TextEditingController();

  final List<Map<String, dynamic>> _assets = [];
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _targetUidController.dispose();
    _reasonController.dispose();
    _assetTypeController.dispose();
    _assetIdController.dispose();
    _assetNameController.dispose();
    _assetUrlController.dispose();
    _durationDaysController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/admin/rewards/history');
      if (response['success'] == true) {
        _history = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading reward history: $e');
    }
    setState(() => _isLoading = false);
  }

  void _addAsset() {
    final assetType = _assetTypeController.text.trim().toLowerCase();
    final validTypes = ['vip_frame', 'entry_effect', 'mount', 'badge', 'avatar_decoration', 'chat_bubble', 'seat_frame'];

    if (!validTypes.contains(assetType)) {
      Get.snackbar('Error', 'Invalid asset type. Valid: ${validTypes.join(', ')}', backgroundColor: Colors.red);
      return;
    }

    if (_assetIdController.text.trim().isEmpty || _assetNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Asset ID and Name required', backgroundColor: Colors.red);
      return;
    }

    setState(() {
      _assets.add({
        'assetType': assetType,
        'assetId': _assetIdController.text.trim(),
        'assetName': _assetNameController.text.trim(),
        'assetUrl': _assetUrlController.text.trim(),
        'durationDays': int.tryParse(_durationDaysController.text) ?? 0,
      });
    });

    _assetTypeController.clear();
    _assetIdController.clear();
    _assetNameController.clear();
    _assetUrlController.clear();
    _durationDaysController.clear();
  }

  void _removeAsset(int index) {
    setState(() => _assets.removeAt(index));
  }

  Future<void> _injectRewards() async {
    if (_targetUidController.text.trim().isEmpty || _assets.isEmpty) {
      Get.snackbar('Error', 'Target UID and at least one asset required', backgroundColor: Colors.red);
      return;
    }

    try {
      await _apiService.post('/admin/rewards/inject', {
        'targetUid': _targetUidController.text.trim(),
        'assets': _assets,
        'reason': _reasonController.text.trim(),
      });
      Get.snackbar('Success', 'Assets injected to ${_targetUidController.text}', backgroundColor: Colors.green);
      _assets.clear();
      _targetUidController.clear();
      _reasonController.clear();
      _loadHistory();
    } catch (e) {
      Get.snackbar('Error', 'Injection failed', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reward Injector')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── INJECTION FORM ──────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Inject Assets to UID', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _targetUidController,
                      decoration: const InputDecoration(labelText: 'Target UID', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reasonController,
                      decoration: const InputDecoration(labelText: 'Reason/Occasion', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text('Add Asset', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _assetTypeController,
                            decoration: const InputDecoration(labelText: 'Type (vip_frame, entry_effect, mount, badge, avatar_decoration, chat_bubble, seat_frame)', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _assetIdController, decoration: const InputDecoration(labelText: 'Asset ID', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _assetNameController, decoration: const InputDecoration(labelText: 'Asset Name', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _assetUrlController, decoration: const InputDecoration(labelText: 'Asset URL (optional)', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _durationDaysController, decoration: const InputDecoration(labelText: 'Duration Days (0=permanent)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _addAsset,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Asset'),
                    ),
                    if (_assets.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('Assets to inject:', style: TextStyle(fontWeight: FontWeight.w600)),
                      ..._assets.asMap().entries.map((entry) => ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Text('${entry.value['assetName']} (${entry.value['assetType']})'),
                        subtitle: Text('ID: ${entry.value['assetId']} | Duration: ${entry.value['durationDays']}d'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeAsset(entry.key),
                        ),
                      )),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _injectRewards,
                        icon: const Icon(Icons.auto_awesome),
                        label: Text('Inject ${_assets.length} Asset(s)'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, padding: const EdgeInsets.all(16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── INJECTION HISTORY ───────────────────────────────
            const Text('Injection History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                    ? const Text('No injections yet')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.card_giftcard, color: Colors.purple),
                              title: Text('UID: ${item['targetUid'] ?? ''}'),
                              subtitle: Text('${(item['assets'] as List).length} assets | ${item['reason'] ?? ''}'),
                              trailing: Text(item['isActive'] == true ? 'Active' : 'Revoked',
                                style: TextStyle(color: item['isActive'] == true ? Colors.green : Colors.red)),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}