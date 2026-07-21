import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class GiftEconomySettingsView extends StatefulWidget {
  const GiftEconomySettingsView({super.key});

  @override
  State<GiftEconomySettingsView> createState() => _GiftEconomySettingsViewState();
}

class _GiftEconomySettingsViewState extends State<GiftEconomySettingsView> {
  final _apiService = Get.find<ApiService>();
  final _giftRatioCtrl = TextEditingController();
  final _diamondPayoutCtrl = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await _apiService.get('/admin/system-settings');
      if (res['success'] == true) {
        final settings = Map<String, dynamic>.from(res['data'] ?? {});
        _giftRatioCtrl.text = (settings['gift_to_diamond_ratio'] ?? 1.0).toString();
        _diamondPayoutCtrl.text = (settings['diamond_to_payout_ratio'] ?? 1.0).toString();
      } else {
        _error = res['message'] ?? 'Failed to load settings';
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final giftRatio = double.tryParse(_giftRatioCtrl.text) ?? 1.0;
      final payoutRatio = double.tryParse(_diamondPayoutCtrl.text) ?? 1.0;
      await _apiService.put('/admin/system-settings/economy', {
        'gift_to_diamond_ratio': giftRatio,
        'diamond_to_payout_ratio': payoutRatio,
      });
      Get.snackbar('Saved', 'Economy settings updated', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
    if (mounted) setState(() => _isSaving = false);
  }

  double get _giftPreview {
    final ratio = double.tryParse(_giftRatioCtrl.text) ?? 1.0;
    return 1000 * ratio * 0.7;
  }

  double get _payoutPreview {
    final payout = double.tryParse(_diamondPayoutCtrl.text) ?? 1.0;
    return 1000 * payout;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Economy Settings'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSettings),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadSettings, child: const Text('Retry')),
                ]))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Economy Ratios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _giftRatioCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Gift → Diamond Ratio',
                                  hintText: 'e.g. 1.0',
                                  border: OutlineInputBorder(),
                                  suffixText: 'x',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _diamondPayoutCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Diamond → Payout Ratio',
                                  hintText: 'e.g. 0.5',
                                  border: OutlineInputBorder(),
                                  suffixText: '₹/diamond',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _saveSettings,
                                  icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
                                  label: const Text('Save Settings'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Live Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              _previewRow(
                                '1000 coin gift → receiver gets',
                                '${_giftPreview.toStringAsFixed(0)} diamonds',
                                Icons.card_giftcard,
                                Colors.deepPurple,
                              ),
                              const SizedBox(height: 12),
                              _previewRow(
                                '1000 diamonds withdrawal → staff gets',
                                '₹${_payoutPreview.toStringAsFixed(0)}',
                                Icons.account_balance_wallet,
                                Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _previewRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  @override
  void dispose() {
    _giftRatioCtrl.dispose();
    _diamondPayoutCtrl.dispose();
    super.dispose();
  }
}
