// ═══════════════════════════════════════════════════════════════════════════
// SERVICE: RolePermissionService — 15+ role matrix dynamic sidebar visibility
// Controls nav visibility based on live role privileges from the backend
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

class RolePermissionService extends GetxService {
  final RxString currentRole = 'assistant'.obs;
  final RxInt currentRoleLevel = 0.obs;
  final RxList<String> permissions = <String>[].obs;
  final RxBool isAuthenticated = false.obs;
  final RxBool isOwner = false.obs;
  final RxString staffId = ''.obs;
  final RxString staffUid = ''.obs;
  final RxString staffName = ''.obs;

  // ─── SIDEBAR SECTION DEFINITIONS ──────────────────────────────────
  // Each section has a permission key that gates visibility
  static final List<SidebarSection> sidebarSections = [
    SidebarSection(
      title: 'Dashboard',
      icon: 'dashboard',
      route: '/dashboard',
      permissionRequired: 'dashboard.view',
    ),
    SidebarSection(
      title: 'User Management',
      icon: 'people',
      route: '/users',
      permissionRequired: 'users.view',
      children: [
        SidebarItem('All Users', '/users', 'users.view'),
        SidebarItem('Verify Users', '/users/verify', 'users.verify'),
        SidebarItem('Banned Users', '/users/banned', 'users.ban'),
      ],
    ),
    SidebarSection(
      title: 'Room Management',
      icon: 'meeting_room',
      route: '/rooms',
      permissionRequired: 'rooms.view',
      children: [
        SidebarItem('Live Rooms', '/rooms/live', 'rooms.view'),
        SidebarItem('All Rooms', '/rooms', 'rooms.view'),
      ],
    ),
    SidebarSection(
      title: 'Wallet & Finance',
      icon: 'account_balance_wallet',
      route: '/wallet-management',
      permissionRequired: 'wallet.view',
      children: [
        SidebarItem('Wallet Overview', '/wallet-management', 'wallet.view'),
        SidebarItem('Withdrawals', '/withdrawals', 'wallet.withdrawal_approve'),
        SidebarItem('Recharge History', '/recharges', 'wallet.view'),
      ],
    ),
    SidebarSection(
      title: 'Gift Management',
      icon: 'card_giftcard',
      route: '/gifts',
      permissionRequired: 'gifts.view',
    ),
    SidebarSection(
      title: 'Coin Vault',
      icon: 'monetization_on',
      route: '/treasury',
      permissionRequired: 'treasury.view',
      children: [
        SidebarItem('Vault Overview', '/treasury', 'treasury.view'),
        SidebarItem('Mint Coins', '/treasury/mint', 'treasury.mint'),
        SidebarItem('Dispatch Coins', '/treasury/dispatch', 'treasury.dispatch'),
        SidebarItem('Burn Coins', '/treasury/burn', 'treasury.burn'),
        SidebarItem('Vault History', '/treasury/vault-history', 'treasury.view'),
      ],
    ),
    SidebarSection(
      title: 'Reward Injector',
      icon: 'auto_awesome',
      route: '/rewards',
      permissionRequired: 'rewards.inject',
    ),
    SidebarSection(
      title: 'Streamer Targets',
      icon: 'track_changes',
      route: '/targets',
      permissionRequired: 'targets.view',
      children: [
        SidebarItem('All Targets', '/targets', 'targets.view'),
        SidebarItem('Create Target', '/targets/create', 'targets.create'),
        SidebarItem('Pending Exchanges', '/targets/exchanges', 'targets.approve_exchange'),
        SidebarItem('Auto Cycle', '/targets/auto-cycle', 'targets.auto_cycle'),
      ],
    ),
    SidebarSection(
      title: 'Agency Management',
      icon: 'business',
      route: '/agency',
      permissionRequired: 'agency.view',
      children: [
        SidebarItem('All Agencies', '/agency', 'agency.view'),
        SidebarItem('Commission Tiers', '/agency/commission', 'commission.view'),
      ],
    ),
    SidebarSection(
      title: 'Family Management',
      icon: 'group',
      route: '/families',
      permissionRequired: 'family.view',
    ),
    SidebarSection(
      title: 'Events',
      icon: 'event',
      route: '/events',
      permissionRequired: 'events.view',
      children: [
        SidebarItem('Event Manager', '/events', 'events.view'),
        SidebarItem('Lucky Draws', '/events/lucky-draws', 'events.lucky_draw'),
        SidebarItem('Daily Tasks', '/events/daily-tasks', 'events.daily_tasks'),
        SidebarItem('Invite/Referrals', '/events/invites', 'events.invites'),
        SidebarItem('Login Streaks', '/events/login-streaks', 'events.login_streaks'),
        SidebarItem('Tournaments', '/tournaments', 'events.tournaments'),
        SidebarItem('Championships', '/championships', 'events.championships'),
        SidebarItem('Treasure Hunts', '/treasure-hunts', 'events.treasure_hunts'),
      ],
    ),
    SidebarSection(
      title: 'PK Battle Management',
      icon: 'sports_kabaddi',
      route: '/pk-battle-management',
      permissionRequired: 'pk.view',
    ),
    SidebarSection(
      title: 'VIP Management',
      icon: 'stars',
      route: '/vip-admin',
      permissionRequired: 'vip.view',
    ),
    SidebarSection(
      title: 'Support Tickets',
      icon: 'support_agent',
      route: '/support-tickets',
      permissionRequired: 'support.view',
    ),
    SidebarSection(
      title: 'Reports & Moderation',
      icon: 'flag',
      route: '/reports',
      permissionRequired: 'reports.view',
    ),
    SidebarSection(
      title: 'Notifications',
      icon: 'notifications',
      route: '/broadcasts',
      permissionRequired: 'notifications.send',
    ),
    SidebarSection(
      title: 'Staff Management',
      icon: 'admin_panel_settings',
      route: '/staff',
      permissionRequired: 'staff.view',
      children: [
        SidebarItem('Staff List', '/staff/list', 'staff.view'),
        SidebarItem('Create Staff', '/staff/create', 'staff.create'),
        SidebarItem('Role Hierarchy', '/staff/roles', 'staff.view'),
      ],
    ),
    SidebarSection(
      title: 'Settings',
      icon: 'settings',
      route: '/settings',
      permissionRequired: 'settings.view',
    ),
    SidebarSection(
      title: 'Audit Logs',
      icon: 'history',
      route: '/security/audit-logs',
      permissionRequired: 'audit.view',
    ),
    SidebarSection(
      title: 'Announcements',
      icon: 'campaign',
      route: '/announcements',
      permissionRequired: 'announcements.send',
    ),
    SidebarSection(
      title: 'Leaderboard',
      icon: 'leaderboard',
      route: '/analytics-dashboard',
      permissionRequired: 'leaderboard.view',
    ),
    SidebarSection(
      title: 'Coin Orders',
      icon: 'receipt_long',
      route: '/coin-orders',
      permissionRequired: 'coin_orders.view',
    ),
    SidebarSection(
      title: 'Security',
      icon: 'security',
      route: '/security',
      permissionRequired: 'security.view',
    ),
  ];

