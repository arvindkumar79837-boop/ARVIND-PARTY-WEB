// ═══════════════════════════════════════════════════════════════════════════
// VIEW: TargetManagerView — Streamer targets & 50-50 exchange approval
// Weekly, 15-Day, Monthly cycles
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class TargetManagerView extends StatefulWidget {
  const TargetManagerView({super.key});

  @override
  State<TargetManagerView> createState() => _TargetManagerViewState();
}

class _TargetManagerViewState extends State<TargetManagerView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _targets = [];
  bool _isLoading = true;
  String _filter = 'all';

  final _streamerUidController = TextEditingController();
  final _cycleTypeController = TextEditingController();
  final _targetDiamondsController = TextEditingController();
  final _autoCycleTypeController = TextEditingController();
  final _autoDiamondsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTargets();
  }

  @override
  void dispose() {
    _streamerUidController.dispose();
    _cycleTypeController.dispose();
    _targetDiamondsController.dispose();
    _autoCycleTypeController.dispose();
    _autoDiamondsController.dispose();
    super.dispose();
  }

  Future<void> _loadTargets() async {
    setState(() => _isLoading = true);
    try {
      final queryParams = <String, String>{};
      if (_filter == 'met') queryParams['isTargetMet'] = 'true';
      if (_filter == 'settled') queryParams['isSettled'] = 'true';
      if (_filter == 'pending') {
        queryParams['isTargetMet'] = 'true';
        queryParams['isSettled'] = 'false';
      }

      final response = await _apiService.get('/targets', queryParams: queryParams);
      if (response['success'] == true) {
        _targets = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading targets: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _createTarget() async {
    final streamerUid = _streamerUidController.text.trim();
    final cycleType = _cycleTypeController.text.trim();
    final targetDiamonds = int.tryParse(_targetDiamondsController.text) ?? 0;

    if (streamerUid.isEmpty || cycleType.isEmpty || targetDiamonds <= 0) {
      Get.snackbar('Error', 'All fields required', backgroundColor: Colors.red);
      return;
    }

    try {
      await _apiService.post('/targets/create', {
        'streamerUid': streamerUid,
        'cycleType': cycleType,
        'targetDiamonds': targetDiamonds,
      });
      _streamerUidController.clear();
      _cycleTypeController.clear();
      _targetDiamondsController.clear();
      Get.snackbar('Success', 'Target created', backgroundColor: Colors.green);
      _loadTargets();
    } catch (e) {
      Get.snackbar('Error', 'Creation failed', backgroundColor: Colors.red);
    }
  }

  Future<void> _approveExchange(String targetId, int requestIndex) async {
    try {
      await _apiService.post('/targets/approve-exchange/$targetId/$requestIndex', {});
      Get.snackbar('Success', 'Exchange approved', backgroundColor: Colors.green);
      _loadTargets();
    } catch (e) {
      Get.snackbar('Error', 'Approval failed', backgroundColor: Colors.red);
    }
  }

  Future<void> _autoCreateCycles() async {
    final cycleType = _autoCycleTypeController.text.trim();
    final targetDiamonds = int.tryParse(_autoDiamondsController.text) ?? 0;

    if (cycleType.isEmpty || targetDiamonds <= 0) {
      Get.snackbar('Error', 'Cycle type and target diamonds required', backgroundColor: Colors.red);
      return;
    }

    try {
      final response = await _apiService.post('/targets/auto-cycle', {
        'cycleType': cycleType,
        'targetDiamonds': targetDiamonds,
      });
      final count = response['data']?['count'] ?? 0;
      Get.snackbar('Success', 'Auto-created $count cycles', backgroundColor: Colors.green);
      _loadTargets();
    } catch (e) {
      Get.snackbar('Error', 'Auto-cycle failed', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = _permService.hasPermission('targets.create');
    final canApprove = _permService.hasPermission('targets.approve_exchange');
    final canAutoCycle = _permService.hasPermission('targets.auto_cycle');

    return Scaffold(
      appBar: AppBar(title: const Text('Streamer Targets & 50-50 Split')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── FILTERS ─────────────────────────────────────────
            Row(
              children: [
                const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('All')),
                    ButtonSegment(value: 'met', label: Text('Target Met')),
                    ButtonSegment(value: 'pending', label: Text('Pending Exchange')),
                    ButtonSegment(value: 'settled', label: Text('Settled')),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (v) { setState(() => _filter = v.first); _loadTargets(); },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── CREATE TARGET (Owner/Admin) ─────────────────────
            if (canCreate)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Create New Target', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: TextField(controller: _streamerUidController, decoration: const InputDecoration(labelText: 'Streamer UID', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _cycleTypeController, decoration: const InputDecoration(labelText: 'Cycle (weekly/fifteen_day/monthly)', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _targetDiamondsController, decoration: const InputDecoration(labelText: 'Target Diamonds', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        ElevatedButton(onPressed: _createTarget, child: const Text('Create')),
                      ]),
                    ],
                  ),
                ),
              ),
            if (canCreate) const SizedBox(height: 16),

            // ─── AUTO CYCLE (Owner/Admin) ────────────────────────
            if (canAutoCycle)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Auto-Create Cycles for All Streamers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: TextField(controller: _autoCycleTypeController, decoration: const InputDecoration(labelText: 'Cycle Type', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _autoDiamondsController, decoration: const InputDecoration(labelText: 'Target Diamonds', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        ElevatedButton(onPressed: _autoCreateCycles, child: const Text('Auto-Create')),
                      ]),
                    ],
                  ),
                ),
              ),
            if (canAutoCycle) const SizedBox(height: 16),

            // ─── TARGETS LIST ────────────────────────────────────
            const Text('Targets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _targets.isEmpty
                    ? const Text('No targets found')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _targets.length,
                        itemBuilder: (context, index) {
                          final target = _targets[index];
                          final progress = target['progress'] ?? {};
                          final settlement = target['settlement'] ?? {};
                          final cycle = target['cycle'] ?? {};
                          final exchanges = List<Map<String, dynamic>>.from(target['diamondExchangeRequests'] ?? []);
                          final pendingExchanges = exchanges.where((e) => e['status'] == 'pending').toList();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ExpansionTile(
                              leading: Icon(
                                target['isTargetMet'] == true ? Icons.check_circle : Icons.pending,
                                color: target['isTargetMet'] == true ? Colors.green : Colors.orange,
                              ),
                              title: Text('Streamer: ${target['streamerUid'] ?? ''}'),
                              subtitle: Text('${cycle['cycleType'] ?? ''} | ${progress['percentComplete'] ?? 0}% complete | ${settlement['isSettled'] == true ? "Settled" : "Not Settled"}'),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Target: ${cycle['targetDiamonds'] ?? 0} diamonds'),
                                      Text('Progress: ${progress['currentDiamonds'] ?? 0}/${cycle['targetDiamonds'] ?? 0} diamonds'),
                                      LinearProgressIndicator(value: (progress['percentComplete'] ?? 0) / 100),
                                      const SizedBox(height: 8),
                                      Text('Revenue: ${settlement['totalRevenue'] ?? 0} | Platform: ${settlement['platformShare'] ?? 0} | Streamer: ${settlement['streamerShare'] ?? 0}'),
                                      if (pendingExchanges.isNotEmpty && canApprove) ...[
                                        const SizedBox(height: 8),
                                        const Text('Pending Exchanges:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ...pendingExchanges.asMap().entries.map((entry) => ListTile(
                                          dense: true,
                                          title: Text('${entry.value['diamondAmount']} diamonds → ${entry.value['coinAmount']} coins'),
                                          trailing: ElevatedButton(
                                            onPressed: () => _approveExchange(target['_id'], exchanges.indexOf(entry.value)),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                            child: const Text('Approve'),
                                          ),
                                        )),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
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