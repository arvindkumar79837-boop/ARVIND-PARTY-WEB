// ═══════════════════════════════════════════════════════════════════════════
// MODEL: EventModel - Web Panel Event Management
// ═══════════════════════════════════════════════════════════════════════════

class EventModel {
  final String id;
  final String eventName;
  final String eventType;
  final String title;
  final String description;
  final String bannerImage;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final bool isActive;
  final bool isRecurring;
  final String recurrencePattern;
  final Map<String, dynamic> rewardDetails;
  final Map<String, dynamic> requirements;
  final int maxParticipants;
  final int participantsCount;
  final Map<String, dynamic> metadata;
  final Map<String, dynamic> config;
  final String createdById;
  final String? updatedById;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.eventName,
    required this.eventType,
    required this.title,
    required this.description,
    required this.bannerImage,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.isActive,
    required this.isRecurring,
    required this.recurrencePattern,
    required this.rewardDetails,
    required this.requirements,
    required this.maxParticipants,
    required this.participantsCount,
    required this.metadata,
    required this.config,
    required this.createdById,
    this.updatedById,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id'] ?? json['id'] ?? '',
      eventName: json['event_name'] ?? '',
      eventType: json['event_type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      bannerImage: json['banner_image'] ?? '',
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : DateTime.now(),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : DateTime.now(),
      status: json['status'] ?? 'upcoming',
      isActive: json['is_active'] ?? true,
      isRecurring: json['is_recurring'] ?? false,
      recurrencePattern: json['recurrence_pattern'] ?? 'none',
      rewardDetails: json['reward_details'] ?? {},
      requirements: json['requirements'] ?? {},
      maxParticipants: json['max_participants'] ?? 0,
      participantsCount: json['participants_count'] ?? 0,
      metadata: json['metadata'] ?? {},
      config: json['config'] ?? {},
      createdById: json['created_by'] ?? '',
      updatedById: json['updated_by'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'event_name': eventName,
      'event_type': eventType,
      'title': title,
      'description': description,
      'banner_image': bannerImage,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status,
      'is_active': isActive,
      'is_recurring': isRecurring,
      'recurrence_pattern': recurrencePattern,
      'reward_details': rewardDetails,
      'requirements': requirements,
      'max_participants': maxParticipants,
      'participants_count': participantsCount,
      'metadata': metadata,
      'config': config,
      'created_by': createdById,
      'updated_by': updatedById,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isUpcoming => status == 'upcoming';
  bool get isActiveEvent => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  int get rewardCoins => rewardDetails['coins'] ?? 0;
  int get rewardDiamonds => rewardDetails['diamonds'] ?? 0;
  int get rewardXp => rewardDetails['xp'] ?? 0;
  int get rewardVipDays => rewardDetails['vipDays'] ?? 0;
}