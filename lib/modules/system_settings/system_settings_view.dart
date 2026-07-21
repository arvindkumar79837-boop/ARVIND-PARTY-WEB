import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arvind_party_web/modules/shared/admin_shell.dart';
import 'package:arvind_party_web/core/services/api_service.dart';

class SystemSettingsView extends StatefulWidget {
  const SystemSettingsView({super.key});

  @override
  State<SystemSettingsView> createState() => _SystemSettingsViewState();
}

class _SystemSettingsViewState extends State<SystemSettingsView> {
  final _api = Get.find<ApiService>();
  Map<String, dynamic> _settings = {};
  bool _isLoading = true;
  bool _isSaving = false;

  final _roomLockCostCtrl = TextEditingController();
  final _roomLockDurationCtrl = TextEditingController();
  final _minDiamondWithdrawalCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final resp = await _api.dio.get('/economy/settings');
      if (resp.data['success'] == true) {
        _settings = Map<String, dynamic>.from(resp.data['data'] ?? {});
      }
    } catch (e) { debugPrint('Error: $e'); }
    _roomLockCostCtrl.text = (_settings['room_lock_cost'] ?? 50).toString();
    _roomLockDurationCtrl.text = (_settings['room_lock_duration_hours'] ?? 6).toString();
    _minDiamondWithdrawalCtrl.text = (_settings['diamond_withdrawal_min'] ?? 50).toString();
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final updates = {
        'room_lock_cost': int.tryParse(_roomLockCostCtrl.text) ?? 50,
        'room_lock_duration_hours': int.tryParse(_roomLockDurationCtrl.text) ?? 6,
        'diamond_withdrawal_min': int.tryParse(_minDiamondWithdrawalCtrl.text) ?? 50,
      };
      await _api.dio.put('/economy/settings', data: {'updates': updates});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved'), backgroundColor: Color(0xFF4CAF50)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings, color: Color(0xFFFF8906), size: 28),
                SizedBox(width: 12),
                Text('System Settings', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSection('🔒 Room Lock', [
                        _buildNumberField('Room Lock Cost (coins)', _roomLockCostCtrl, 'Coins required to lock a room'),
                        _buildNumberField('Lock Duration (hours)', _roomLockDurationCtrl, 'Default lock duration'),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection('💎 Diamond Withdrawal', [
                        _buildNumberField('Minimum Diamond Withdrawal', _minDiamondWithdrawalCtrl, 'Min diamonds to request withdrawal'),
                      ]),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveSettings,
                          icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
                          label: const Text('Save Settings'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906), foregroundColor: Colors.white),
                        ),
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

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController ctrl, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(color: Colors.white54),
          hintText: hint, hintStyle: const TextStyle(color: Colors.white24),
          filled: true, fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF8906))),
        ),
      ),
    );
  }
}