  /// Returns only the sidebar sections this role can see
  List<SidebarSection> get visibleSections {
    return sidebarSections.where((section) {
      if (isOwner.value) return true;
      if (permissions.contains(section.permissionRequired)) return true;
      if (section.children != null) {
        return section.children!.any((child) => permissions.contains(child.permissionRequired));
      }
      return false;
    }).toList();
  }

  /// Check if the current route requires a permission the user lacks
  bool hasPermissionForRoute(String route) {
    if (isOwner.value) return false;
    for (final section in sidebarSections) {
      if (route == section.route) {
        if (!hasPermission(section.permissionRequired)) return true;
        return false;
      }
      if (section.children != null) {
        for (final child in section.children!) {
          if (route == child.route && !hasPermission(child.permissionRequired)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Check if user has a specific permission
  bool hasPermission(String permission) {
    if (isOwner.value) return true;
    return permissions.contains(permission);
  }

  /// Check if user has any of the given permissions
  bool hasAnyPermission(List<String> permissionList) {
    if (isOwner.value) return true;
    return permissionList.any((p) => permissions.contains(p));
  }

  /// Check if user has all of the given permissions
  bool hasAllPermissions(List<String> permissionList) {
    if (isOwner.value) return true;
    return permissionList.every((p) => permissions.contains(p));
  }

  /// Get the label for the current role
  String get currentRoleLabel {
    const labels = {
      'owner': 'Owner',
      'super_admin': 'Super Admin',
      'admin': 'Admin',
      'global_manager': 'Global Manager',
      'country_manager': 'Country Manager',
      'bd_staff': 'BD Staff',
      'super_coin_seller': 'Super Coin Seller',
      'normal_coin_seller': 'Normal Coin Seller',
      'customer_service_manager': 'CS Manager',
      'customer_service_senior': 'Senior CS',
      'customer_service': 'Customer Service',
      'assistant_manager': 'Assistant Manager',
      'assistant_senior': 'Senior Assistant',
      'assistant': 'Assistant',
      'moderator': 'Moderator',
    };
    return labels[currentRole.value] ?? currentRole.value;
  }

  /// Initialize from staff login response
  void initFromStaff(Map<String, dynamic> staffData) {
    currentRole.value = staffData['role'] ?? 'assistant';
    currentRoleLevel.value = staffData['roleLevel'] ?? 0;
    permissions.value = List<String>.from(staffData['permissions'] ?? []);
    isAuthenticated.value = true;
    isOwner.value = staffData['role'] == 'owner';
    staffId.value = staffData['_id'] ?? '';
    staffUid.value = staffData['uid'] ?? '';
    staffName.value = staffData['name'] ?? staffData['loginId'] ?? '';
  }

  void logout() {
    currentRole.value = 'assistant';
    currentRoleLevel.value = 0;
    permissions.clear();
    isAuthenticated.value = false;
    isOwner.value = false;
    staffId.value = '';
    staffUid.value = '';
    staffName.value = '';
  }
}

class SidebarSection {
  final String title;
  final String icon;
  final String route;
  final String permissionRequired;
  final List<SidebarItem>? children;

  SidebarSection({
    required this.title,
    required this.icon,
    required this.route,
    required this.permissionRequired,
    this.children,
  });
}

class SidebarItem {
  final String title;
  final String route;
  final String permissionRequired;

  SidebarItem(this.title, this.route, this.permissionRequired);
}