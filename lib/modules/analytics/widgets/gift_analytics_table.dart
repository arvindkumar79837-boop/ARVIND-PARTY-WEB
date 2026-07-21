import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/analytics_controller.dart';

class GiftAnalyticsTable extends GetView<AnalyticsController> {
  const GiftAnalyticsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final giftData = controller.giftAnalytics.value;
      if (giftData == null) {
        return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No gift analytics data')));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (giftData.topGifts.isNotEmpty) ...[
            const Text('🎁 Top Gifts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DataTable(
              columns: const [
                DataColumn(label: Text('Rank')),
                DataColumn(label: Text('Gift Name')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Times Sent')),
                DataColumn(label: Text('Diamond Value')),
                DataColumn(label: Text('Blasts')),
              ],
              rows: giftData.topGifts.take(10).map((gift) {
                return DataRow(cells: [
                  DataCell(Text(gift['totalSentCount'] is int ? (giftData.topGifts.indexOf(gift) + 1).toString() : '-')),
                  DataCell(Text(gift['giftName'] ?? 'Unknown')),
                  DataCell(Text(gift['giftCategory'] ?? '-')),
                  DataCell(Text('${gift['totalSentCount'] ?? 0}')),
                  DataCell(Text('💎 ${gift['totalDiamondValue'] ?? 0}')),
                  DataCell(Text('${gift['progressiveBlastCount'] ?? 0}')),
                ]);
              }).toList(),
            ),
          ],
          if (giftData.topRooms.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('🔥 Top Gifted Rooms', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DataTable(
              columns: const [
                DataColumn(label: Text('Room')),
                DataColumn(label: Text('Total Gifts')),
                DataColumn(label: Text('Diamond Value')),
                DataColumn(label: Text('Highest Gift')),
              ],
              rows: giftData.topRooms.map((room) {
                return DataRow(cells: [
                  DataCell(Text(room['roomName'] ?? 'Unknown')),
                  DataCell(Text('${room['totalGifts'] ?? 0}')),
                  DataCell(Text('💎 ${room['totalDiamondValue'] ?? 0}')),
                  DataCell(Text('💎 ${room['highestSingleGift'] ?? 0}')),
                ]);
              }).toList(),
            ),
          ],
          if (giftData.progressiveBlasts.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('💥 Progressive Blasts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DataTable(
              columns: const [
                DataColumn(label: Text('Room')),
                DataColumn(label: Text('Total Blasts')),
                DataColumn(label: Text('Max Value')),
              ],
              rows: giftData.progressiveBlasts.map((blast) {
                return DataRow(cells: [
                  DataCell(Text(blast['roomName'] ?? 'Unknown')),
                  DataCell(Text('${blast['totalBlasts'] ?? 0}')),
                  DataCell(Text('💎 ${blast['maxBlastValue'] ?? 0}')),
                ]);
              }).toList(),
            ),
          ],
        ],
      );
    });
  }
}