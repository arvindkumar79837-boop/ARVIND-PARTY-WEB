import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/analytics_controller.dart';

class AgencyRankingsTable extends GetView<AnalyticsController> {
  const AgencyRankingsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.agencyRankings.isEmpty) {
        return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No agency rankings data yet')));
      }

      return DataTable(
        columns: const [
          DataColumn(label: Text('Rank')),
          DataColumn(label: Text('Agency Name')),
          DataColumn(label: Text('Owner')),
          DataColumn(label: Text('Hosts')),
          DataColumn(label: Text('Active Hosts')),
          DataColumn(label: Text('Diamonds')),
          DataColumn(label: Text('Trend')),
        ],
        rows: controller.agencyRankings.map((agency) {
          final trendIcon = agency['trend'] == 'up' ? Icons.trending_up : (agency['trend'] == 'down' ? Icons.trending_down : Icons.trending_flat);
          final trendColor = agency['trend'] == 'up' ? Colors.green : (agency['trend'] == 'down' ? Colors.red : Colors.grey);
          return DataRow(cells: [
            DataCell(Text('#${agency['rankingPosition'] ?? '-'}')),
            DataCell(Text(agency['agencyName'] ?? 'Unknown')),
            DataCell(Text(agency['agencyOwnerName'] ?? 'N/A')),
            DataCell(Text('${agency['totalHosts'] ?? 0}')),
            DataCell(Text('${agency['activeHosts'] ?? 0}')),
            DataCell(Text('💎 ${agency['totalDiamondsEarned'] ?? 0}')),
            DataCell(Icon(trendIcon, color: trendColor, size: 20)),
          ]);
        }).toList(),
      );
    });
  }
}