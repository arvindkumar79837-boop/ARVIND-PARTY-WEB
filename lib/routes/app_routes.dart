class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String users = '/users';
  static const String rooms = '/rooms';
  static const String gifts = '/gifts';
  static const String wallet = '/wallet';
  static const String vip = '/vip';
  static const String vipAdmin = '/vip-admin';
  static const String family = '/family';
  static const String families = '/families';
  static const String familyDetails = '/families/details';
  static const String agency = '/agency';
  static const String dealerManagement = '/dealer-management';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String myProfile = '/my-profile';
  static const String staff = '/staff';
  static const String events = '/events';
  static const String eventDashboard = '/events/dashboard';
  static const String tournaments = '/tournaments';
  static const String championships = '/championships';
  static const String treasureHunts = '/treasure-hunts';
  static const String luckyDraws = '/events/lucky-draws';
  static const String dailyTasks = '/events/daily-tasks';
  static const String invites = '/events/invites';
  static const String loginStreaks = '/events/login-streaks';
  static const String analyticsDashboard = '/analytics-dashboard';
  static const String localization = '/localization';
  static const String NotFound = '/not-found';
  static const String walletManagement = '/wallet-management';
  static const String pkBattleManagement = '/pk-battle-management';

  // Treasury routes
  static const String treasury = '/treasury';
  static const String treasuryVault = '/treasury/vault';
  static const String treasuryMint = '/treasury/mint';
  static const String treasuryDispatch = '/treasury/dispatch';

  // Withdrawal routes
  static const String withdrawals = '/withdrawals';
  static const String withdrawalsPending = '/withdrawals/pending';

  // Coin generation
  static const String coinGeneration = '/coin-generation';
  static const String coinOrders = '/coin-orders';

  // Game Center (WebView Mini-Games)
  static const String gameCenter = '/game-center';

  // Broadcast / Announcements
  static const String broadcasts = '/broadcasts';
  static const String announcements = '/announcements';

  // User sub-routes
  static const String usersVerify = '/users/verify';
  static const String usersBanned = '/users/banned';

  // Room sub-routes
  static const String roomsLive = '/rooms/live';

  // Recharge History
  static const String recharges = '/recharges';

  // Treasury sub-routes
  static const String treasuryBurn = '/treasury/burn';
  static const String treasuryVaultHistory = '/treasury/vault-history';

  // Coin Pricing (Owner-controlled rate management)
  static const String coinPricing = '/coin-pricing';

  // Coin Distribution (Owner generate + hierarchy transfer)
  static const String coinDistribution = '/coin-distribution';

  // Agency Targets (Owner create + progress dashboard)
  static const String agencyTargets = '/agency-targets';

  // Streamer Targets
  static const String targets = '/targets';
  static const String targetsCreate = '/targets/create';
  static const String targetsExchanges = '/targets/exchanges';
  static const String targetsAutoCycle = '/targets/auto-cycle';

  // Gift Economy Settings (Owner-only)
  static const String giftEconomySettings = '/gift-economy-settings';

  // Diamond Withdrawals (Owner + eligible staff)
  static const String diamondWithdrawals = '/diamond-withdrawals';

  // Content Reports (Moderation)
  static const String contentReports = '/content-reports';

  // Legal Documents (Privacy, Terms)
  static const String legalDocuments = '/legal-documents';

  // Support Tickets
  static const String supportTickets = '/support-tickets';

  // Agency sub-routes
  static const String agencyCommission = '/agency/commission';

  // Staff sub-routes
  static const String staffList = '/staff/list';
  static const String staffCreate = '/staff/create';
  static const String staffRoles = '/staff/roles';

  // Rewards
  static const String rewards = '/rewards';

  // Security module
  static const String securityDashboard = '/security';
  static const String securityFraudAlerts = '/security/fraud-alerts';
  static const String securityBannedDevices = '/security/banned-devices';
  static const String securityBlockedIps = '/security/blocked-ips';
  static const String securityAuditLogs = '/security/audit-logs';
  static const String securityLiveThreats = '/security/live-threats';

  // Infrastructure module
  static const String infrastructureDashboard = '/infrastructure';
  static const String infrastructureMonitoring = '/infrastructure/monitoring';
  static const String infrastructureScaling = '/infrastructure/scaling';
  static const String infrastructureBackup = '/infrastructure/backup';
  static const String infrastructureErrors = '/infrastructure/errors';
  static const String infrastructureAlerts = '/infrastructure/alerts';
  static const String infrastructureAuditLogs = '/infrastructure/audit-logs';
  static const String infrastructureDeployment = '/infrastructure/deployment';
  static const String infrastructureFeatureFlags = '/infrastructure/feature-flags';
  static const String infrastructureCDN = '/infrastructure/cdn';

  // ─── LUXURY / PREMIUM FEATURES ───────────────────────────────
  static const String subscriptionTiers = '/subscription-tiers';
  static const String systemSettings = '/system-settings';
  static const String musicLibrary = '/music-library';
  static const String roomTopics = '/room-topics';
  static const String feedModeration = '/feed-moderation';
  static const String revenueDashboard = '/revenue-dashboard';

  // Power Matrix (Owner room hierarchy engine)
  static const String powerMatrix = '/power-matrix';

  // YouTube Management (Room playlist sync)
  static const String youtubeManagement = '/youtube-management';
}
