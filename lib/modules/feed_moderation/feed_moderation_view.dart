import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arvind_party_web/modules/shared/admin_shell.dart';
import 'package:arvind_party_web/core/services/api_service.dart';

class FeedModerationView extends StatefulWidget {
  const FeedModerationView({super.key});

  @override
  State<FeedModerationView> createState() => _FeedModerationViewState();
}

class _FeedModerationViewState extends State<FeedModerationView> {
  final _api = Get.find<ApiService>();
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  String _filter = 'FLAGGED';

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final resp = await _api.dio.get('/moderation/reports', queryParameters: {'status': _filter});
      if (resp.data['success'] == true) {
        _posts = List<Map<String, dynamic>>.from(resp.data['data']?['reports'] ?? resp.data['data'] ?? []);
      }
    } catch (e) { debugPrint('Error: $e'); }
    setState(() => _isLoading = false);
  }

  Future<void> _resolvePost(String postId, String action) async {
    try {
      await _api.dio.put('/moderation/resolve/$postId', data: {'actionTaken': action});
      _loadPosts();
    } catch (e) { debugPrint('Error: $e'); }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await _api.dio.delete('/moments/admin/$postId');
      _loadPosts();
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
                const Icon(Icons.feed, color: Color(0xFFFF8906), size: 28),
                const SizedBox(width: 12),
                const Text('Feed Moderation', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                _filterChip('Flagged', 'FLAGGED'),
                const SizedBox(width: 8),
                _filterChip('All', 'ALL'),
                const SizedBox(width: 8),
                _filterChip('Resolved', 'RESOLVED'),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
            else if (_posts.isEmpty)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white24, size: 64),
                    SizedBox(height: 16),
                    Text('No reported posts', style: TextStyle(color: Colors.white38, fontSize: 16)),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (ctx, i) => _buildPostCard(_posts[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isActive = _filter == value;
    return GestureDetector(
      onTap: () { _filter = value; _loadPosts(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF8906) : const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final content = post['content'] ?? post['description'] ?? '';
    final userName = post['userName'] ?? post['reportedBy'] ?? 'Unknown';
    final reason = post['reason'] ?? post['reportReason'] ?? '';
    final status = post['status'] ?? post['moderationStatus'] ?? '';
    final postId = post['_id'] ?? post['postId'] ?? post['reportId'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status == 'FLAGGED' ? Colors.orange.withOpacity(0.3) : Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFFF8906).withOpacity(0.2),
                child: Text(userName[0].toUpperCase(), style: const TextStyle(color: Color(0xFFFF8906), fontSize: 14)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    if (reason.isNotEmpty) Text('Reason: $reason', style: const TextStyle(color: Colors.orange, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: status == 'FLAGGED' ? Colors.orange.withOpacity(0.15) : const Color(0xFF4CAF50).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status, style: TextStyle(color: status == 'FLAGGED' ? Colors.orange : const Color(0xFF4CAF50), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(color: Colors.white70, fontSize: 14), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _resolvePost(postId, 'WARN'),
                icon: const Icon(Icons.warning, size: 16),
                label: const Text('Warn'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _deletePost(postId),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _resolvePost(postId, 'DISMISS'),
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Dismiss'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
