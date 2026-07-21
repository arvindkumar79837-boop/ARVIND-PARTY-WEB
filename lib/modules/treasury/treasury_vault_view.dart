// ═══════════════════════════════════════════════════════════════════════════
// VIEW: TreasuryVaultView — Coin Vault Management (Owner-only minting/dispatch)
// Full UI for the global coin vault
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class TreasuryVaultView extends StatefulWidget {
  const TreasuryVaultView({super.key});

  @override
  State<TreasuryVaultView> createState() => _TreasuryVaultViewState();
}

class _TreasuryVaultViewState extends State<TreasuryVaultView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  bool _isLoading = true;
  Map<String, dynamic> _vaultData = {};
  final _mintAmountController = TextEditingController();
  final _mintReasonController = TextEditingController();
  final _dispatchAmountController = TextEditingController();
  final _dispatchUidController = TextEditingController();
  final _dispatchReasonController = TextEditingController();
  final _burnAmountController = TextEditingController();
  final _burnReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVault();
  }

  Future<void> _loadVault() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/treasury/vault');
      if (response['success'] == true) {
        _vaultData = response['data'] ?? {};
      }
    } catch (e) {
      // Handle error
    }
    setState(() => _isLoading = false);
  }

  Future<void> _mintCoins() async {
    final amount = int.tryParse(_mintAmountController.text) ?? 0;
    if (amount <= 0) return;

    try {
      await _apiService.post('/treasury/vault/mint', {
        'amount': amount,
        'reason': _mintReasonController.text,
      });
      _mintAmountController.clear();
      _mintReasonController.clear();
      _loadVault();
      Get.snackbar('Success', '$amount coins minted', backgroundColor: Colors.green);
    } catch (e) {
      Get.snackbar('Error', 'Mint failed', backgroundColor: Colors.red);
    }
  }

  Future<void> _dispatchCoins() async {
    final amount = int.tryParse(_dispatchAmountController.text) ?? 0;
    final sellerUid = _dispatchUidController.text.trim();
    if (amount <= 0 || sellerUid.isEmpty) return;

    try {
      await _apiService.post('/treasury/vault/dispatch', {
        'amount': amount,
        'sellerUid': sellerUid,
        'reason': _dispatchReasonController.text,
      });
      _dispatchAmountController.clear();
      _dispatchUidController.clear();
      _dispatchReasonController.clear();
      _loadVault();
      Get.snackbar('Success', '$amount coins dispatched to $sellerUid', backgroundColor: Colors.green);
    } catch (e) {
      Get.snackbar('Error', 'Dispatch failed', backgroundColor: Colors.red);
    }
  }

  Future<void> _burnCoins() async {
    final amount = int.tryParse(_burnAmountController.text) ?? 0;
    if (amount <= 0) return;

    try {
      await _apiService.post('/treasury/vault/burn', {
        'amount': amount,
        'reason': _burnReasonController.text,
      });
      _burnAmountController.clear();
      _burnReasonController.clear();
      _loadVault();
      Get.snackbar('Success', '$amount coins burned', backgroundColor: Colors.orange);
    } catch (e) {
      Get.snackbar('Error', 'Burn failed', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canMint = _permService.hasPermission('treasury.mint');
    final canDispatch = _permService.hasPermission('treasury.dispatch');
    final canBurn = _permService.hasPermission('treasury.burn');

    return Scaffold(
      appBar: AppBar(title: const Text('Coin Vault Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── VAULT OVERVIEW ──────────────────────────────
                  _buildOverviewCard(),
                  const SizedBox(height: 24),

                  // ─── ACTIONS GRID ─────────────────────────────────
                  if (canMint || canDispatch || canBurn)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (canMint) Expanded(child: _buildMintCard()),
                        if (canMint && canDispatch) const SizedBox(width: 16),
                        if (canDispatch) Expanded(child: _buildDispatchCard()),
                        if ((canMint || canDispatch) && canBurn) const SizedBox(width: 16),
                        if (canBurn) Expanded(child: _buildBurnCard()),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vault Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Minted', '${_vaultData['totalCoinsMinted'] ?? 0}', Colors.green),
                _buildStatItem('Total Dispatched', '${_vaultData['totalCoinsDispatched'] ?? 0}', Colors.blue),
                _buildStatItem('Total Burned', '${_vaultData['totalCoinsBurned'] ?? 0}', Colors.orange),
                _buildStatItem('Current Balance', '${_vaultData['currentBalance'] ?? 0}', Colors.amber),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMintCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mint Coins', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 12),
            TextField(
              controller: _mintAmountController,
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _mintReasonController,
              decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _mintCoins,
                icon: const Icon(Icons.add_circle),
                label: const Text('Mint Coins'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDispatchCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dispatch to Seller', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 12),
            TextField(
              controller: _dispatchUidController,
              decoration: const InputDecoration(labelText: 'Seller UID', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dispatchAmountController,
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dispatchReasonController,
              decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _dispatchCoins,
                icon: const Icon(Icons.send),
                label: const Text('Dispatch'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBurnCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Burn Coins', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 12),
            TextField(
              controller: _burnAmountController,
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _burnReasonController,
              decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _burnCoins,
                icon: const Icon(Icons.remove_circle),
                label: const Text('Burn Coins'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}