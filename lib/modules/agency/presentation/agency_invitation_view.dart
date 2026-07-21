import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'agency_invitation_controller.dart';

class AgencyInvitationView extends GetView<AgencyInvitationController> {
  const AgencyInvitationView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agency Invitations'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                controller.fetchInbox();
              },
              tooltip: 'Refresh Lists',
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inbox),
                    const SizedBox(width: 8),
                    const Text('Inbox'),
                    Obx(() {
                      if (controller.pendingCount.value == 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Text(controller.pendingCount.value.toString(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const Tab(icon: Icon(Icons.outbox), text: 'Sent'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildSendInvitationCard(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildInboxList(),
                  _buildSentList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendInvitationCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Send Agency Invitation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.uidController,
                decoration: const InputDecoration(
                  labelText: 'Enter User UID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_search),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.messageController,
                decoration: const InputDecoration(
                  labelText: 'Message (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton.icon(
                    onPressed: controller.isLoading.value ? null : controller.sendInvitation,
                    icon: const Icon(Icons.send),
                    label: const Text('Send Invitation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInboxList() {
    return Obx(() {
      if (controller.isLoading.value && controller.invitations.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.invitations.isEmpty) {
        return const Center(child: Text('No pending invitations in your inbox.'));
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.invitations.length,
        itemBuilder: (context, index) {
          final invitation = controller.invitations[index];
          final agencyName = invitation['agencyName'] ?? 'Unknown Agency';
          final message = invitation['message'] ?? '';
          final createdAt = invitation['createdAt'] ?? '';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Text(
                  agencyName.isNotEmpty ? agencyName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text('Invitation from $agencyName'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isNotEmpty) Text(message),
                  Text(
                    'Received: ${_formatDate(createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => controller.acceptInvitation(invitation['_id']),
                    tooltip: 'Accept',
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => controller.rejectInvitation(invitation['_id']),
                    tooltip: 'Reject',
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildSentList() {
    return Obx(() {
      if (controller.isLoading.value && controller.invitations.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.invitations.isEmpty) {
        return const Center(child: Text('You have not sent any invitations.'));
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.invitations.length,
        itemBuilder: (context, index) {
          final invitation = controller.invitations[index];
          final targetUser = invitation['targetUser'] as Map? ?? {};
          final targetName = targetUser['name'] ?? 'Unknown User';
          final status = invitation['status'] ?? 'pending';
          final createdAt = invitation['createdAt'] ?? '';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(status),
                child: Icon(_getStatusIcon(status), color: Colors.white, size: 20),
              ),
              title: Text('Invitation to $targetName'),
              subtitle: Text(
                'Sent: ${_formatDate(createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              trailing: Text(
                status.toString().capitalizeFirst ?? status.toString(),
                style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.check;
      case 'rejected':
        return Icons.close;
      case 'pending':
      default:
        return Icons.hourglass_top;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}