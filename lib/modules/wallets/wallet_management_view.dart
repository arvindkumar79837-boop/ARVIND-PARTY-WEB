import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class WalletManagementView extends StatefulWidget {
  const WalletManagementView({super.key});

  @override
  State<WalletManagementView> createState() => _WalletManagementViewState();
}

class _WalletManagementViewState extends State<WalletManagementView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = Get.find<ApiService>();

  var isLoading = false.obs;
  var totalCoins = 0.obs;
  var totalDiamonds = 0.obs;
  var todayRecharges = 0.obs;
  var pendingWithdrawalsCount = 0.obs;
  var familyTotalCoins = 0.obs;
  var familyTotalDiamonds = 0.obs;
  var agencyTotalBalance = 0.obs;
  var agencyTotalEarnings = 0.obs;
  var agencyTotalCommission = 0.obs;
  var totalFamilyEarnings = 0.obs;
  var totalTaxCollected = 0.obs;

  var withdrawals = <Map<String, dynamic>>[].obs;
  var allTransactions = <Map<String, dynamic>>[].obs;
  var taxRecords = <Map<String, dynamic>>[].obs;
  var withdrawalPage = 1.obs;
  var transactionPage = 1.obs;
  var taxPage = 1.obs;
  var selectedWithdrawalStatus = ''.obs;
  var selectedTransactionType = ''.obs;

  // User Search
  var userSearchQuery = TextEditingController();
  var selectedUser = Rxn<Map<String, dynamic>>();
  var searchResults = <Map<String, dynamic>>[].obs;
  var isSearchingUser = false.obs;

  // Wallet Adjustment
  var adjustmentCoins = TextEditingController();
  var adjustmentDiamonds = TextEditingController();
  var adjustmentReason = TextEditingController();
  var adjustmentWalletType = 'coin'.obs;

  // Config
  var configCoinRate = TextEditingController(text: '10');
  var configExchangeRate = TextEditingController(text: '100');
  var configMinWithdrawal = TextEditingController(text: '500');
  var configTaxPercentage = TextEditingController(text: '5');
  var configAgencyCommission = TextEditingController(text: '0.1');

  // Freeze/Unfreeze
  var freezeWalletType = 'coin'.obs;
  var freezeReason = TextEditingController();
  var freezeUserId = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    loadDashboardStats();
    loadAllWithdrawals();
    loadAllTransactions();
    loadTaxRecords();
  }

  void _onTabChanged() {}

  @override
  void dispose() {
    _tabController.dispose();
    userSearchQuery.dispose();
    adjustmentCoins.dispose();
    adjustmentDiamonds.dispose();
    adjustmentReason.dispose();
    configCoinRate.dispose();
    configExchangeRate.dispose();
    configMinWithdrawal.dispose();
    configTaxPercentage.dispose();
    configAgencyCommission.dispose();
    freezeReason.dispose();
    freezeUserId.dispose();
    super.dispose();
  }

  Future<void> loadDashboardStats() async {
    try {
      isLoading.value = true;
      final response = await _api.get('/wallet/admin/wallet/stats');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        totalCoins.value = data['totalCoins'] ?? 0;
        totalDiamonds.value = data['totalDiamonds'] ?? 0;
        todayRecharges.value = data['todayRecharges'] ?? 0;
        pendingWithdrawalsCount.value = data['pendingWithdrawals'] ?? 0;

        if (data['familyWallet'] != null) {
          familyTotalCoins.value = data['familyWallet']['totalCoins'] ?? 0;
          familyTotalDiamonds.value = data['familyWallet']['totalDiamonds'] ?? 0;
        }
        if (data['agencyWallet'] != null) {
          agencyTotalBalance.value = data['agencyWallet']['totalBalance'] ?? 0;
          agencyTotalEarnings.value = data['agencyWallet']['totalEarnings'] ?? 0;
          agencyTotalCommission.value = data['agencyWallet']['totalCommission'] ?? 0;
        }
        totalFamilyEarnings.value = data['totalFamilyEarnings'] ?? 0;
      }
    } catch (e) {
      debugPrint('Failed to load stats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchUser() async {
    final query = userSearchQuery.text.trim();
    if (query.length < 2) return;
    try {
      isSearchingUser.value = true;
      final response = await _api.get('/admin/users/search?q=$query');
      if (response['success'] == true && response['data'] != null) {
        searchResults.value = List<Map<String, dynamic>>.from(response['data']);
      }
    } catch (e) {
      debugPrint('User search failed: $e');
    } finally {
      isSearchingUser.value = false;
    }
  }

  Future<void> loadAllWithdrawals({bool reset = false}) async {
    try {
      if (reset) withdrawalPage.value = 1;
      final page = withdrawalPage.value;
      final params = <String>[];
      if (selectedWithdrawalStatus.value.isNotEmpty) params.add('status=${selectedWithdrawalStatus.value}');
      final query = params.isNotEmpty ? '?${params.join('&')}' : '';
      final response = await _api.get('/wallet/admin/withdrawals$query&page=$page&limit=50');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (reset) {
          withdrawals.assignAll(List<Map<String, dynamic>>.from(data));
        } else {
          withdrawals.addAll(List<Map<String, dynamic>>.from(data));
        }
      }
    } catch (e) {
      debugPrint('Failed to load withdrawals: $e');
    }
  }

  Future<void> loadAllTransactions({bool reset = false}) async {
    try {
      if (reset) transactionPage.value = 1;
      final page = transactionPage.value;
      final params = <String>[];
      if (selectedTransactionType.value.isNotEmpty) params.add('walletType=${selectedTransactionType.value}');
      final query = params.isNotEmpty ? '?${params.join('&')}' : '';
      final response = await _api.get('/wallet/admin/transactions$query&page=$page&limit=50');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (reset) {
          allTransactions.assignAll(List<Map<String, dynamic>>.from(data));
        } else {
          allTransactions.addAll(List<Map<String, dynamic>>.from(data));
        }
      }
    } catch (e) {
      debugPrint('Failed to load transactions: $e');
    }
  }

  Future<void> loadTaxRecords({bool reset = false}) async {
    try {
      if (reset) taxPage.value = 1;
      final page = taxPage.value;
      final response = await _api.get('/wallet/admin/wallet/tax-records?page=$page&limit=50');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        taxRecords.assignAll(List<Map<String, dynamic>>.from(data['transactions'] ?? []));
        totalTaxCollected.value = data['totalTaxCollected'] ?? 0;
      }
    } catch (e) {
      debugPrint('Failed to load tax records: $e');
    }
  }

  Future<void> adjustUserWallet() async {
    if (selectedUser.value == null) {
      Get.snackbar('Error', 'Please select a user first', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }
    final coins = int.tryParse(adjustmentCoins.text);
    final diamonds = int.tryParse(adjustmentDiamonds.text);
    if (coins == null && diamonds == null) {
      Get.snackbar('Error', 'Enter coin or diamond amount', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }
    try {
      isLoading.value = true;
      await _api.put('/wallet/admin/wallet/adjust', {
        'userId': selectedUser.value!['_id'],
        'coins': coins ?? 0,
        'diamonds': diamonds ?? 0,
        'reason': adjustmentReason.text,
        'walletType': adjustmentWalletType.value,
      });
      Get.snackbar('Success', 'Wallet adjusted successfully', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
      adjustmentCoins.clear();
      adjustmentDiamonds.clear();
      adjustmentReason.clear();
      loadDashboardStats();
    } catch (e) {
      Get.snackbar('Error', 'Adjustment failed: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveWithdrawal(String withdrawalId) async {
    try {
      isLoading.value = true;
      await _api.put('/wallet/admin/withdrawals/$withdrawalId/approve', {});
      Get.snackbar('Success', 'Withdrawal approved', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
      loadAllWithdrawals(reset: true);
      loadDashboardStats();
    } catch (e) {
      Get.snackbar('Error', 'Approval failed: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectWithdrawal(String withdrawalId) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Withdrawal'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Reason for rejection'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (note == null || note.isEmpty) return;
    try {
      isLoading.value = true;
      await _api.put('/wallet/admin/withdrawals/$withdrawalId/reject', {'note': note});
      Get.snackbar('Success', 'Withdrawal rejected', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
      loadAllWithdrawals(reset: true);
      loadDashboardStats();
    } catch (e) {
      Get.snackbar('Error', 'Rejection failed: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processWithdrawal(String withdrawalId) async {
    final controller = TextEditingController();
    final ref = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Process Withdrawal'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Payment Reference / UTR'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (ref == null || ref.isEmpty) return;
    try {
      isLoading.value = true;
      await _api.put('/wallet/admin/withdrawals/$withdrawalId/process', {'paymentReference': ref});
      Get.snackbar('Success', 'Withdrawal marked as paid', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
      loadAllWithdrawals(reset: true);
      loadDashboardStats();
    } catch (e) {
      Get.snackbar('Error', 'Processing failed: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateWalletConfig() async {
    try {
      isLoading.value = true;
      await _api.put('/wallet/admin/wallet/config', {
        'coinPackageRate': int.tryParse(configCoinRate.text) ?? 10,
        'exchangeRate': int.tryParse(configExchangeRate.text) ?? 100,
        'minWithdrawal': int.tryParse(configMinWithdrawal.text) ?? 500,
        'taxPercentage': int.tryParse(configTaxPercentage.text) ?? 5,
        'agencyCommissionRate': double.tryParse(configAgencyCommission.text) ?? 0.1,
      });
      Get.snackbar('Success', 'Configuration updated', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Update failed: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> freezeWallet() async {
    final userId = freezeUserId.text.trim();
    if (userId.isEmpty || freezeReason.text.trim().isEmpty) {
      Get.snackbar('Error', 'User ID and reason required', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }
    try {
      isLoading.value = true;
      await _api.post('/wallet/admin/wallet/freeze', {
        'userId': userId,
        'walletType': freezeWalletType.value,
        'reason': freezeReason.text,
      });
      Get.snackbar('Success', 'Wallet frozen', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
      freezeUserId.clear();
      freezeReason.clear();
    } catch (e) {
      Get.snackbar('Error', 'Freeze failed: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> unfreezeWallet() async {
    final userId = freezeUserId.text.trim();
    if (userId.isEmpty) {
      Get.snackbar('Error', 'User ID required', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }
    try {
      isLoading.value = true;
      await _api.post('/wallet/admin/wallet/unfreeze', {
        'userId': userId,
        'walletType': freezeWalletType.value,
        'reason': 'Manual unfreeze by admin',
      });
      Get.snackbar('Success', 'Wallet unfrozen', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
      freezeUserId.clear();
    } catch (e) {
      Get.snackbar('Error', 'Unfreeze failed: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Management - 4 Core Wallets'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
            Tab(text: 'Withdrawals', icon: Icon(Icons.money_off)),
            Tab(text: 'Transactions', icon: Icon(Icons.list_alt)),
            Tab(text: 'Tax & Safety', icon: Icon(Icons.security)),
            Tab(text: 'Settings', icon: Icon(Icons.settings)),
          ],
        ),
        actions: [
          IconButton(onPressed: loadDashboardStats, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Obx(() {
        if (isLoading.value && withdrawals.isEmpty && allTransactions.isEmpty && taxRecords.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return TabBarView(
          controller: _tabController,
          children: [
            _buildDashboardTab(),
            _buildWithdrawalsTab(),
            _buildTransactionsTab(),
            _buildTaxAndSafetyTab(),
            _buildSettingsTab(),
          ],
        );
      }),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: loadDashboardStats,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Coin & Diamond Stats
          const Text('Coin & Diamond Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _buildStatCard('Total Coins', totalCoins.value.toString(), Icons.monetization_on, Colors.amber)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Total Diamonds', totalDiamonds.value.toString(), Icons.diamond, Colors.cyan)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _buildStatCard('Today Recharges', todayRecharges.value.toString(), Icons.trending_up, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Pending Withdrawals', pendingWithdrawalsCount.value.toString(), Icons.pending_actions, Colors.orange)),
          ]),
          const SizedBox(height: 24),

          // Family Wallet Stats
          const Text('Family Wallet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _buildStatCard('Family Total Coins', familyTotalCoins.value.toString(), Icons.group, Colors.teal)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Family Total Diamonds', familyTotalDiamonds.value.toString(), Icons.group_work, Colors.teal.shade300)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _buildStatCard('Family Task Earnings', totalFamilyEarnings.value.toString(), Icons.task, Colors.indigo)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('', '', Icons.check, Colors.transparent)),
          ]),
          const SizedBox(height: 24),

          // Agency Wallet Stats
          const Text('Agency Wallet & Commission', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _buildStatCard('Agency Balance', agencyTotalBalance.value.toString(), Icons.account_balance, Colors.deepPurple)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Agency Earnings', agencyTotalEarnings.value.toString(), Icons.trending_up, Colors.deepPurple.shade300)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _buildStatCard('Total Commission', agencyTotalCommission.value.toString(), Icons.percent, Colors.blueGrey)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Total Tax Collected', totalTaxCollected.value.toString(), Icons.receipt_long, Colors.red.shade400)),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    if (color == Colors.transparent) return const SizedBox.shrink();
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedWithdrawalStatus.value.isEmpty ? null : selectedWithdrawalStatus.value,
                  decoration: const InputDecoration(labelText: 'Filter by Status', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All')),
                    DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                    DropdownMenuItem(value: 'PROCESSING', child: Text('Processing')),
                    DropdownMenuItem(value: 'APPROVED', child: Text('Approved')),
                    DropdownMenuItem(value: 'PAID', child: Text('Paid')),
                    DropdownMenuItem(value: 'REJECTED', child: Text('Rejected')),
                  ],
                  onChanged: (val) {
                    selectedWithdrawalStatus.value = val ?? '';
                    loadAllWithdrawals(reset: true);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: () => loadAllWithdrawals(reset: true), icon: const Icon(Icons.search)),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (withdrawals.isEmpty) return const Center(child: Text('No withdrawals found'));
            return ListView.builder(
              itemCount: withdrawals.length,
              itemBuilder: (ctx, i) {
                final w = withdrawals[i];
                final user = w['userId'] ?? {};
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(child: Text((user['name'] ?? 'U')[0].toUpperCase())),
                    title: Text(user['name'] ?? 'Unknown'),
                    subtitle: Text('Diamonds: ${w['diamondsRequested']} | INR: ₹${w['amountINR']} | Status: ${w['status']} | Stage: ${w['currentStage']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (w['currentStage'] == 'SELLER_REVIEW' || w['currentStage'] == 'MERCHANT_REVIEW' || w['currentStage'] == 'OWNER_FINANCE')
                          IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => approveWithdrawal(w['_id'])),
                        if (w['status'] == 'PENDING')
                          IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => rejectWithdrawal(w['_id'])),
                        if (w['status'] == 'APPROVED')
                          IconButton(icon: const Icon(Icons.payment, color: Colors.blue), onPressed: () => processWithdrawal(w['_id'])),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTransactionsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedTransactionType.value.isEmpty ? null : selectedTransactionType.value,
                  decoration: const InputDecoration(labelText: 'Filter by Wallet', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All Wallets')),
                    DropdownMenuItem(value: 'coin', child: Text('Coin Wallet')),
                    DropdownMenuItem(value: 'diamond', child: Text('Diamond Wallet')),
                    DropdownMenuItem(value: 'family', child: Text('Family Wallet')),
                    DropdownMenuItem(value: 'agency', child: Text('Agency Wallet')),
                  ],
                  onChanged: (val) {
                    selectedTransactionType.value = val ?? '';
                    loadAllTransactions(reset: true);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: () => loadAllTransactions(reset: true), icon: const Icon(Icons.search)),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (allTransactions.isEmpty) return const Center(child: Text('No transactions found'));
            return ListView.builder(
              itemCount: allTransactions.length,
              itemBuilder: (ctx, i) {
                final t = allTransactions[i];
                final user = t['userId'] ?? {};
                final walletType = t['walletType'] ?? 'coin';
                final isCredit = (t['amount'] ?? 0) > 0;

                IconData walletIcon;
                Color walletColor;
                switch (walletType) {
                  case 'diamond':
                    walletIcon = Icons.diamond;
                    walletColor = Colors.cyan;
                    break;
                  case 'family':
                    walletIcon = Icons.group;
                    walletColor = Colors.teal;
                    break;
                  case 'agency':
                    walletIcon = Icons.business;
                    walletColor = Colors.deepPurple;
                    break;
                  default:
                    walletIcon = Icons.monetization_on;
                    walletColor = Colors.amber;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: walletColor.withValues(alpha: 0.1),
                      child: Icon(walletIcon, color: walletColor),
                    ),
                    title: Text(t['description'] ?? 'Transaction'),
                    subtitle: Text('User: ${user['name'] ?? 'N/A'} | ${t['walletType']?.toString().toUpperCase() ?? ''} | ${t['createdAt']?.toString().substring(0, 10) ?? ''}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${isCredit ? '+' : '-'}${t['amount'] ?? 0}', style: TextStyle(color: isCredit ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                        if ((t['taxAmount'] ?? 0) > 0)
                          Text('Tax: ${t['taxAmount']}', style: const TextStyle(fontSize: 10, color: Colors.orange)),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTaxAndSafetyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Tax Records Section
        const Text('Tax Records (Withdrawal & Gift Tax)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildStatCard('Total Tax Collected', totalTaxCollected.value.toString(), Icons.receipt_long, Colors.orange),
        const SizedBox(height: 12),

        Obx(() {
          if (taxRecords.isEmpty) return const Center(child: Text('No tax records found'));
          return Column(
            children: taxRecords.take(10).map((t) {
              final user = t['userId'] ?? {};
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.receipt, color: Colors.orange),
                  title: Text(t['description'] ?? 'Tax deduction'),
                  subtitle: Text('User: ${user['name'] ?? 'N/A'} | ${t['createdAt']?.toString().substring(0, 10) ?? ''}'),
                  trailing: Text('-${t['amount'] ?? 0}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
          );
        }),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // Freeze/Unfreeze Wallet Section
        const Text('Wallet Freeze / Unfreeze (Safety Control)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        TextField(
          controller: freezeUserId,
          decoration: const InputDecoration(
            labelText: 'User ID (_id)',
            border: OutlineInputBorder(),
            hintText: 'Enter the MongoDB User ID',
          ),
        ),
        const SizedBox(height: 12),

        Obx(() => DropdownButtonFormField<String>(
          initialValue: freezeWalletType.value,
          decoration: const InputDecoration(labelText: 'Wallet Type', border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'coin', child: Text('Coin Wallet')),
            DropdownMenuItem(value: 'diamond', child: Text('Diamond Wallet')),
            DropdownMenuItem(value: 'family', child: Text('Family Wallet')),
            DropdownMenuItem(value: 'agency', child: Text('Agency Wallet')),
            DropdownMenuItem(value: 'all', child: Text('All Wallets')),
          ],
          onChanged: (val) {
            if (val != null) freezeWalletType.value = val;
          },
        )),
        const SizedBox(height: 12),

        TextField(
          controller: freezeReason,
          decoration: const InputDecoration(
            labelText: 'Freeze Reason',
            border: OutlineInputBorder(),
            hintText: 'Why is this wallet being frozen?',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: freezeWallet,
                icon: const Icon(Icons.lock),
                label: const Text('Freeze Wallet'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: unfreezeWallet,
                icon: const Icon(Icons.lock_open),
                label: const Text('Unfreeze Wallet'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        const Text('Note: Freezing coin/diamond wallet also blocks the user account. Family wallet freeze prevents family task rewards. Agency freeze prevents commission payouts.', style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Wallet Configuration
        const Text('Wallet Configuration (सभी 4 वॉलेट के लिए सेटिंग्स)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        const Text('Coin Package Rate (coins per ₹)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(controller: configCoinRate, decoration: const InputDecoration(border: OutlineInputBorder()), keyboardType: TextInputType.number),
        const SizedBox(height: 12),

        const Text('Diamond to Coin Exchange Rate', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(controller: configExchangeRate, decoration: const InputDecoration(border: OutlineInputBorder()), keyboardType: TextInputType.number),
        const SizedBox(height: 12),

        const Text('Minimum Withdrawal (diamonds/INR)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(controller: configMinWithdrawal, decoration: const InputDecoration(border: OutlineInputBorder()), keyboardType: TextInputType.number),
        const SizedBox(height: 12),

        const Text('Tax Percentage (%) on Withdrawals & Gifts', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(controller: configTaxPercentage, decoration: const InputDecoration(border: OutlineInputBorder()), keyboardType: TextInputType.number),
        const SizedBox(height: 12),

        const Text('Agency Commission Rate (e.g. 0.1 = 10%)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(controller: configAgencyCommission, decoration: const InputDecoration(border: OutlineInputBorder()), keyboardType: TextInputType.number),
        const SizedBox(height: 16),

        ElevatedButton(onPressed: updateWalletConfig, child: const Text('Update Configuration')),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),

        // User Search & Manual Adjustment
        const Text('Manual Wallet Adjustment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: userSearchQuery,
                decoration: const InputDecoration(
                  labelText: 'Search User by name/UID',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  if (val.length >= 2) searchUser();
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: searchUser, child: const Text('Search')),
          ],
        ),
        const SizedBox(height: 8),

        Obx(() {
          if (searchResults.isEmpty) return const SizedBox.shrink();
          return RadioGroup<Map<String, dynamic>>(
            groupValue: selectedUser.value,
            onChanged: (val) => selectedUser.value = val,
            child: Column(
              children: searchResults.map((u) => RadioListTile<Map<String, dynamic>>(
                title: Text('${u['name'] ?? 'N/A'} (${u['uid'] ?? ''})'),
                subtitle: Text('Coins: ${u['coins'] ?? 0} | Diamonds: ${u['diamonds'] ?? 0}'),
                value: u,
              )).toList(),
            ),
          );
        }),

        if (selectedUser.value != null) ...[
          const SizedBox(height: 12),
          Text('Selected: ${selectedUser.value!['name'] ?? 'N/A'} - ${selectedUser.value!['uid'] ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 12),

          Obx(() => DropdownButtonFormField<String>(
            initialValue: adjustmentWalletType.value,
            decoration: const InputDecoration(labelText: 'Target Wallet', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'coin', child: Text('Coin Wallet')),
              DropdownMenuItem(value: 'diamond', child: Text('Diamond Wallet')),
            ],
            onChanged: (val) {
              if (val != null) adjustmentWalletType.value = val;
            },
          )),
          const SizedBox(height: 12),

          TextField(controller: adjustmentCoins, decoration: const InputDecoration(labelText: 'Coins (+ add / - subtract)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: adjustmentDiamonds, decoration: const InputDecoration(labelText: 'Diamonds (+ add / - subtract)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: adjustmentReason, decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: adjustUserWallet, child: const Text('Adjust Selected User Wallet')),
        ],
      ],
    );
  }
}