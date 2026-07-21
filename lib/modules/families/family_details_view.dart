// ═══════════════════════════════════════════════════════════════════════════
// VIEW: FamilyDetailsView — Admin panel: view and manage a single family
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../family_management/family_rewards_config_view.dart';
import '../family_management/family_admin_slots_view.dart';

class FamilyDetailsView extends StatefulWidget {
  final String familyId;

  const FamilyDetailsView({super.key, required this.familyId});

  @override
  State<FamilyDetailsView> createState() => _FamilyDetailsViewState();
}

class _FamilyDetailsViewState extends State<FamilyDetailsView> {
  final _apiService = Get.find<ApiService>();
  Map<String, dynamic>? _family;
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFamilyDetails();
  }

  Future<void> _loadFamilyDetails() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/families/${widget.familyId}/details');
      if (response['success'] == true) {
        setState(() {
          _family = Map<String, dynamic>.from(response['data'] ?? {});
          _members = List<Map<String, dynamic>>.from(_family!['members'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Error loading family details: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Family Details', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF252542),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadFamilyDetails,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
          : _family == null
              ? const Center(child: Text('Family not found', style: TextStyle(color: Colors.grey)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildStatsGrid(),
                      const SizedBox(height: 24),
                      _buildMembersSection(),
                      const SizedBox(height: 24),
                      _buildAdminActions(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF8906).withValues(alpha: 0.3),
            const Color(0xFFFF8906).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF8906).withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8906), Colors.orangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                (_family!['family_badge'] ?? 'TA').substring(0, 2).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _family!['family_name'] ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ID: ${_family!['familyId']}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontFamily: 'monospace'),
                ),
                if (_family!['family_slogan'] != null && _family!['family_slogan'].toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '"${_family!['family_slogan']}"',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontStyle: FontStyle.italic),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final currentLevel = _family!['current_level'] ?? 1;
    final totalXP = _family!['total_xp'] ?? 0;
    final memberCount = _members.length;
    final memberLimit = _family!['member_limit'] ?? 20;
    final familyPoints = _family!['family_points'] ?? 0;
    final totalWealth = _family!['total_wealth'] ?? 0;
    final totalGifts = _family!['total_gifts_sent'] ?? 0;
    final unlockedPowers = _family!['unlocked_powers'] as List<dynamic>? ?? [];
    final isBanned = _family!['is_banned'] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildStatCard('Level', '$currentLevel', Colors.purple, Icons.arrow_upward),
            _buildStatCard('Total XP', '$totalXP', Colors.blue, Icons.bolt),
            _buildStatCard('Members', '$memberCount/$memberLimit', Colors.green, Icons.people),
            _buildStatCard('Family Pts', '$familyPoints', Colors.orange, Icons.stars),
            _buildStatCard('Wealth', '$totalWealth', Colors.amber, Icons.monetization_on),
            _buildStatCard('Gifts Sent', '$totalGifts', Colors.pink, Icons.card_giftcard),
          ],
        ),
        const SizedBox(height: 16),

        // Status & Powers
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isBanned ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isBanned ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: isBanned ? Colors.red : Colors.green, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Status',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBanned ? 'BANNED' : 'Active',
                    style: TextStyle(
                      color: isBanned ? Colors.red : Colors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Unlocked Powers
        const Text(
          'Unlocked Powers',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (unlockedPowers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: const Text(
              'No powers unlocked yet. Level up to unlock special abilities!',
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: unlockedPowers.map((power) {
              return Chip(
                label: Text(
                  power.toString().replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
                backgroundColor: Colors.deepPurple.withValues(alpha: 0.3),
                side: const BorderSide(color: Colors.deepPurple, width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Members',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.4)),
              ),
              child: Text(
                '${_members.length} members',
                style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_members.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: const Center(
              child: Text(
                'No members yet',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _members.length,
            itemBuilder: (context, index) {
              final member = _members[index];
              return _buildMemberTile(member, index);
            },
          ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions() {
    final familyName = _family!['family_name'] ?? 'Unknown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admin Actions',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => FamilyRewardsConfigView(
                    familyId: widget.familyId,
                    familyName: familyName,
                  ));
                },
                icon: const Icon(Icons.emoji_events, color: Colors.white, size: 18),
                label: const Text('Reward Config', style: TextStyle(color: Colors.white, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8906).withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: const Color(0xFFFF8906).withValues(alpha: 0.4)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => FamilyAdminSlotsView(
                    familyId: widget.familyId,
                    familyName: familyName,
                  ));
                },
                icon: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 18),
                label: const Text('Admin Slots', style: TextStyle(color: Colors.white, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.deepPurple.withValues(alpha: 0.4)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> member, int index) {
    final role = member['familyRole'] ?? 'Member';
    final isLeader = role == 'Patriarch';
    final avatarUrl = member['avatar'] ?? '';
    final username = member['username'] ?? 'Unknown';

    Color roleColor;
    String roleLabel;
    if (isLeader) {
      roleColor = Colors.purple;
      roleLabel = 'LEADER';
    } else if (role == 'Elder') {
      roleColor = Colors.orange;
      roleLabel = 'ELDER';
    } else if (role == 'Co-Leader') {
      roleColor = Colors.deepOrange;
      roleLabel = 'CO-LEADER';
    } else {
      roleColor = Colors.blue;
      roleLabel = 'MEMBER';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF252542), Color(0xFF1E1E3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLeader ? Colors.purple.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
          width: isLeader ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8906), Colors.orangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipOval(
              child: avatarUrl.isNotEmpty
                  ? Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, color: Colors.white);
                      },
                    )
                  : const Icon(Icons.person, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLeader) Icon(Icons.emoji_events, color: Colors.yellow.shade700, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: roleColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        roleLabel,
                        style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lv.${member['level'] ?? 1}',
                      style: TextStyle(color: Colors.green.shade400, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${member['xp'] ?? 0} XP',
                      style: TextStyle(color: Colors.purple.shade400, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}