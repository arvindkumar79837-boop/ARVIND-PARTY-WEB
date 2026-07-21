import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/analytics_controller.dart';

class RevenueTimeseriesChart extends GetView<AnalyticsController> {
  const RevenueTimeseriesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final chart = controller.chartData.value;
      if (chart == null) {
        return const Card(
          child: Center(child: Text('No chart data available yet')),
        );
      }

      final hourly = chart['hourly'] as List<dynamic>? ?? [];
      if (hourly.isEmpty) {
        return const Card(
          child: Center(child: Text('No hourly data available yet')),
        );
      }

      final spots = <FlSpot>[];
      double maxY = 0;
      for (int i = 0; i < hourly.length; i++) {
        final entry = hourly[i] as Map<String, dynamic>;
        final revenue = (entry['revenue'] as num?)?.toDouble() ?? 0;
        if (revenue > maxY) maxY = revenue;
        spots.add(FlSpot(i.toDouble(), revenue));
      }

      if (maxY == 0) maxY = 1000;
      final maxYRounded = (maxY * 1.2).ceilToDouble();

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xff020227),
        child: Padding(
          padding: const EdgeInsets.only(top: 24, right: 24, bottom: 12, left: 8),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: maxYRounded / 4,
                getDrawingHorizontalLine: (value) {
                  return const FlLine(color: Color(0xff37434d), strokeWidth: 1);
                },
                getDrawingVerticalLine: (value) {
                  return const FlLine(color: Color(0xff37434d), strokeWidth: 1);
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() % 2 != 0) return const SizedBox.shrink();
                      return SideTitleWidget(
                        meta: meta,
                        child: Text('${value.toInt()}:00', style: const TextStyle(color: Color(0xff68737d), fontSize: 10)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    interval: maxYRounded / 4,
                    getTitlesWidget: (value, meta) {
                      String text;
                      if (value >= 100000) {
                        text = '${(value / 100000).toStringAsFixed(1)}L';
                      } else if (value >= 1000) {
                        text = '${(value / 1000).toStringAsFixed(1)}K';
                      } else {
                        text = value.toInt().toString();
                      }
                      return Text(text, style: const TextStyle(color: Color(0xff67727d), fontSize: 12));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d)),
              ),
              minX: 0,
              maxX: (hourly.length - 1).toDouble(),
              minY: 0,
              maxY: maxYRounded,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  gradient: const LinearGradient(colors: [Colors.cyan, Colors.blue]),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [Colors.cyan.withValues(alpha: 0.3), Colors.blue.withValues(alpha: 0.3)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

