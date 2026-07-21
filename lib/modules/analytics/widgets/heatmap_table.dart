import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/analytics_controller.dart';

class HeatMapTable extends GetView<AnalyticsController> {
  const HeatMapTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.heatMapData.isEmpty) {
        return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No heat map data yet')));
      }

      return DataTable(
        columns: const [
          DataColumn(label: Text('Country')),
          DataColumn(label: Text('State')),
          DataColumn(label: Text('City')),
          DataColumn(label: Text('Active Users')),
          DataColumn(label: Text('Time Spent (min)')),
          DataColumn(label: Text('Diamonds')),
        ],
        rows: controller.heatMapData.map((entry) {
          return DataRow(cells: [
            DataCell(Text(entry['country'] ?? 'Unknown')),
            DataCell(Text(entry['state'] ?? '')),
            DataCell(Text(entry['city'] ?? '')),
            DataCell(Text('${entry['activeUsers'] ?? 0}')),
            DataCell(Text('${entry['totalTimeSpentMinutes'] ?? 0}')),
            DataCell(Text('💎 ${entry['diamondsEarned'] ?? 0}')),
          ]);
        }).toList(),
      );
    });
  }
}