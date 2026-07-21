import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arvind_party_web/modules/shared/admin_shell.dart';
import 'package:arvind_party_web/core/services/api_service.dart';

class MusicLibraryView extends StatefulWidget {
  const MusicLibraryView({super.key});

  @override
  State<MusicLibraryView> createState() => _MusicLibraryViewState();
}

class _MusicLibraryViewState extends State<MusicLibraryView> {
  final _api = Get.find<ApiService>();
  List<Map<String, dynamic>> _tracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    setState(() => _isLoading = true);
    try {
      final resp = await _api.dio.get('/admin/music-library');
      if (resp.data['success'] == true) {
        _tracks = List<Map<String, dynamic>>.from(resp.data['data'] ?? []);
      }
    } catch (e) { debugPrint('Error: $e'); }
    setState(() => _isLoading = false);
  }

  Future<void> _addTrack() async {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final lyricsCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Add Track', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(ctx, titleCtrl, 'Track Title'),
            _field(ctx, urlCtrl, 'Audio URL'),
            _field(ctx, lyricsCtrl, 'Lyrics URL (LRC)'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty && urlCtrl.text.isNotEmpty) {
                try {
                  await _api.dio.post('/admin/music-library', data: {
                    'title': titleCtrl.text, 'url': urlCtrl.text, 'lyricsUrl': lyricsCtrl.text,
                  });
                  Navigator.pop(ctx, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906)),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (result == true) _loadTracks();
  }

  Future<void> _deleteTrack(String id) async {
    try {
      await _api.dio.delete('/admin/music-library/$id');
      _loadTracks();
    } catch (e) { debugPrint('Error: $e'); }
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
                const Icon(Icons.library_music, color: Color(0xFFFF8906), size: 28),
                const SizedBox(width: 12),
                const Text('Music Library', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addTrack,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Track'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906), foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Manage tracks for room music broadcast & karaoke', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
            else if (_tracks.isEmpty)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_off, color: Colors.white24, size: 64),
                    SizedBox(height: 16),
                    Text('No tracks in library', style: TextStyle(color: Colors.white38, fontSize: 16)),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _tracks.length,
                  itemBuilder: (ctx, i) {
                    final track = _tracks[i];
                    final hasLyrics = (track['lyricsUrl'] ?? '').isNotEmpty;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: const Color(0xFFFF8906).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.music_note, color: Color(0xFFFF8906)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(track['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(track['url'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          if (hasLyrics)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFF4CAF50).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                              child: const Text('LRC', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _deleteTrack(track['_id']),
                            icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget _field(BuildContext ctx, TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
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
