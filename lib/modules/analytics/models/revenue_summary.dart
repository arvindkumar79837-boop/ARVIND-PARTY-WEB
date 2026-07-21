class RevenueSummary {
  final double totalRevenue;
  final double todayRevenue;
  final double thisWeekRevenue;
  final double thisMonthRevenue;
  final double totalPayouts;
  final double pendingWithdrawalsAmount;
  final double totalDiamondsEarned;
  final double todayDiamondsEarned;
  final double thisWeekDiamondsEarned;
  final double thisMonthDiamondsEarned;
  final int activeRechargeUsers;
  final double coinSellerTotalSales;
  final double totalCommissionPaid;

  RevenueSummary({
    required this.totalRevenue,
    required this.todayRevenue,
    required this.thisWeekRevenue,
    required this.thisMonthRevenue,
    required this.totalPayouts,
    required this.pendingWithdrawalsAmount,
    required this.totalDiamondsEarned,
    required this.todayDiamondsEarned,
    required this.thisWeekDiamondsEarned,
    required this.thisMonthDiamondsEarned,
    required this.activeRechargeUsers,
    required this.coinSellerTotalSales,
    required this.totalCommissionPaid,
  });

  factory RevenueSummary.fromJson(Map<String, dynamic> json) {
    return RevenueSummary(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0.0,
      thisWeekRevenue: (json['thisWeekRevenue'] as num?)?.toDouble() ?? 0.0,
      thisMonthRevenue: (json['thisMonthRevenue'] as num?)?.toDouble() ?? 0.0,
      totalPayouts: (json['totalPayouts'] as num?)?.toDouble() ?? 0.0,
      pendingWithdrawalsAmount: (json['pendingWithdrawalsAmount'] as num?)?.toDouble() ?? 0.0,
      totalDiamondsEarned: (json['totalDiamondsEarned'] as num?)?.toDouble() ?? 0.0,
      todayDiamondsEarned: (json['todayDiamondsEarned'] as num?)?.toDouble() ?? 0.0,
      thisWeekDiamondsEarned: (json['thisWeekDiamondsEarned'] as num?)?.toDouble() ?? 0.0,
      thisMonthDiamondsEarned: (json['thisMonthDiamondsEarned'] as num?)?.toDouble() ?? 0.0,
      activeRechargeUsers: (json['activeRechargeUsers'] as num?)?.toInt() ?? 0,
      coinSellerTotalSales: (json['coinSellerTotalSales'] as num?)?.toDouble() ?? 0.0,
      totalCommissionPaid: (json['totalCommissionPaid'] as num?)?.toDouble() ?? 0.0,
    );
  }
}