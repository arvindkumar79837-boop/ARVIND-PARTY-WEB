class WebViewGameModel {
  final String id;
  final String name;
  final String description;
  final String gameType;
  final String gameUrl;
  final String thumbnailUrl;
  final bool isActive;
  final int minBetAmount;
  final int maxBetAmount;
  final int houseEdgePercentage;
  final String rewardType;
  final int coinToDiamondRatio;
  final double diamondToCoinRatio;
  final int totalPlays;
  final int totalVolume;
  final int totalWinnings;
  final String createdBy;
  final List<String> tags;
  final Map<String, dynamic> configuration;
  final DateTime createdAt;
  final DateTime updatedAt;

  WebViewGameModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.gameType,
    required this.gameUrl,
    this.thumbnailUrl = '',
    this.isActive = true,
    this.minBetAmount = 10,
    this.maxBetAmount = 10000,
    this.houseEdgePercentage = 5,
    this.rewardType = 'COINS',
    this.coinToDiamondRatio = 100,
    this.diamondToCoinRatio = 0.01,
    this.totalPlays = 0,
    this.totalVolume = 0,
    this.totalWinnings = 0,
    required this.createdBy,
    this.tags = const [],
    this.configuration = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory WebViewGameModel.fromJson(Map<String, dynamic> json) {
    return WebViewGameModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      gameType: json['gameType'] ?? 'WEB_BASED',
      gameUrl: json['gameUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      isActive: json['isActive'] ?? true,
      minBetAmount: json['minBetAmount'] ?? 10,
      maxBetAmount: json['maxBetAmount'] ?? 10000,
      houseEdgePercentage: json['houseEdgePercentage'] ?? 5,
      rewardType: json['rewardType'] ?? 'COINS',
      coinToDiamondRatio: json['coinToDiamondRatio'] ?? 100,
      diamondToCoinRatio: (json['diamondToCoinRatio'] ?? 0.01).toDouble(),
      totalPlays: json['totalPlays'] ?? 0,
      totalVolume: json['totalVolume'] ?? 0,
      totalWinnings: json['totalWinnings'] ?? 0,
      createdBy: json['createdBy']?['_id']?.toString() ?? json['createdBy']?.toString() ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      configuration: Map<String, dynamic>.from(json['configuration'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'gameType': gameType,
      'gameUrl': gameUrl,
      'thumbnailUrl': thumbnailUrl,
      'isActive': isActive,
      'minBetAmount': minBetAmount,
      'maxBetAmount': maxBetAmount,
      'houseEdgePercentage': houseEdgePercentage,
      'rewardType': rewardType,
      'coinToDiamondRatio': coinToDiamondRatio,
      'diamondToCoinRatio': diamondToCoinRatio,
      'totalPlays': totalPlays,
      'totalVolume': totalVolume,
      'totalWinnings': totalWinnings,
      'createdBy': createdBy,
      'tags': tags,
      'configuration': configuration,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class GameLedgerEntry {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String gameId;
  final String gameName;
  final String gameType;
  final int betAmount;
  final int winAmount;
  final String rewardType;
  final DateTime createdAt;

  GameLedgerEntry({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    required this.gameId,
    required this.gameName,
    required this.gameType,
    required this.betAmount,
    required this.winAmount,
    required this.rewardType,
    required this.createdAt,
  });

  factory GameLedgerEntry.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final game = json['gameId'] ?? {};
    return GameLedgerEntry(
      id: json['_id'] ?? '',
      userId: user['_id']?.toString() ?? '',
      userName: user['name'] ?? '',
      userAvatar: user['avatar'] ?? '',
      gameId: game['_id']?.toString() ?? '',
      gameName: game['name'] ?? '',
      gameType: game['gameType'] ?? '',
      betAmount: json['betAmount'] ?? 0,
      winAmount: json['winAmount'] ?? 0,
      rewardType: json['rewardType'] ?? 'COINS',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class GameLedgerSummary {
  final int totalVolume;
  final int totalWinnings;
  final int netProfit;
  final int totalSessions;

  GameLedgerSummary({
    required this.totalVolume,
    required this.totalWinnings,
    required this.netProfit,
    required this.totalSessions,
  });

  factory GameLedgerSummary.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] ?? {};
    return GameLedgerSummary(
      totalVolume: summary['totalVolume'] ?? 0,
      totalWinnings: summary['totalWinnings'] ?? 0,
      netProfit: summary['netProfit'] ?? 0,
      totalSessions: summary['totalSessions'] ?? 0,
    );
  }
}

class GameLeaderboardEntry {
  final String userId;
  final String name;
  final String avatar;
  final int totalWon;
  final int sessionsPlayed;

  GameLeaderboardEntry({
    required this.userId,
    required this.name,
    this.avatar = '',
    required this.totalWon,
    required this.sessionsPlayed,
  });

  factory GameLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return GameLeaderboardEntry(
      userId: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      totalWon: json['totalWon'] ?? 0,
      sessionsPlayed: json['sessionsPlayed'] ?? 0,
    );
  }
}