import 'package:get/get.dart';
import '../modules/dashboard/dashboard_view.dart';
import '../modules/vip/views/vip_admin_view.dart';
import '../modules/vip/vip_management_view.dart';
import '../modules/family_management/family_management_view.dart';
import '../modules/security/security_dashboard_view.dart';
import '../modules/security/security_binding.dart';
import '../modules/events/event_management_view.dart';
import '../modules/events/views/event_management_dashboard_view.dart';
import '../modules/events/bindings/event_binding.dart';
import '../modules/events/lucky_draw_management_view.dart';
import '../modules/events/daily_task_management_view.dart';
import '../modules/events/invite_management_view.dart';
import '../modules/events/login_streak_management_view.dart';
import '../modules/analytics/views/analytics_dashboard_view.dart';
import '../modules/analytics/bindings/analytics_binding.dart';
import '../modules/localization/localization_management_view.dart';
import '../modules/wallets/wallet_management_view.dart';
import '../modules/pk_battle/pk_battle_management_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/users/user_management_view.dart';
import '../modules/rooms/room_management_view.dart';
import '../modules/gifts/gift_management_view.dart';
import '../modules/families/family_details_view.dart';
import '../modules/agency/agency_dashboard_view.dart';
import '../modules/dealer_management/dealer_management_view.dart';
import '../modules/reports/reports_view.dart';
import '../modules/settings/settings_view.dart';
import '../modules/staff_management/staff_list_view.dart';
import '../modules/profile/my_profile_view.dart';
import '../modules/infrastructure/infrastructure_dashboard_view.dart';
import '../modules/treasury/treasury_vault_view.dart';
import '../modules/withdrawals/withdrawals_view.dart';
import '../modules/targets/target_manager_view.dart';
import '../modules/coin_generation/coin_generation_view.dart';
import '../modules/coin_orders/coin_orders_view.dart';
import '../modules/rewards/rewards_view.dart';
import '../modules/notifications/broadcast_view.dart';
import '../modules/games/views/games_management_view.dart';
import '../modules/games/controllers/game_controller.dart';
import '../modules/coin_pricing/coin_pricing_view.dart';
import '../modules/coin_distribution/coin_distribution_view.dart';
import '../modules/agency_targets/agency_target_view.dart';
import '../modules/gift_economy_settings/gift_economy_settings_view.dart';
import '../modules/diamond_withdrawals/diamond_withdrawals_view.dart';
import '../modules/content_reports/content_reports_view.dart';
import '../modules/legal_documents/legal_documents_view.dart';
import '../modules/support_tickets/support_tickets_view.dart';
import '../modules/subscription_tiers/subscription_tiers_view.dart';
import '../modules/system_settings/system_settings_view.dart';
import '../modules/music_library/music_library_view.dart';
import '../modules/room_topics/room_topics_view.dart';
import '../modules/feed_moderation/feed_moderation_view.dart';
import '../modules/revenue_dashboard/revenue_dashboard_view.dart';
import 'app_routes.dart';
import 'auth_guard.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.treasury,
      page: () => const TreasuryVaultView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.treasuryVault,
      page: () => const TreasuryVaultView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.treasuryMint,
      page: () => const TreasuryVaultView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.treasuryDispatch,
      page: () => const TreasuryVaultView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.withdrawals,
      page: () => const WithdrawalsView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.withdrawalsPending,
      page: () => const WithdrawalsView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.coinGeneration,
      page: () => const CoinGenerationView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.gameCenter,
      page: () => const GamesManagementView(),
      binding: BindingsBuilder(() => Get.put(GameController())),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.rewards,
      page: () => const RewardsView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.broadcasts,
      page: () => const BroadcastView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.announcements,
      page: () => const BroadcastView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.coinOrders,
      page: () => const CoinOrdersView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.securityDashboard,
      page: () => const SecurityDashboardView(),
      binding: SecurityBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.vipAdmin,
      page: () => const VipAdminView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.families,
      page: () => const FamilyManagementView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.events,
      page: () => const EventManagementView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.eventDashboard,
      page: () => const EventManagementDashboardView(),
      binding: EventBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.luckyDraws,
      page: () => const LuckyDrawManagementView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.dailyTasks,
      page: () => const DailyTaskManagementView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.invites,
      page: () => const InviteManagementView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.loginStreaks,
      page: () => const LoginStreakManagementView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.analyticsDashboard,
      page: () => const AnalyticsDashboardView(),
      binding: AnalyticsBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.walletManagement,
      page: () => const WalletManagementView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.pkBattleManagement,
      page: () => PkBattleManagementView(),
      middlewares: [AuthGuard()],
    ),
    // ── Core admin pages ─────────────────────────────────────────
    GetPage(
      name: AppRoutes.users,
      page: () => const UserManagementView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.rooms,
      page: () => RoomManagementView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.gifts,
      page: () => GiftManagementView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.wallet,
      page: () => const WalletManagementView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.vip,
      page: () => const VipManagementView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.family,
      page: () => const FamilyManagementView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.familyDetails,
      page: () => FamilyDetailsView(familyId: Get.parameters['familyId'] ?? ''),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.agency,
      page: () => AgencyDashboardView(
        agencyId: Get.parameters['agencyId'] ?? '',
        agencyName: Get.parameters['agencyName'] ?? 'Agency',
      ),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.dealerManagement,
      page: () => const DealerManagementView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.myProfile,
      page: () => const MyProfileView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.staff,
      page: () => const StaffListView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.localization,
      page: () => const LocalizationManagementView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.infrastructureDashboard,
      page: () => const InfrastructureDashboardView(),
      middlewares: [AuthGuard()],
    ),
    // ── Event sub-types ──────────────────────────────────────────
    GetPage(
      name: AppRoutes.tournaments,
      page: () => const EventManagementView(initialType: 'TOURNAMENT'),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.championships,
      page: () => const EventManagementView(initialType: 'CHAMPIONSHIP'),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.treasureHunts,
      page: () => const EventManagementView(initialType: 'TREASURE_HUNT'),
      middlewares: [AuthGuard()],
    ),
    // ── Security sub-routes ──────────────────────────────────────
    GetPage(
      name: AppRoutes.securityLiveThreats,
      page: () => const SecurityDashboardView(initialTab: 0),
      binding: SecurityBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.securityFraudAlerts,
      page: () => const SecurityDashboardView(initialTab: 1),
      binding: SecurityBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.securityBannedDevices,
      page: () => const SecurityDashboardView(initialTab: 2),
      binding: SecurityBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.securityBlockedIps,
      page: () => const SecurityDashboardView(initialTab: 2),
      binding: SecurityBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.securityAuditLogs,
      page: () => const SecurityDashboardView(initialTab: 3),
      binding: SecurityBinding(),
      middlewares: [AuthGuard()],
    ),
    // ── Infrastructure sub-routes ────────────────────────────────
    GetPage(
      name: AppRoutes.infrastructureMonitoring,
      page: () => const InfrastructureDashboardView(initialTab: 0),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.infrastructureScaling,
      page: () => const InfrastructureDashboardView(initialTab: 1),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.infrastructureBackup,
      page: () => const InfrastructureDashboardView(initialTab: 2),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.infrastructureErrors,
      page: () => const InfrastructureDashboardView(initialTab: 3),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.infrastructureAlerts,
      page: () => const InfrastructureDashboardView(initialTab: 0),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.infrastructureAuditLogs,
      page: () => const InfrastructureDashboardView(initialTab: 0),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.infrastructureDeployment,
      page: () => const InfrastructureDashboardView(initialTab: 0),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.infrastructureFeatureFlags,
      page: () => const InfrastructureDashboardView(initialTab: 4),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.infrastructureCDN,
      page: () => const InfrastructureDashboardView(initialTab: 0),
      middlewares: [AuthGuard()],
    ),
    // ── User sub-routes ────────────────────────────────────────────
    GetPage(
      name: AppRoutes.usersVerify,
      page: () => const UserManagementView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.usersBanned,
      page: () => const UserManagementView(),
      middlewares: [AuthGuard()],
    ),
    // ── Room sub-routes ────────────────────────────────────────────
    GetPage(
      name: AppRoutes.roomsLive,
      page: () => RoomManagementView(),
      middlewares: [AuthGuard()],
    ),
    // ── Recharge History ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.recharges,
      page: () => const WalletManagementView(),
      middlewares: [AuthGuard()],
    ),
    // ── Treasury sub-routes ────────────────────────────────────────
    GetPage(
      name: AppRoutes.treasuryBurn,
      page: () => const TreasuryVaultView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.treasuryVaultHistory,
      page: () => const TreasuryVaultView(),
      middlewares: [AuthGuard()],
    ),
    // ── Coin Pricing ───────────────────────────────────────────────
    GetPage(
      name: AppRoutes.coinPricing,
      page: () => const CoinPricingView(),
      middlewares: [AuthGuard()],
    ),
    // ── Coin Distribution ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.coinDistribution,
      page: () => const CoinDistributionView(),
      middlewares: [AuthGuard()],
    ),
    // ── Agency Targets ──────────────────────────────────────────────
    GetPage(
      name: AppRoutes.agencyTargets,
      page: () => const AgencyTargetView(),
      middlewares: [AuthGuard()],
    ),
    // ── Streamer Targets ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.targets,
      page: () => const TargetManagerView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.targetsCreate,
      page: () => const TargetManagerView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.targetsExchanges,
      page: () => const TargetManagerView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.targetsAutoCycle,
      page: () => const TargetManagerView(),
      middlewares: [AuthGuard()],
    ),
    // ── Gift Economy Settings ──────────────────────────────────────
    GetPage(
      name: AppRoutes.giftEconomySettings,
      page: () => const GiftEconomySettingsView(),
      middlewares: [AuthGuard()],
    ),
    // ── Diamond Withdrawals ────────────────────────────────────────
    GetPage(
      name: AppRoutes.diamondWithdrawals,
      page: () => const DiamondWithdrawalsView(),
      middlewares: [AuthGuard()],
    ),
    // ── Content Reports ────────────────────────────────────────────
    GetPage(
      name: AppRoutes.contentReports,
      page: () => const ContentReportsView(),
      middlewares: [AuthGuard()],
    ),
    // ── Legal Documents ────────────────────────────────────────────
    GetPage(
      name: AppRoutes.legalDocuments,
      page: () => const LegalDocumentsView(),
      middlewares: [AuthGuard()],
    ),
    // ── Support Tickets ────────────────────────────────────────────
    GetPage(
      name: AppRoutes.supportTickets,
      page: () => const SupportTicketsView(),
      middlewares: [AuthGuard()],
    ),
    // ── Agency sub-routes ──────────────────────────────────────────
    GetPage(
      name: AppRoutes.agencyCommission,
      page: () => AgencyDashboardView(
        agencyId: Get.parameters['agencyId'] ?? '',
        agencyName: Get.parameters['agencyName'] ?? 'Commission',
      ),
      middlewares: [AuthGuard()],
    ),
    // ── Staff sub-routes ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.staffList,
      page: () => const StaffListView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.staffCreate,
      page: () => const StaffListView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.staffRoles,
      page: () => const StaffListView(),
      middlewares: [AuthGuard()],
    ),
    // ── LUXURY / PREMIUM FEATURES ──────────────────────────────
    GetPage(
      name: AppRoutes.subscriptionTiers,
      page: () => const SubscriptionTiersView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.systemSettings,
      page: () => const SystemSettingsView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.musicLibrary,
      page: () => const MusicLibraryView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.roomTopics,
      page: () => const RoomTopicsView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.feedModeration,
      page: () => const FeedModerationView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.revenueDashboard,
      page: () => const RevenueDashboardView(),
      middlewares: [AuthGuard()],
    ),
    // ── Not-found fallback ───────────────────────────────────────
    GetPage(
      name: AppRoutes.NotFound,
      page: () => const DashboardView(),
      middlewares: [AuthGuard()],
    ),
  ];
}
