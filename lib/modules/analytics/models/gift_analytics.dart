class GiftAnalytics {
  final List<Map<String, dynamic>> topGifts;
  final List<Map<String, dynamic>> topRooms;
  final List<Map<String, dynamic>> progressiveBlasts;

  GiftAnalytics({required this.topGifts, required this.topRooms, required this.progressiveBlasts});

  factory GiftAnalytics.fromJson(Map<String, dynamic> json) {
    return GiftAnalytics(
      topGifts: (json['topGifts'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
      topRooms: (json['topRooms'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
      progressiveBlasts: (json['progressiveBlasts'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
    );
  }
}