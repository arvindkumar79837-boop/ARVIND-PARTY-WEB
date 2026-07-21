import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arvind_party_web/modules/shared/admin_shell.dart';
import 'package:arvind_party_web/core/services/api_service.dart';
import 'package:arvind_party_web/core/constants/auth_controller.dart';

class SubscriptionTiersView extends StatefulWidget {
  const SubscriptionTiersView({super.key});

  @override
  State<SubscriptionTiersView> createState() => _SubscriptionTiersViewState();
}

class _SubscriptionTiersViewState extends State<SubscriptionTiersView> {
  final _api = Get.find<ApiService>();
  final _auth = Get.find<AuthController>();
  List<Map<String, dynamic>> _tiers = [];
  List<Map<String, dynamic>> _subscribers = [];
  bool _isLoading = true;
  bool _showSubscribers = false;

  @override
  void initState() {
    super.initState();
    _loadTiers();
  }

  Future<void> _loadTiers() async {
    setState(() => _isLoading = true);
    try {
      final resp = await _api.dio.get('/subscriptions/tiers');
      if (resp.data['success'] == true) {
        _tiers = List<Map<String, dynamic>>.from(resp.data['data'] ?? []);
        _tiers.sort((a, b) => (a['sortOrder'] ?? 0).compareTo(b['sortOrder'] ?? 0));
      }
    } catch (e) {
      debugPrint('loadTiers error: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadSubscribers() async {
    try {
      final resp = await _api.dio.get('/admin/subscriptions/active');
      if (resp.data['success'] == true) {
        _subscribers = List<Map<String, dynamic>>.from(resp.data['data'] ?? []);
      }
    } catch (e) { debugPrint('Error: $e'); }
    setState(() => _showSubscribers = true);
  }

  Future<void> _createTier() async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '30');
    final coinsCtrl = TextEditingController(text: '0');
    final badgeCtrl = TextEditingController();
    final effectCtrl = TextEditingController();
    final multiplierCtrl = TextEditingController(text: '1.0');
    final descCtrl = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Create Subscription Tier', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(ctx, nameCtrl, 'Tier Name (Silver/Gold/Royal)'),
              _dialogField(ctx, priceCtrl, 'Price (INR)', isNumber: true),
              _dialogField(ctx, durationCtrl, 'Duration (days)', isNumber: true),
              _dialogField(ctx, coinsCtrl, 'Monthly Coins', isNumber: true),
              _dialogField(ctx, badgeCtrl, 'Badge Icon ID'),
              _dialogField(ctx, effectCtrl, 'Entrance Effect ID'),
              _dialogField(ctx, multiplierCtrl, 'XP Multiplier (1.0-5.0)'),
              _dialogField(ctx, descCtrl, 'Description'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, {
              'tierName': nameCtrl.text, 'priceINR': priceCtrl.text,
              'durationDays': durationCtrl.text, 'monthlyCoins': coinsCtrl.text,
              'badgeIcon': badgeCtrl.text, 'entranceEffectId': effectCtrl.text,
              'levelUpMultiplier': multiplierCtrl.text, 'description': descCtrl.text,
            }),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906)),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result['tierName']!.isNotEmpty) {
      try {
        await _api.dio.post('/subscriptions/tiers', data: {
          'tierName': result['tierName'],
          'priceINR': double.tryParse(result['priceINR']!) ?? 0,
          'durationDays': int.tryParse(result['durationDays']!) ?? 30,
          'perks': {
            'monthlyCoins': int.tryParse(result['monthlyCoins']!) ?? 0,
            'badgeIcon': result['badgeIcon'],
            'entranceEffectId': result['entranceEffectId'],
            'levelUpMultiplier': double.tryParse(result['levelUpMultiplier']!) ?? 1.0,
          },
          'description': result['description'],
        });
        _loadTiers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteTier(String tierId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Delete Tier?', style: TextStyle(color: Colors.white)),
        content: const Text('Active subscribers will keep access until expiry.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _api.dio.delete('/subscriptions/tiers/$tierId');
        _loadTiers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFF8906), size: 28),
                const SizedBox(width: 12),
                const Text('Subscription Tiers', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () { _loadSubscribers(); },
                  icon: const Icon(Icons.people, size: 18),
                  label: const Text('View Subscribers'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white70),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _createTier,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Tier'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906), foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
            else if (_showSubscribers)
              _buildSubscribersList()
            else
              Expanded(child: _buildTiersList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTiersList() {
    if (_tiers.isEmpty) {
      return const Center(child: Text('No tiers created yet', style: TextStyle(color: Colors.white38)));
    }
    return ListView.builder(
      itemCount: _tiers.length,
      itemBuilder: (ctx, i) {
        final tier = _tiers[i];
        final perks = Map<String, dynamic>.from(tier['perks'] ?? {});
        final tierColor = tier['tierName'] == 'Royal' ? const Color(0xFF9C27B0) : tier['tierName'] == 'Gold' ? const Color(0xFFFFB300) : const Color(0xFF90A4AE);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tierColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [tierColor, tierColor.withValues(alpha: 0.5)]),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Text(tier['tierName'] == 'Royal' ? '👑' : tier['tierName'] == 'Gold' ? '🥇' : '🥈', style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tier['tierName'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          Text('${tier['durationDays']} days • ₹${tier['priceINR']}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _deleteTier(tier['_id']),
                      icon: const Icon(Icons.delete, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _perkChip('🪙', '${perks['monthlyCoins'] ?? 0} coins/mo'),
                    _perkChip('🏷️', 'Badge: ${perks['badgeIcon'] ?? '-'}'),
                    _perkChip('✨', 'Effect: ${perks['entranceEffectId'] ?? '-'}'),
                    _perkChip('⚡', '${perks['levelUpMultiplier'] ?? 1}x XP'),
                    _perkChip('👥', '+${perks['friendLimitBoost'] ?? 0} friends'),
                    _perkChip('🚗', 'Vehicle: ${perks['luxuryVehicleEffectId'] ?? '-'}'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubscribersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Active Subscribers', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(onPressed: () => setState(() => _showSubscribers = false), icon: const Icon(Icons.arrow_back), label: const Text('Back to Tiers')),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _subscribers.isEmpty
              ? const Center(child: Text('No active subscribers', style: TextStyle(color: Colors.white38)))
              : ListView.builder(
                  itemCount: _subscribers.length,
                  itemBuilder: (ctx, i) {
                    final sub = _subscribers[i];
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: const Color(0xFFFF8906).withValues(alpha: 0.2), child: Text((sub['userName'] ?? '?')[0].toUpperCase(), style: const TextStyle(color: Color(0xFFFF8906)))),
                      title: Text(sub['userName'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${sub['tierName']} • Expires: ${sub['expiresAt']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _perkChip(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
      child: Text('$emoji $label', style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }

  static Widget _dialogField(BuildContext ctx, TextEditingController ctrl, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(color: Colors.white54),
          filled: true, fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
