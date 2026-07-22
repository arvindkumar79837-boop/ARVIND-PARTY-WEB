// ═══════════════════════════════════════════════════════════════════════════
// FILE: arvind_party_web/lib/modules/rooms/youtube_management_view.dart
// ARVIND PARTY - Web Admin Panel: YouTube Management
// TODO: YouTubeManagementController is unused — no route, no Get.find, no import
//       from outside this file. Wire to a view and route when ready, or remove.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/services/api_service.dart';
import '../../core/constants/env_config.dart';

class YouTubeManagementView extends GetView<YouTubeManagementController> {
  const YouTubeManagementView({super.key, this.roomId});
  final String? roomId;

  @override
  Widget build(BuildContext context) {
    if (roomId == null) {
      return const Scaffold(body: Center(child: Text('No room selected')));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Management • Room: $roomId'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller._loadPlaylist,
            tooltip: 'Refresh Playlist',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: controller._showSearchDialog,
            tooltip: 'Add Video',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInfoBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return controller.videos.isEmpty
                  ? const Center(child: Text('No videos in playlist', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: controller.videos.length,
                      itemBuilder: (context, index) => _buildVideoCard(controller.videos[index], index),
                    );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.red[50],
      child: Row(
        children: [
          const Icon(Icons.youtube_searched_for, color: Colors.red, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Manage shared YouTube playlist for room $roomId',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton.icon(
            onPressed: controller._showSearchDialog,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Video', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video, int index) {
    final videoId = video['id'] ?? '';
    final title = video['title'] ?? 'Unknown';
    final channel = video['channelName'] ?? video['channel'] ?? 'Unknown';
    final thumbnail = video['thumbnailUrl'] ?? video['thumbnail'] ?? '';
    final duration = video['duration'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: thumbnail.isNotEmpty
              ? Image.network(thumbnail, width: 100, height: 56, fit: BoxFit.cover)
              : Container(width: 100, height: 56, color: Colors.grey[300], child: const Icon(Icons.play_circle_outline)),
        ),
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(channel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (duration > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                child: Text('${duration ~/ 60}:${(duration % 60).toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => controller._removeFromPlaylist(videoId),
              tooltip: 'Remove',
            ),
          ],
        ),
        onTap: () => controller._playVideo(video),
      ),
    );
  }
}

class YouTubeManagementController extends GetxController {
  final String? roomId;
  final ApiService _api = Get.find<ApiService>();

  final RxList<Map<String, dynamic>> videos = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  // ─── Socket.IO Real-time Sync ─────────────────────────────
  io.Socket? _youtubeSocket;

  YouTubeManagementController({this.roomId});

  @override
  void onInit() {
    super.onInit();
    _loadPlaylist();
    setupSocket();
  }

  @override
  void onClose() {
    _youtubeSocket?.dispose();
    super.onClose();
  }

  void setupSocket() {
    final token = _api.token;
    if (token == null) return;
    try {
      _youtubeSocket = io.io(
        '${EnvConfig.socketUrl}/youtube',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .build(),
      );
      _youtubeSocket!.onConnect((_) {
        // YouTube Socket connected
      });
      _youtubeSocket!.on('youtube:playlist_updated', (dynamic data) {
        if (data == null) return;
        final Map<String, dynamic> map = data as Map<String, dynamic>;
        final list = (map['videos'] as List<dynamic>? ?? []);
        videos.assignAll(list.map((v) => Map<String, dynamic>.from(v as Map)).toList());
      });
      _youtubeSocket!.on('youtube:sync_update', (dynamic data) {
        // Real-time playback state update (optional UI indicator)
      });
      _youtubeSocket!.on('youtube:video_changed', (dynamic data) {
        // YouTube video changed
      });
      _youtubeSocket!.onDisconnect((_) => debugPrint('YouTube Socket: Disconnected'));
      _youtubeSocket!.onError((error) => debugPrint('YouTube Socket Error: $error'));
    } catch (e) {
      debugPrint('Error setting up YouTube socket: $e');
    }
  }

  Future<void> _loadPlaylist() async {
    if (roomId == null) return;
    isLoading.value = true;
    try {
      final response = await _api.get('/youtube/playlist/$roomId');
      if (response.isNotEmpty) {
        final list = (response['videos'] as List<dynamic>? ?? []);
        videos.assignAll(list.map((v) => Map<String, dynamic>.from(v as Map)).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load playlist: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _removeFromPlaylist(String videoId) async {
    if (roomId == null) return;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove Video'),
        content: const Text('Remove this video from the shared playlist?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.delete('/youtube/playlist/$roomId/$videoId');
      Get.snackbar('Removed', 'Video removed from playlist', backgroundColor: Colors.greenAccent, colorText: Colors.black);
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove video: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> _playVideo(Map<String, dynamic> video) async {
    if (roomId == null) return;
    try {
      await _api.post('/youtube/playback/update', {
        'roomId': roomId,
        'videoId': video['id'],
        'isPlaying': true,
        'position': 0,
      });
      Get.snackbar('Playing', 'Host initiated playback', backgroundColor: Colors.greenAccent, colorText: Colors.black);
    } catch (e) {
      Get.snackbar('Error', 'Failed to play video: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
  
  void _showSearchDialog() {
    final ctrl = TextEditingController();
    final results = <Map<String, dynamic>>[].obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Search & Add Video'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                decoration: InputDecoration(
                  hintText: 'Search YouTube...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onSubmitted: (_) => _search(ctrl.text, results),
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (results.isEmpty) return const SizedBox.shrink();
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final v = results[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.play_circle_outline),
                        title: Text(v['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () async {
                          await _api.post('/youtube/playlist/add', {
                            'roomId': roomId,
                            'video': v,
                          });
                          Get.back();
                          Get.snackbar('Added', 'Video added to playlist', backgroundColor: Colors.greenAccent, colorText: Colors.black);
                        },
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          ElevatedButton(onPressed: () => _search(ctrl.text, results), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Search', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Future<void> _search(String query, RxList<Map<String, dynamic>> results) async {
    if (query.trim().isEmpty) return;
    try {
      final response = await _api.get('/youtube/search', queryParams: {'q': query});
      final list = (response['videos'] as List<dynamic>? ?? []);
      results.assignAll(list.map((v) => Map<String, dynamic>.from(v as Map)).toList());
    } catch (e) {
      Get.snackbar('Error', 'Search failed: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

}
