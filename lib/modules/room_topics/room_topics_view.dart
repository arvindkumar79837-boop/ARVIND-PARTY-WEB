import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arvind_party_web/modules/shared/admin_shell.dart';
import 'package:arvind_party_web/core/services/api_service.dart';

class RoomTopicsView extends StatefulWidget {
  const RoomTopicsView({super.key});

  @override
  State<RoomTopicsView> createState() => _RoomTopicsViewState();
}

class _RoomTopicsViewState extends State<RoomTopicsView> {
  final _api = Get.find<ApiService>();
  List<Map<String, dynamic>> _topics = [];
  bool _isLoading = true;

  static const _defaultTopics = [
    {'name': 'Music', 'icon': '🎵', 'color': '#FF6B6B'},
    {'name': 'Chatting', 'icon': '💬', 'color': '#00BCD4'},
    {'name': 'Gaming', 'icon': '🎮', 'color': '#6C63FF'},
    {'name': 'Dating', 'icon': '❤️', 'color': '#FF4081'},
    {'name': 'Comedy', 'icon': '😂', 'color': '#FFD54F'},
    {'name': 'Talk Show', 'icon': '🎙️', 'color': '#81C784'},
    {'name': 'Study', 'icon': '📚', 'color': '#7986CB'},
  ];

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    setState(() => _isLoading = true);
    try {
      final resp = await _api.dio.get('/admin/room-topics');
      if (resp.data['success'] == true) {
        _topics = List<Map<String, dynamic>>.from(resp.data['data'] ?? []);
      }
    } catch (e) { debugPrint('Error: $e'); _topics = List<Map<String, dynamic>>.from(_defaultTopics); }
    if (_topics.isEmpty) _topics = List<Map<String, dynamic>>.from(_defaultTopics);
    setState(() => _isLoading = false);
  }

  Future<void> _addTopic() async {
    final nameCtrl = TextEditingController();
    final iconCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Add Topic', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Topic Name', labelStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
            const SizedBox(height: 8),
            TextField(controller: iconCtrl, style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Emoji Icon', labelStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                try {
                  await _api.dio.post('/admin/room-topics', data: {'name': nameCtrl.text, 'icon': iconCtrl.text});
                  Navigator.pop(ctx, true);
                } catch (e) { debugPrint('Error: $e'); Navigator.pop(ctx, true); }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906)),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (result == true) _loadTopics();
  }

  Future<void> _deleteTopic(String name) async {
    try {
      await _api.dio.delete('/admin/room-topics/$name');
      _loadTopics();
    } catch (e) { debugPrint('Error: $e'); setState(() => _topics.removeWhere((t) => t['name'] == name)); }
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
                const Icon(Icons.topic, color: Color(0xFFFF8906), size: 28),
                const SizedBox(width: 12),
                const Text('Room Topics', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addTopic,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Topic'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906), foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Topics appear as filters in the app\'s room discovery', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
            else
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _topics.map((topic) {
                    final color = Color(int.parse((topic['color'] ?? '#FF8906').replaceFirst('#', '0xFF')));
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(topic['icon'] ?? '📌', style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Text(topic['name'] ?? '', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _deleteTopic(topic['name']),
                            child: Icon(Icons.close, color: color.withOpacity(0.5), size: 18),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
