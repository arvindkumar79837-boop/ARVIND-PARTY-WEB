import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/auth_controller.dart';
import '../../core/services/role_permission_service.dart';
import '../../core/theme/web_theme.dart';
import '../../routes/app_routes.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  final String title;

  const AdminShell({
    super.key,
    required this.child,
    this.title = 'Arvind Party Admin',
  });

  @override
  Widget build(BuildContext context) {
    final permService = Get.find<RolePermissionService>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            color: WebTheme.backgroundLight,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: WebTheme.borderColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings, color: WebTheme.primaryOrange, size: 28),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Arvind Party',
                          style: TextStyle(
                            color: WebTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Staff info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: WebTheme.borderColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: WebTheme.primaryOrange,
                        child: Text(
                          (authController.staffName.value.isNotEmpty
                              ? authController.staffName.value[0]
                              : 'A'),
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => Text(
                              authController.staffName.value,
                              style: const TextStyle(color: WebTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            )),
                            Obx(() => Text(
                              permService.currentRoleLabel,
                              style: const TextStyle(color: WebTheme.textSecondary, fontSize: 11),
                            )),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, size: 18, color: WebTheme.errorRed),
                        onPressed: () => authController.logout(),
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                ),
                // Navigation items (RBAC-driven from permService.visibleSections)
                Expanded(
                  child: Obx(() {
                    final sections = permService.visibleSections;
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: sections.map((section) => _navSectionItem(section)).toList(),
                    );
                  }),
                ),
              ],
            ),
          ),
          // Content area
          Expanded(
            child: Container(
              color: WebTheme.backgroundDark,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFromString(String name) {
    const iconMap = {
      'dashboard': Icons.dashboard,
      'people': Icons.people,
      'meeting_room': Icons.meeting_room,
      'account_balance_wallet': Icons.account_balance_wallet,
      'card_giftcard': Icons.card_giftcard,
      'monetization_on': Icons.monetization_on,
      'auto_awesome': Icons.auto_awesome,
      'track_changes': Icons.track_changes,
      'business': Icons.business,
      'group': Icons.group,
      'event': Icons.event,
      'sports_kabaddi': Icons.sports_kabaddi,
      'stars': Icons.stars,
      'support_agent': Icons.support_agent,
      'flag': Icons.flag,
      'notifications': Icons.notifications,
      'admin_panel_settings': Icons.admin_panel_settings,
      'settings': Icons.settings,
      'history': Icons.history,
      'campaign': Icons.campaign,
      'leaderboard': Icons.leaderboard,
      'receipt_long': Icons.receipt_long,
      'security': Icons.security,
      'dns': Icons.dns,
      'translate': Icons.translate,
      'store': Icons.store,
      'currency_bitcoin': Icons.currency_bitcoin,
      'money_off': Icons.money_off,
      'analytics': Icons.analytics,
    };
    return iconMap[name] ?? Icons.circle;
  }

  Widget _navSectionItem(SidebarSection section) {
    final isParentRoute = Get.currentRoute == section.route ||
        (section.children?.any((c) => Get.currentRoute == c.route) ?? false);

    return Container(
      color: isParentRoute ? WebTheme.primaryOrange.withValues(alpha: 0.1) : null,
      child: ExpansionTile(
        leading: Icon(
          _iconFromString(section.icon),
          size: 20,
          color: isParentRoute ? WebTheme.primaryOrange : WebTheme.textSecondary,
        ),
        title: Text(
          section.title,
          style: TextStyle(
            color: isParentRoute ? WebTheme.primaryOrange : WebTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        initiallyExpanded: isParentRoute,
        children: [
          if (section.children != null && section.children!.isNotEmpty)
            ...section.children!.map((child) => ListTile(
              dense: true,
              title: Text(
                child.title,
                style: TextStyle(
                  color: Get.currentRoute == child.route
                      ? WebTheme.primaryOrange
                      : WebTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              onTap: () => Get.toNamed(child.route),
              selected: Get.currentRoute == child.route,
              selectedTileColor: WebTheme.primaryOrange.withValues(alpha: 0.05),
              contentPadding: const EdgeInsetsDirectional.only(start: 72),
            ))
          else
            ListTile(
              dense: true,
              onTap: () => Get.toNamed(section.route),
              selected: Get.currentRoute == section.route,
              selectedTileColor: WebTheme.primaryOrange.withValues(alpha: 0.05),
            ),
        ],
      ),
    );
  }
}
