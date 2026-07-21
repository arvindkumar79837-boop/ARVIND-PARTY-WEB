import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class CoinOrdersView extends StatefulWidget {
  const CoinOrdersView({super.key});

  @override
  State<CoinOrdersView> createState() => _CoinOrdersViewState();
}

class _CoinOrdersViewState extends State<CoinOrdersView> {
  final _apiService = Get.find<ApiService>();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/admin/coin-orders');
      if (response['success'] == true) {
        _orders = List<Map<String, dynamic>>.from(response['data'] ?? response['orders'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading coin orders: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coin Orders')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No coin orders found'))
              : ListView.builder(
                  itemCount: _orders.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (ctx, i) {
                    final o = _orders[i];
                    final user = o['userId'] ?? {};
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(user['name'] ?? 'Unknown'),
                        subtitle: Text('Coins: ${o['coins'] ?? 0} | Amount: ₹${o['amount'] ?? 0} | Status: ${o['status'] ?? 'PENDING'}'),
                      ),
                    );
                  },
                ),
    );
  }
}
