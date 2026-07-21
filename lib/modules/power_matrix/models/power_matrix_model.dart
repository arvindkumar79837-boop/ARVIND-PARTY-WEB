// ═══════════════════════════════════════════════════════════════════════════
// FILE: arvind_party_web/lib/modules/power_matrix/models/power_matrix_model.dart
// ARVIND PARTY - POWER MATRIX MODELS (Web Panel)
// ═══════════════════════════════════════════════════════════════════════════

class PowerMatrixRule {
  final int level;
  final bool canMuteLowerLevels;
  final bool canKickLowerLevels;
  final int muteLevelThreshold;
  final int kickLevelThreshold;
  final int vipProtectionLevel;
  final List<SpecialPrivilege> specialPrivileges;

  PowerMatrixRule({
    required this.level,
    required this.canMuteLowerLevels,
    required this.canKickLowerLevels,
    required this.muteLevelThreshold,
    required this.kickLevelThreshold,
    required this.vipProtectionLevel,
    this.specialPrivileges = const [],
  });

  factory PowerMatrixRule.fromJson(Map<String, dynamic> json) => PowerMatrixRule(
    level: json['level'] ?? 0,
    canMuteLowerLevels: json['canMuteLowerLevels'] ?? false,
    canKickLowerLevels: json['canKickLowerLevels'] ?? false,
    muteLevelThreshold: json['muteLevelThreshold'] ?? 0,
    kickLevelThreshold: json['kickLevelThreshold'] ?? 0,
    vipProtectionLevel: json['vipProtectionLevel'] ?? 0,
    specialPrivileges: (json['specialPrivileges'] as List?)
        ?.map((e) => SpecialPrivilege.fromJson(e))
        .toList() ?? [],
  );

  Map<String, dynamic> toJson() => {
    'level': level,
    'canMuteLowerLevels': canMuteLowerLevels,
    'canKickLowerLevels': canKickLowerLevels,
    'muteLevelThreshold': muteLevelThreshold,
    'kickLevelThreshold': kickLevelThreshold,
    'vipProtectionLevel': vipProtectionLevel,
    'specialPrivileges': specialPrivileges.map((e) => e.toJson()).toList(),
  };
}

class SpecialPrivilege {
  final String privilege;
  final int appliesToLevel;
  final String description;

  SpecialPrivilege({
    required this.privilege,
    required this.appliesToLevel,
    this.description = '',
  });

  factory SpecialPrivilege.fromJson(Map<String, dynamic> json) => SpecialPrivilege(
    privilege: json['privilege'] ?? '',
    appliesToLevel: json['appliesToLevel'] ?? 0,
    description: json['description'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'privilege': privilege,
    'appliesToLevel': appliesToLevel,
    'description': description,
  };
}

class PowerMatrixGlobalSettings {
  final bool ownerCanOverrideAll;
  final bool adminCanOverrideVip;
  final int svipImmunityLevel;
  final int vipImmunityLevel;
  final int levelDifferenceRequired;

  PowerMatrixGlobalSettings({
    required this.ownerCanOverrideAll,
    required this.adminCanOverrideVip,
    required this.svipImmunityLevel,
    required this.vipImmunityLevel,
    required this.levelDifferenceRequired,
  });

  factory PowerMatrixGlobalSettings.fromJson(Map<String, dynamic> json) =>
      PowerMatrixGlobalSettings(
        ownerCanOverrideAll: json['ownerCanOverrideAll'] ?? true,
        adminCanOverrideVip: json['adminCanOverrideVip'] ?? true,
        svipImmunityLevel: json['svipImmunityLevel'] ?? 10,
        vipImmunityLevel: json['vipImmunityLevel'] ?? 8,
        levelDifferenceRequired: json['levelDifferenceRequired'] ?? 2,
      );

  Map<String, dynamic> toJson() => {
    'ownerCanOverrideAll': ownerCanOverrideAll,
    'adminCanOverrideVip': adminCanOverrideVip,
    'svipImmunityLevel': svipImmunityLevel,
    'vipImmunityLevel': vipImmunityLevel,
    'levelDifferenceRequired': levelDifferenceRequired,
  };
}

class PowerMatrix {
  final String id;
  final bool isActive;
  final List<PowerMatrixRule> rules;
  final PowerMatrixGlobalSettings globalSettings;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  PowerMatrix({
    required this.id,
    required this.isActive,
    required this.rules,
    required this.globalSettings,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PowerMatrix.fromJson(Map<String, dynamic> json) => PowerMatrix(
    id: json['_id'] ?? json['id'] ?? '',
    isActive: json['isActive'] ?? true,
    rules: (json['rules'] as List)
        .map((e) => PowerMatrixRule.fromJson(e))
        .toList(),
    globalSettings: PowerMatrixGlobalSettings.fromJson(json['globalSettings'] ?? {}),
    version: json['version'] ?? 1,
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'isActive': isActive,
    'rules': rules.map((e) => e.toJson()).toList(),
    'globalSettings': globalSettings.toJson(),
    'version': version,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class PowerCheckResult {
  final bool allowed;
  final String reason;
  final int actorLevel;
  final int targetLevel;
  final String actorRole;
  final String targetRole;
  final String action;

  PowerCheckResult({
    required this.allowed,
    required this.reason,
    required this.actorLevel,
    required this.targetLevel,
    required this.actorRole,
    required this.targetRole,
    required this.action,
  });

  factory PowerCheckResult.fromJson(Map<String, dynamic> json) => PowerCheckResult(
    allowed: json['allowed'] ?? false,
    reason: json['reason'] ?? '',
    actorLevel: json['actorLevel'] ?? 0,
    targetLevel: json['targetLevel'] ?? 0,
    actorRole: json['actorRole'] ?? '',
    targetRole: json['targetRole'] ?? '',
    action: json['action'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'allowed': allowed,
    'reason': reason,
    'actorLevel': actorLevel,
    'targetLevel': targetLevel,
    'actorRole': actorRole,
    'targetRole': targetRole,
    'action': action,
  };
}

class PowerMatrixHistory {
  final String id;
  final int version;
  final bool isActive;
  final PowerMatrixGlobalSettings globalSettings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  PowerMatrixHistory({
    required this.id,
    required this.version,
    required this.isActive,
    required this.globalSettings,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory PowerMatrixHistory.fromJson(Map<String, dynamic> json) =>
      PowerMatrixHistory(
        id: json['_id'] ?? json['id'] ?? '',
        version: json['version'] ?? 1,
        isActive: json['isActive'] ?? false,
        globalSettings: PowerMatrixGlobalSettings.fromJson(json['globalSettings'] ?? {}),
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
        createdBy: json['createdBy']?['username'],
        updatedBy: json['updatedBy']?['username'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'version': version,
    'isActive': isActive,
    'globalSettings': globalSettings.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'createdBy': createdBy,
    'updatedBy': updatedBy,
  };
}