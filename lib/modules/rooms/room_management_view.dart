// ═══════════════════════════════════════════════════════════════════════════
// FILE: arvind_party_web/lib/modules/rooms/room_management_view.dart
// ARVIND PARTY - Web Admin Panel: Room Management, Cosmetics, PK, Ranking
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
 
class RoomManagementView extends StatefulWidget {
  const RoomManagementView({super.key});

  @override
  State<RoomManagementView> createState() => _RoomManagementViewState();
}

class _RoomManagementViewState extends State<RoomManagementView> {
 
  final ApiService _api = Get.find<ApiService>();
  final RxList<Map<String, dynamic>> rooms = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> roomRankings = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedFilter = 'all'.obs;
  final RxString rankingType = 'gift'.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The onInit call was here, which is incorrect. It's moved to the constructor.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Management'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => _showRankingDialog(context),
            tooltip: 'Room Rankings',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateRoomDialog(context),
            tooltip: 'Create Room',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => fetchRooms(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return rooms.isEmpty
                  ? const Center(
                      child: Text('No rooms found', style: TextStyle(fontSize: 18, color: Colors.grey)))
                  : ListView.builder(
                      itemCount: rooms.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) => _buildRoomCard(context, rooms[index]),
                    );
            }),
          ),
        ],
      ),
    );
  }
 
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search rooms by title...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => fetchRooms(search: searchController.text),
              ),
            ),
            onSubmitted: (value) => fetchRooms(search: value),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All', 'all'),
                const SizedBox(width: 8),
                _filterChip('Public', 'PUBLIC'),
                const SizedBox(width: 8),
                _filterChip('Password', 'PASSWORD'),
                const SizedBox(width: 8),
                _filterChip('Theme', 'THEME'),
                const SizedBox(width: 8),
                _filterChip('Karaoke', 'KARAOKE'),
                const SizedBox(width: 8),
                _filterChip('Game', 'GAME'),
                const SizedBox(width: 8),
                _filterChip('Family', 'FAMILY'),
                const SizedBox(width: 8),
                _filterChip('Agency', 'AGENCY'),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _filterChip(String label, String value) {
    return Obx(() => ChoiceChip(
      label: Text(label),
      selected: selectedFilter.value == value,
      onSelected: (_) {
        selectedFilter.value = value;
        if (value == 'all') {
          fetchRooms();
        } else {
          fetchRooms(type: value);
        }
      },
      selectedColor: Colors.deepPurple[300],
      labelStyle: TextStyle(
        color: selectedFilter.value == value ? Colors.white : Colors.black87,
      ),
    ));
  }
 
  Widget _buildRoomCard(BuildContext context, Map<String, dynamic> room) {
    final roomId = room['roomId'] ?? room['_id'] ?? '';
    final title = room['title'] ?? 'Untitled Room';
    final roomType = room['roomType'] ?? 'PUBLIC';
    final ownerName = room['ownerId'] is Map
        ? (room['ownerId']['name'] ?? room['ownerId']['username'] ?? 'Unknown')
        : 'Unknown';
    final activeUsers = room['activeUsers'] ?? 0;
    final isLive = room['isLive'] ?? false;
    final isActive = room['isActive'] ?? true;
    final status = room['status'] ?? 'inactive';
    final totalGiftPoints = room['totalGiftPoints'] ?? 0;
    final pkPoints = room['pkPoints'] ?? 0;
    final rankPoints = room['rankPoints'] ?? 0;
 
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isLive ? Colors.green : (isActive ? Colors.blue : Colors.red),
          child: Icon(
            isLive ? Icons.record_voice_over : (isActive ? Icons.check_circle : Icons.cancel),
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getRoomTypeColor(roomType),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(roomType, style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ],
        ),
        subtitle: Text('Owner: $ownerName • Active: $activeUsers • Room: $roomId'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _statChip(Icons.card_giftcard, 'Gifts: $totalGiftPoints', Colors.orange),
                    const SizedBox(width: 8),
                    _statChip(Icons.sports_kabaddi, 'PK: $pkPoints', Colors.red),
                    const SizedBox(width: 8),
                    _statChip(Icons.leaderboard, 'Rank: $rankPoints', Colors.blue),
                    const SizedBox(width: 8),
                    _statChip(
                      Icons.circle,
                      status,
                      status == 'active' || status == 'live' ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isLive)
                      TextButton.icon(
                        onPressed: () => _toggleLive(roomId, false),
                        icon: const Icon(Icons.videocam_off, size: 18),
                        label: const Text('Go Offline'),
                        style: TextButton.styleFrom(foregroundColor: Colors.orange),
                      ),
                    if (!isLive && isActive)
                      TextButton.icon(
                        onPressed: () => _toggleLive(roomId, true),
                        icon: const Icon(Icons.videocam, size: 18),
                        label: const Text('Go Live'),
                        style: TextButton.styleFrom(foregroundColor: Colors.green),
                      ),
                    const SizedBox(width: 8),
                    if (isActive)
                      TextButton.icon(
                        onPressed: () => _banRoom(roomId),
                        icon: const Icon(Icons.block, size: 18),
                        label: const Text('Ban'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showRoomDetailDialog(context, room),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Details'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showBackgroundDialog(context, roomId, title),
                      icon: const Icon(Icons.brush, size: 18),
                      label: const Text('Cosmetics'),
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
 
  Widget _statChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
 
  Color _getRoomTypeColor(String type) {
    switch (type) {
      case 'PUBLIC': return Colors.green;
      case 'PRIVATE': return Colors.blue;
      case 'PASSWORD': return Colors.orange;
      case 'THEME': return Colors.purple;
      case 'KARAOKE': return Colors.pink;
      case 'GAME': return Colors.teal;
      case 'FAMILY': return Colors.indigo;
      case 'AGENCY': return Colors.brown;
      default: return Colors.grey;
    }
  }
 
  Future<void> fetchRooms({String? type, String? search}) async {
    isLoading.value = true;
    try {
      final query = <String, dynamic>{'limit': '100'};
      if (type != null) query['type'] = type;
      if (search != null && search.isNotEmpty) query['search'] = search;

      final response = await _api.get('/rooms', query: query);
      if (response['success'] == true) {
        final List<dynamic> roomList = response['rooms'] ?? response['data'] ?? [];
        rooms.assignAll(roomList.map((e) => Map<String, dynamic>.from(e)).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch rooms: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
 
  Future<void> fetchRoomRanking({String type = 'gift'}) async {
    try {
      final response = await _api.get('/rooms/ranking', query: {'type': type, 'limit': '50'});
      if (response['success'] == true) {
        final List<dynamic> rankList = response['rooms'] ?? response['data'] ?? [];
        roomRankings.assignAll(rankList.map((e) => Map<String, dynamic>.from(e)).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch rankings: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
 
  Future<void> _toggleLive(String roomId, bool goLive) async {
    try {
      final response = await _api.post('/rooms/$roomId/toggle-live', {'isLive': goLive});
      if (response['success'] == true) {
        Get.snackbar('Success', 'Room is now ${goLive ? "LIVE" : "OFFLINE"}',
            backgroundColor: Colors.greenAccent, colorText: Colors.black);
        fetchRooms();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle live status',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
 
  Future<void> _banRoom(String roomId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Ban Room'),
        content: const Text('Are you sure you want to ban this room? This will kick all users.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ban Room'),
          ),
        ],
      ),
    );
 
    if (confirmed == true) {
      try {
        final response = await _api.post('/rooms/$roomId/ban', {'status': 'banned'});
        if (response['success'] == true) {
          Get.snackbar('Banned', 'Room has been banned.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          fetchRooms();
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to ban room',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    }
  }
 
  void _showCreateRoomDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'PUBLIC';
    String selectedCategory = 'voice';
    int seatCount = 8;
 
    Get.dialog(
      AlertDialog(
        title: const Text('Create New Room'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Room Title *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Room Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'PUBLIC', child: Text('Public')),
                  DropdownMenuItem(value: 'PRIVATE', child: Text('Private')),
                  DropdownMenuItem(value: 'PASSWORD', child: Text('Password')),
                  DropdownMenuItem(value: 'THEME', child: Text('Theme')),
                  DropdownMenuItem(value: 'KARAOKE', child: Text('Karaoke')),
                  DropdownMenuItem(value: 'GAME', child: Text('Game')),
                  DropdownMenuItem(value: 'FAMILY', child: Text('Family')),
                  DropdownMenuItem(value: 'AGENCY', child: Text('Agency')),
                ],
                onChanged: (v) => selectedType = v ?? 'PUBLIC',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'voice', child: Text('Voice')),
                  DropdownMenuItem(value: 'music', child: Text('Music')),
                  DropdownMenuItem(value: 'gaming', child: Text('Gaming')),
                  DropdownMenuItem(value: 'chat', child: Text('Chat')),
                  DropdownMenuItem(value: 'event', child: Text('Event')),
                ],
                onChanged: (v) => selectedCategory = v ?? 'voice',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Seats: '),
                  Expanded(
                    child: Slider(
                      value: seatCount.toDouble(),
                      min: 2,
                      max: 32,
                      divisions: 30,
                      label: seatCount.toString(),
                      onChanged: (v) => seatCount = v.toInt(),
                    ),
                  ),
                  Text('$seatCount'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Room title is required',
                    backgroundColor: Colors.redAccent, colorText: Colors.white);
                return;
              }
              try {
                final response = await _api.post('/rooms', {
                  'title': titleController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'roomType': selectedType,
                  'roomCategory': selectedCategory,
                  'seatCount': seatCount,
                });
                if (response['success'] == true) {
                  Get.back();
                  Get.snackbar('Success', 'Room created!',
                      backgroundColor: Colors.greenAccent, colorText: Colors.black);
                  fetchRooms();
                }
              } catch (e) {
                Get.snackbar('Error', 'Failed to create room: $e',
                    backgroundColor: Colors.redAccent, colorText: Colors.white);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('Create Room', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
 
  void _showRoomDetailDialog(BuildContext context, Map<String, dynamic> room) {
    final roomId = room['roomId'] ?? '';
    Get.dialog(
      AlertDialog(
        title: Text(room['title'] ?? 'Room Details'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Room ID', roomId),
                _detailRow('Type', room['roomType'] ?? 'N/A'),
                _detailRow('Category', room['roomCategory'] ?? 'N/A'),
                _detailRow('Description', room['description'] ?? 'N/A'),
                _detailRow('Language', room['language'] ?? 'N/A'),
                _detailRow('Status', room['status'] ?? 'N/A'),
                _detailRow('Active Users', '${room['activeUsers'] ?? 0}'),
                _detailRow('Seat Count', '${room['seatCount'] ?? 8}'),
                const Divider(),
                _detailRow('Gift Points', '${room['totalGiftPoints'] ?? 0}'),
                _detailRow('Traffic Minutes', '${room['totalTrafficMinutes'] ?? 0}'),
                _detailRow('PK Wins', '${room['pkWins'] ?? 0}'),
                _detailRow('PK Losses', '${room['pkLosses'] ?? 0}'),
                _detailRow('PK Points', '${room['pkPoints'] ?? 0}'),
                _detailRow('Rank Points', '${room['rankPoints'] ?? 0}'),
                _detailRow('Loot Box Level', '${room['lootBoxLevel'] ?? 1}'),
                const Divider(),
                _detailRow('Announcement', room['announcement'] ?? 'None'),
                _detailRow('Pinned Message', room['pinnedMessage'] ?? 'None'),
                _detailRow('LiveKit Room', room['liveKitRoom'] ?? 'N/A'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }
 
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
 
  void _showBackgroundDialog(BuildContext context, String roomId, String roomTitle) {
    final backgrounds = [
      {'id': 'default', 'name': 'Default', 'url': '', 'color': '#FF6B6B'},
      {'id': 'space', 'name': 'Space Galaxy', 'url': 'assets/backgrounds/space.jpg', 'color': '#0D0D2B'},
      {'id': 'casino', 'name': 'Casino Royale', 'url': 'assets/backgrounds/casino.jpg', 'color': '#FFD700'},
      {'id': 'nature', 'name': 'Forest Vibes', 'url': 'assets/backgrounds/nature.jpg', 'color': '#2E7D32'},
      {'id': 'party', 'name': 'Neon Party', 'url': 'assets/backgrounds/party.gif', 'color': '#FF1493'},
      {'id': 'ocean', 'name': 'Deep Ocean', 'url': 'assets/backgrounds/ocean.jpg', 'color': '#006064'},
      {'id': 'festival', 'name': 'Festival Lights', 'url': 'assets/backgrounds/festival.gif', 'color': '#FF6F00'},
    ];
    String selectedUrl = '';
    String selectedName = '';
 
    Get.dialog(
      AlertDialog(
        title: Text('Cosmetics: $roomTitle'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a background theme:'),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: backgrounds.length,
                  itemBuilder: (context, index) {
                    final bg = backgrounds[index];
                    return GestureDetector(
                      onTap: () {
                        selectedUrl = bg['url'] as String;
                        selectedName = bg['name'] as String;
                        Get.back();
                        _applyBackground(roomId, selectedUrl, selectedName);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(int.parse((bg['color'] as String).replaceAll('#', '0xFF'))),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Text(
                            bg['name'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }
 
  Future<void> _applyBackground(String roomId, String url, String name) async {
    try {
      final response = await _api.put('/rooms/$roomId/settings', {
        'backgroundUrl': url,
        'backgroundName': name,
      });
      if (response['success'] == true) {
        Get.snackbar('Updated', 'Background set to $name',
            backgroundColor: Colors.greenAccent, colorText: Colors.black);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update background',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
 
  void _showRankingDialog(BuildContext context) {
    fetchRoomRanking();
    Get.dialog(
      AlertDialog(
        title: const Text('Room Rankings'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Obx(() {
            if (roomRankings.isEmpty) {
              return const Center(child: Text('No ranking data yet'));
            }
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Gift'),
                      selected: rankingType.value == 'gift',
                      onSelected: (_) {
                        rankingType.value = 'gift';
                        fetchRoomRanking(type: 'gift');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Traffic'),
                      selected: rankingType.value == 'traffic',
                      onSelected: (_) {
                        rankingType.value = 'traffic';
                        fetchRoomRanking(type: 'traffic');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('PK'),
                      selected: rankingType.value == 'pk',
                      onSelected: (_) {
                        rankingType.value = 'pk';
                        fetchRoomRanking(type: 'pk');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: roomRankings.length,
                    itemBuilder: (context, index) {
                      final room = roomRankings[index];
                      final rank = index + 1;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: rank <= 3 ? Colors.amber : Colors.grey[300],
                          child: Text('$rank', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: rank <= 3 ? Colors.white : Colors.black87,
                          )),
                        ),
                        title: Text(room['title'] ?? 'Unknown Room'),
                        subtitle: Text(
                          'Owner: ${room['ownerId'] is Map ? (room['ownerId']['name'] ?? 'Unknown') : 'Unknown'}',
                        ),
                        trailing: Text(
                          '${room['totalGiftPoints'] ?? 0} pts',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }
}