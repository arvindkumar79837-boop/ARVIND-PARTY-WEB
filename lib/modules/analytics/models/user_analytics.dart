class UserAnalytics {
  final int dau;
  final int wau;
  final int mau;
  final int newRegistrationsToday;
  final int avgTimeSpentMinutes;
  final int totalActiveUsers;
  final int totalUsers;

  UserAnalytics({
    required this.dau,
    required this.wau,
    required this.mau,
    required this.newRegistrationsToday,
    required this.avgTimeSpentMinutes,
    required this.totalActiveUsers,
    required this.totalUsers,
  });

  factory UserAnalytics.fromJson(Map<String, dynamic> json) {
    return UserAnalytics(
      dau: (json['dau'] as num?)?.toInt() ?? 0,
      wau: (json['wau'] as num?)?.toInt() ?? 0,
      mau: (json['mau'] as num?)?.toInt() ?? 0,
      newRegistrationsToday: (json['newRegistrationsToday'] as num?)?.toInt() ?? 0,
      avgTimeSpentMinutes: (json['avgTimeSpentMinutes'] as num?)?.toInt() ?? 0,
      totalActiveUsers: (json['totalActiveUsers'] as num?)?.toInt() ?? 0,
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
    );
  }
}