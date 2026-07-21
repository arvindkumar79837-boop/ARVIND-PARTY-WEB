import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class BroadcastView extends StatefulWidget {
  const BroadcastView({super.key});

  @override
  State<BroadcastView> createState() => _BroadcastViewState();
}

class _BroadcastViewState extends State<BroadcastView> {
  final _apiService = Get.find<ApiService>();
  List<Map<String, dynamic>> _broadcasts = [];
  bool _isLoading = true;
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedType = 'ANNOUNCEMENT';

  @override
  void initState() {
    super.initState();
    _loadBroadcasts();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadBroadcasts() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/broadcasts');
      if (response['success'] == true) {
        _broadcasts = List<Map<String, dynamic>>.from(response['data'] ?? response['broadcasts'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading broadcasts: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _sendBroadcast() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      Get.snackbar('Error', 'Title and message are required', backgroundColor: Colors.red);
      return;
    }

    try {
      final response = await _apiService.post('/broadcasts/send', {
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'type': _selectedType,
      });
      if (response['success'] == true) {
        Get.back();
        _titleController.clear();
        _messageController.clear();
        Get.snackbar('Success', 'Broadcast sent', backgroundColor: Colors.green);
        _loadBroadcasts();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to send', backgroundColor: Colors.red);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send broadcast', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcasts & Announcements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showSendDialog,
            tooltip: 'New Broadcast',
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBroadcasts),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _broadcasts.isEmpty
              ? const Center(child: Text('No broadcasts yet'))
              : ListView.builder(
                  itemCount: _broadcasts.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (ctx, i) {
                    final b = _broadcasts[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Icon(
                          _getTypeIcon(b['type'] ?? 'ANNOUNCEMENT'),
                          color: _getTypeColor(b['type'] ?? 'ANNOUNCEMENT'),
                        ),
                        title: Text(b['title'] ?? 'No Title'),
                        subtitle: Text(b['message'] ?? ''),
                        trailing: Text(
                          b['createdAt']?.toString().substring(0, 10) ?? '',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showSendDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Send Broadcast'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'ANNOUNCEMENT', child: Text('Announcement')),
                  DropdownMenuItem(value: 'NOTIFICATION', child: Text('Notification')),
                  DropdownMenuItem(value: 'ALERT', child: Text('Alert')),
                  DropdownMenuItem(value: 'UPDATE', child: Text('Update')),
                ],
                onChanged: (v) => _selectedType = v ?? 'ANNOUNCEMENT',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: _sendBroadcast,
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'ALERT': return Icons.warning;
      case 'NOTIFICATION': return Icons.notifications;
      case 'UPDATE': return Icons.system_update;
      default: return Icons.campaign;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'ALERT': return Colors.red;
      case 'NOTIFICATION': return Colors.blue;
      case 'UPDATE': return Colors.green;
      default: return Colors.orange;
    }
  }
}
