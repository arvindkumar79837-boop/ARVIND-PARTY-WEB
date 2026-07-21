import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/analytics_controller.dart';

class LiveEngagementGrid extends GetView<AnalyticsController> {
  const LiveEngagementGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final userData = controller.userAnalytics.value;
      final liveData = controller.liveAnalytics.value;

      return GridView.count(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.5,
        children: [
          _buildCard('DAU', '${userData?.dau ?? 0}', Colors.blue, Icons.people),
          _buildCard('WAU', '${userData?.wau ?? 0}', Colors.green, Icons.people_outline),
          _buildCard('MAU', '${userData?.mau ?? 0}', Colors.purple, Icons.people_alt),
          _buildCard('New Today', '${userData?.newRegistrationsToday ?? 0}', Colors.orange, Icons.person_add),
          _buildCard('Avg Time', '${userData?.avgTimeSpentMinutes ?? 0} min', Colors.cyan, Icons.timer),
          _buildCard('Active Rooms', '${liveData?.activeVoiceRooms ?? 0}', Colors.redAccent, Icons.mic),
          _buildCard('Online', '${liveData?.onlineUsers ?? 0}', Colors.teal, Icons.wifi),
          _buildCard('Seats Filled', '${liveData?.filledSeats ?? 0}/${liveData?.totalSeats ?? 0}', Colors.amber, Icons.event_seat),
        ],
      );
    });
  }

  Widget _buildCard(String label, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}