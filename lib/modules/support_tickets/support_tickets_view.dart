import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class SupportTicketsView extends StatefulWidget {
  const SupportTicketsView({super.key});

  @override
  State<SupportTicketsView> createState() => _SupportTicketsViewState();
}

class _SupportTicketsViewState extends State<SupportTicketsView> {
  final _apiService = Get.find<ApiService>();
  List<dynamic> _tickets = [];
  bool _isLoading = true;
  Map<String, dynamic>? _selectedTicket;
  final _replyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() { _isLoading = true; _selectedTicket = null; });
    try {
      final res = await _apiService.get('/support/tickets');
      if (res['success'] == true) _tickets = List.from(res['data'] ?? []);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _sendReply(String ticketId) async {
    if (_replyCtrl.text.trim().isEmpty) return;
    try {
      final res = await _apiService.post('/support/ticket/reply', {
        'ticketId': ticketId,
        'message': _replyCtrl.text.trim(),
        'status': 'IN_PROGRESS',
      });
      if (res['success'] == true) {
        _replyCtrl.clear();
        Get.snackbar('Sent', 'Reply sent');
        _loadTickets();
      } else {
        Get.snackbar('Error', res['message'] ?? 'Failed');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _resolveTicket(String ticketId) async {
    try {
      final res = await _apiService.post('/support/ticket/reply', {
        'ticketId': ticketId,
        'status': 'RESOLVED',
      });
      if (res['success'] == true) {
        Get.snackbar('Done', 'Ticket resolved');
        _loadTickets();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Tickets'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTickets)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedTicket != null
              ? _buildTicketDetail()
              : _buildTicketList(),
    );
  }

  Widget _buildTicketList() {
    if (_tickets.isEmpty) return const Center(child: Text('No tickets'));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _tickets.length,
      itemBuilder: (context, index) {
        final t = _tickets[index];
        final status = t['status'] ?? 'OPEN';
        final statusColor = {
          'OPEN': Colors.orange, 'IN_PROGRESS': Colors.blue, 'RESOLVED': Colors.green,
        }[status] ?? Colors.grey;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: statusColor.withValues(alpha: 0.2), child: Icon(Icons.support_agent, color: statusColor, size: 20)),
            title: Text(t['subject'] ?? 'No subject', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(t['userId'] is Map ? t['userId']['username'] ?? 'User' : 'User'),
            trailing: Chip(label: Text(status, style: const TextStyle(fontSize: 11)), backgroundColor: statusColor.withValues(alpha: 0.2), visualDensity: VisualDensity.compact),
            onTap: () => setState(() => _selectedTicket = t),
          ),
        );
      },
    );
  }

  Widget _buildTicketDetail() {
    final t = _selectedTicket!;
    final messages = List.from(t['messages'] ?? []);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.orange.shade50,
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _selectedTicket = null)),
              Expanded(child: Text(t['subject'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              if (t['status'] != 'RESOLVED')
                ElevatedButton(
                  onPressed: () => _resolveTicket(t['_id']),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text('Resolve'),
                ),
            ],
          ),
        ),
        Expanded(
          child: messages.isEmpty
              ? const Center(child: Text('No messages yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    final isStaff = m['senderType'] == 'staff' || m['senderType'] == 'admin';
                    return Align(
                      alignment: isStaff ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                          color: isStaff ? Colors.orange.shade100 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m['message'] ?? '', style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(
                              m['createdAt']?.toString().substring(0, 16) ?? '',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (t['status'] != 'RESOLVED')
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyCtrl,
                    decoration: const InputDecoration(hintText: 'Type your reply...', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _sendReply(t['_id']),
                  icon: const Icon(Icons.send, color: Colors.orange),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }
}
