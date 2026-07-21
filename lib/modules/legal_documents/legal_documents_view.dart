import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class LegalDocumentsView extends StatefulWidget {
  const LegalDocumentsView({super.key});

  @override
  State<LegalDocumentsView> createState() => _LegalDocumentsViewState();
}

class _LegalDocumentsViewState extends State<LegalDocumentsView> {
  final _apiService = Get.find<ApiService>();
  List<dynamic> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.get('/legal/documents');
      if (res['success'] == true) _documents = List.from(res['data'] ?? []);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _openEditor(Map<String, dynamic>? doc, String type) {
    final titleCtrl = TextEditingController(text: doc?['title'] ?? '');
    final contentCtrl = TextEditingController(text: doc?['content'] ?? '');
    final typeLabels = {'PRIVACY_POLICY': 'Privacy Policy', 'TERMS_OF_SERVICE': 'Terms of Service', 'COMMUNITY_GUIDELINES': 'Community Guidelines'};

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${typeLabels[type] ?? type}'),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: contentCtrl, maxLines: 12, decoration: const InputDecoration(labelText: 'Content (Markdown supported)', border: OutlineInputBorder(), alignLabelWithHint: true)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.post('/legal/document', {
                  'type': type,
                  'title': titleCtrl.text,
                  'content': contentCtrl.text,
                });
                Navigator.pop(ctx);
                Get.snackbar('Saved', '${typeLabels[type]} updated successfully');
                _loadDocuments();
              } catch (e) {
                Get.snackbar('Error', e.toString());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Documents'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDocuments)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDocumentCard('PRIVACY_POLICY', Icons.privacy_tip, 'Privacy Policy', 'User data handling, storage, and third-party sharing'),
                const SizedBox(height: 12),
                _buildDocumentCard('TERMS_OF_SERVICE', Icons.gavel, 'Terms of Service', 'Platform usage rules, liabilities, and user obligations'),
                const SizedBox(height: 12),
                _buildDocumentCard('COMMUNITY_GUIDELINES', Icons.people, 'Community Guidelines', 'Acceptable behavior, content standards, and enforcement'),
              ],
            ),
    );
  }

  Widget _buildDocumentCard(String type, IconData icon, String title, String subtitle) {
    final existing = _documents.cast<Map<String, dynamic>?>().firstWhere((d) => d?['type'] == type, orElse: () => null);
    final updatedAt = existing?['updatedAt'];

    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.orange.shade100, child: Icon(icon, color: Colors.orange)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            if (updatedAt != null) Text('Last updated: ${updatedAt.toString().substring(0, 16)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        isThreeLine: true,
        trailing: ElevatedButton.icon(
          onPressed: () => _openEditor(existing, type),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Edit'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
        ),
      ),
    );
  }
}
