class LiveAnalytics {
  final int activeVoiceRooms;
  final int totalSeats;
  final int filledSeats;
  final int onlineUsers;
  final int totalUsersInRooms;

  LiveAnalytics({
    required this.activeVoiceRooms,
    required this.totalSeats,
    required this.filledSeats,
    required this.onlineUsers,
    required this.totalUsersInRooms,
  });

  factory LiveAnalytics.fromJson(Map<String, dynamic> json) {
    return LiveAnalytics(
      activeVoiceRooms: (json['activeVoiceRooms'] as num?)?.toInt() ?? 0,
      totalSeats: (json['totalSeats'] as num?)?.toInt() ?? 0,
      filledSeats: (json['filledSeats'] as num?)?.toInt() ?? 0,
      onlineUsers: (json['onlineUsers'] as num?)?.toInt() ?? 0,
      totalUsersInRooms: (json['totalUsersInRooms'] as num?)?.toInt() ?? 0,
    );
  }
}