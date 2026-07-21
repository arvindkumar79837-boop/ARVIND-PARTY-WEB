// ═══════════════════════════════════════════════════════════════════════════
// VIEW: NotificationSenderView — Send notifications to users
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class NotificationSenderView extends StatefulWidget {
  const NotificationSenderView({super.key});

  @override
  State<NotificationSenderView> createState() => _NotificationSenderViewState();
}

class _NotificationSenderViewState extends State<NotificationSenderView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _targetUidController = TextEditingController();
  String _type = 'general';

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _targetUidController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final targetUid = _targetUidController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      Get.snackbar('Error', 'Title and message required', backgroundColor: Colors.red);
      return;
    }

    try {
      await _apiService.post('/admin/notifications/send', {
        'title': title,
        'message': message,
        'type': _type,
        if (targetUid.isNotEmpty) 'targetUid': targetUid,
      });
      Get.snackbar('Success', 'Notification sent', backgroundColor: Colors.green);
      _titleController.clear();
      _messageController.clear();
      _targetUidController.clear();
    } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Failed to send', backgroundColor: Colors.red); }
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _permService.hasPermission('notifications.send');

    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification')),
      body: canSend
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('New Notification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _targetUidController,
                    decoration: const InputDecoration(labelText: 'Target UID (leave empty for all)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'general', child: Text('General')),
                      DropdownMenuItem(value: 'system', child: Text('System')),
                      DropdownMenuItem(value: 'promotion', child: Text('Promotion')),
                      DropdownMenuItem(value: 'alert', child: Text('Alert')),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? 'general'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _sendNotification,
                      icon: const Icon(Icons.send),
                      label: const Text('Send Notification'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.all(16)),
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: Text('Permission denied')),
    );
  }
}