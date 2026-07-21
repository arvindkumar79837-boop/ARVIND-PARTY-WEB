import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class FamilyRewardsConfigView extends StatefulWidget {
  final String familyId;
  final String familyName;

  const FamilyRewardsConfigView({
    super.key,
    required this.familyId,
    required this.familyName,
  });

  @override
  State<FamilyRewardsConfigView> createState() => _FamilyRewardsConfigViewState();
}

class _FamilyRewardsConfigViewState extends State<FamilyRewardsConfigView> {
  final _apiService = Get.find<ApiService>();
  bool _isLoading = true;
  bool _isSaving = false;

  final _top1Controller = TextEditingController();
  final _top2Controller = TextEditingController();
  final _top3Controller = TextEditingController();
  final _stayCoinsController = TextEditingController();
  final _stayXpController = TextEditingController();
  bool _customRewardsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _top1Controller.dispose();
    _top2Controller.dispose();
    _top3Controller.dispose();
    _stayCoinsController.dispose();
    _stayXpController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/families/rewards/config');
      if (response['success'] == true) {
        final config = response['data'] as Map<String, dynamic>? ?? {};
        setState(() {
          _top1Controller.text = config['top1_reward'] ?? 'Gold Crown + 5000 Coins';
          _top2Controller.text = config['top2_reward'] ?? 'Silver Crown + 3000 Coins';
          _top3Controller.text = config['top3_reward'] ?? 'Bronze Crown + 1000 Coins';
          _stayCoinsController.text = (config['stay_reward_coins_per_5min'] ?? 10).toString();
          _stayXpController.text = (config['stay_reward_xp_per_5min'] ?? 5).toString();
          _customRewardsEnabled = config['custom_rewards_enabled'] ?? false;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load config: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);
    try {
      final response = await _apiService.put(
        '/families/rewards/config',
        {
          'top1_reward': _top1Controller.text.trim(),
          'top2_reward': _top2Controller.text.trim(),
          'top3_reward': _top3Controller.text.trim(),
          'stay_reward_coins_per_5min': int.tryParse(_stayCoinsController.text.trim()) ?? 10,
          'stay_reward_xp_per_5min': int.tryParse(_stayXpController.text.trim()) ?? 5,
          'custom_rewards_enabled': _customRewardsEnabled,
        },
      );
      if (response['success'] == true) {
        Get.snackbar('Success', 'Reward configuration saved!');
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to save');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save config: $e');
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('Rewards: ${widget.familyName}', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF252542),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveConfig,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save', style: TextStyle(color: Color(0xFFFF8906), fontWeight: FontWeight.bold)),
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
                  _buildSectionHeader('🏆 Top 3 Heroes Rewards', 'Set rewards for top contributors'),
                  const SizedBox(height: 16),
                  _buildRewardField('🥇 Top 1 Reward', 'Gold Crown + 5000 Coins', _top1Controller),
                  const SizedBox(height: 12),
                  _buildRewardField('🥈 Top 2 Reward', 'Silver Crown + 3000 Coins', _top2Controller),
                  const SizedBox(height: 12),
                  _buildRewardField('🥉 Top 3 Reward', 'Bronze Crown + 1000 Coins', _top3Controller),
                  const SizedBox(height: 32),
                  _buildSectionHeader('🛋️ Stay Reward Settings', 'Auto-rewards for members staying in the official room'),
                  const SizedBox(height: 16),
                  _buildNumberField('Coins per 5 min', '10', _stayCoinsController),
                  const SizedBox(height: 12),
                  _buildNumberField('XP per 5 min', '5', _stayXpController),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252542),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('Enable Custom Rewards', style: TextStyle(color: Colors.white)),
                        const Spacer(),
                        Switch(
                          value: _customRewardsEnabled,
                          onChanged: (val) => setState(() => _customRewardsEnabled = val),
                          activeThumbColor: const Color(0xFFFF8906),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '💡 Tip: Stay rewards are given every 5 minutes when family members sit on seats in the official family room.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildRewardField(String label, String hint, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252542),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1A1A2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(String label, String hint, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252542),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1A1A2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}