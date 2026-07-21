import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/analytics_controller.dart';
import '../widgets/revenue_summary_grid.dart';
import '../widgets/revenue_timeseries_chart.dart';
import '../widgets/live_engagement_grid.dart';
import '../widgets/gift_analytics_table.dart';
import '../widgets/agency_rankings_table.dart';
import '../widgets/family_rankings_table.dart';
import '../widgets/heatmap_table.dart';

class AnalyticsDashboardView extends GetView<AnalyticsController> {
  const AnalyticsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Live Analytics & Revenue Dashboard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshAll(),
            tooltip: 'Refresh All Data',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'revenue_update') {
                controller.triggerRevenueSummaryUpdate();
              } else if (value == 'daily_aggregation') {
                controller.triggerDailyAggregation();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'revenue_update', child: Text('Trigger Revenue Update')),
              const PopupMenuItem(value: 'daily_aggregation', child: Text('Trigger Daily Aggregation')),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.isTrue && controller.revenueSummary.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.revenueSummary.value == null) {
          return const Center(
            child: Text('Could not load analytics data. Please try again later.'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══════════════════════════════════════════════════════════════
              // FEATURE 28: CORE REVENUE TRACKING
              // ═══════════════════════════════════════════════════════════════
              _buildSectionHeader('💰 Core Revenue Tracking (कमाई का लाइव लेखा-जोखा)', Icons.account_balance),
              const SizedBox(height: 16),
              RevenueSummaryGrid(summary: controller.revenueSummary.value!),
              const SizedBox(height: 24),

              _buildSectionHeader('📈 Revenue Trends (This Hour)', Icons.show_chart),
              const SizedBox(height: 16),
              SizedBox(height: 300, child: RevenueTimeseriesChart()),
              const SizedBox(height: 32),

              // ═══════════════════════════════════════════════════════════════
              // FEATURE 29: LIVE BEHAVIOR & APP ENGAGEMENT
              // ═══════════════════════════════════════════════════════════════
              _buildSectionHeader('👥 Live Behavior & App Engagement (यूज़र्स की हरकतों पर नज़र)', Icons.people),
              const SizedBox(height: 16),
              LiveEngagementGrid(),
              const SizedBox(height: 24),

              _buildSectionHeader('🎁 Gift Analytics (गिफ्टिंग विश्लेषण)', Icons.card_giftcard),
              const SizedBox(height: 16),
              GiftAnalyticsTable(),
              const SizedBox(height: 32),

              // ═══════════════════════════════════════════════════════════════
              // FEATURE 30: DEPARTMENTAL PERFORMANCE
              // ═══════════════════════════════════════════════════════════════
              _buildSectionHeader('🏢 Agency Performance (एजेंसी ट्रैकर)', Icons.business),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: AgencyRankingsTable(),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('👪 Family Performance (फैमिली ट्रैकर)', Icons.family_restroom),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: FamilyRankingsTable(),
              ),
              const SizedBox(height: 32),

              // ═══════════════════════════════════════════════════════════════
              // FEATURE 31: ADVANCED DATA VISUALIZATION
              // ═══════════════════════════════════════════════════════════════
              _buildSectionHeader('🌍 Activity Heat Map (एक्टिविटी हिट-मैप)', Icons.map),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: HeatMapTable(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blueGrey),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}