import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/analytics_controller.dart';

class FamilyRankingsTable extends GetView<AnalyticsController> {
  const FamilyRankingsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.familyRankings.isEmpty) {
        return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No family rankings data yet')));
      }

      return DataTable(
        columns: const [
          DataColumn(label: Text('Rank')),
          DataColumn(label: Text('Family Name')),
          DataColumn(label: Text('Owner')),
          DataColumn(label: Text('Members')),
          DataColumn(label: Text('Active')),
          DataColumn(label: Text('Points')),
          DataColumn(label: Text('Trend')),
        ],
        rows: controller.familyRankings.map((family) {
          final trendIcon = family['trend'] == 'up' ? Icons.trending_up : (family['trend'] == 'down' ? Icons.trending_down : Icons.trending_flat);
          final trendColor = family['trend'] == 'up' ? Colors.green : (family['trend'] == 'down' ? Colors.red : Colors.grey);
          return DataRow(cells: [
            DataCell(Text('#${family['rankingPosition'] ?? '-'}')),
            DataCell(Text(family['familyName'] ?? 'Unknown')),
            DataCell(Text(family['familyOwnerName'] ?? 'N/A')),
            DataCell(Text('${family['totalMembers'] ?? 0}')),
            DataCell(Text('${family['activeMembers'] ?? 0}')),
            DataCell(Text('${family['rankingPoints'] ?? 0}')),
            DataCell(Icon(trendIcon, color: trendColor, size: 20)),
          ]);
        }).toList(),
      );
    });
  }
}