import 'package:flutter/material.dart';
import 'package:arvind_party_web/modules/analytics/models/revenue_summary.dart';
import 'summary_card.dart';

class RevenueSummaryGrid extends StatelessWidget {
  final RevenueSummary summary;

  const RevenueSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: _getCrossAxisCount(context),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      children: [
        SummaryCard(
          title: 'Total Revenue',
          value: summary.totalRevenue,
          icon: Icons.bar_chart,
          color: Colors.green,
        ),
        SummaryCard(
          title: "Today's Revenue",
          value: summary.todayRevenue,
          icon: Icons.today,
          color: Colors.blue,
        ),
        SummaryCard(
          title: "This Week's Revenue",
          value: summary.thisWeekRevenue,
          icon: Icons.calendar_view_week,
          color: Colors.orange,
        ),
        SummaryCard(
          title: "This Month's Revenue",
          value: summary.thisMonthRevenue,
          icon: Icons.calendar_month,
          color: Colors.purple,
        ),
        SummaryCard(
          title: 'Total Payouts',
          value: summary.totalPayouts,
          icon: Icons.account_balance_wallet,
          color: Colors.redAccent,
        ),
        SummaryCard(
          title: 'Pending Withdrawals',
          value: summary.pendingWithdrawalsAmount,
          icon: Icons.hourglass_top,
          color: Colors.amber[700]!,
        ),
      ],
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 3;
    } else if (width > 800) {
      return 2;
    } else {
      return 1;
    }
  }
}
