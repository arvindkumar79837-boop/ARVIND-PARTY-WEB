import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controllers/role_auth_controller.dart';
import '../../../core/constants/auth_controller.dart';
import '../../../core/theme/web_theme.dart';

class AdminSidebarWidget extends StatelessWidget {
  final RoleAuthController authController = Get.find<RoleAuthController>();

  AdminSidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        width: 260,
        height: double.infinity,
        color: WebTheme.backgroundLight,
        child: Column(
          children: [
            // शीर्ष ब्रांडिंग / लोगो एरिया
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: WebTheme.borderColor)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ARVIND PARTY",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        authController.currentUserRole.value.name.replaceAll('Web', ' Panel').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // साइडबार मेनू लिस्ट (परमिशन के हिसाब से डायनामिक)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildMenuItem(
                    icon: Icons.dashboard,
                    title: "Dashboard",
                    show: true, // डैशबोर्ड सबको दिखेगा
                    onTap: () => Get.toNamed(AppRoutes.dashboard),
                  ),
                  
                  _buildMenuItem(
                    icon: Icons.monetization_on,
                    title: "Coin Generator",
                    show: authController.hasPermission('COIN_GEN'),
                    onTap: () => Get.toNamed(AppRoutes.treasuryMint),
                  ),

                  _buildMenuItem(
                    icon: Icons.price_check,
                    title: "Coin Pricing",
                    show: authController.permissions.canGenerateCoins.value,
                    onTap: () => Get.toNamed(AppRoutes.coinPricing),
                  ),

                  _buildMenuItem(
                    icon: Icons.swap_horizontal_circle,
                    title: "Coin Transfer",
                    show: authController.hasPermission('COIN_TRANSFER'),
                    onTap: () => Get.toNamed(AppRoutes.treasuryDispatch),
                  ),

                  _buildMenuItem(
                    icon: Icons.send,
                    title: "Coin Distribution",
                    show: authController.hasPermission('COIN_TRANSFER'),
                    onTap: () => Get.toNamed(AppRoutes.coinDistribution),
                  ),

                  _buildMenuItem(
                    icon: Icons.account_balance_wallet,
                    title: "Withdrawal Approvals",
                    show: authController.hasPermission('WITHDRAW_APPROVAL'),
                    onTap: () => Get.toNamed(AppRoutes.withdrawals),
                  ),

                  _buildMenuItem(
                    icon: Icons.people,
                    title: "Staff Invitation",
                    show: authController.hasPermission('STAFF_MGT'),
                    onTap: () => Get.toNamed(AppRoutes.staff),
                  ),

                  _buildMenuItem(
                    icon: Icons.view_carousel,
                    title: "Banner Management",
                    show: authController.hasPermission('BANNER'),
                    onTap: () => Get.toNamed(AppRoutes.events),
                  ),

                  _buildMenuItem(
                    icon: Icons.card_giftcard,
                    title: "Frames & Entry Effects",
                    show: authController.hasPermission('GIVE_FRAME'),
                    onTap: () => Get.toNamed(AppRoutes.gifts),
                  ),

                  _buildMenuItem(
                    icon: Icons.business,
                    title: "Agency Center",
                    show: authController.hasPermission('AGENCY'),
                    onTap: () => Get.toNamed(AppRoutes.agency),
                  ),

                  _buildMenuItem(
                    icon: Icons.flag,
                    title: "Agency Targets",
                    show: authController.hasPermission('AGENCY'),
                    onTap: () => Get.toNamed(AppRoutes.agencyTargets),
                  ),

                  _buildMenuItem(
                    icon: Icons.games,
                    title: "Game Center",
                    show: authController.hasPermission('ADD_GAME'),
                    onTap: () => Get.toNamed(AppRoutes.gameCenter),
                  ),

                  _buildMenuItem(
                    icon: Icons.block,
                    title: "Ban Management",
                    show: authController.hasPermission('BAN_USER'),
                    onTap: () => Get.toNamed(AppRoutes.users),
                  ),

                  _buildMenuItem(
                    icon: Icons.security,
                    title: "Security Dashboard",
                    show: authController.hasPermission('SECURITY_DASHBOARD'),
                    onTap: () => Get.toNamed(AppRoutes.securityDashboard),
                  ),

                  _buildMenuItem(
                    icon: Icons.history_edu,
                    title: "Audit Logs",
                    show: authController.hasPermission('AUDIT_LOGS'),
                    onTap: () => Get.toNamed(AppRoutes.securityAuditLogs),
                  ),

                  const Divider(color: WebTheme.borderColor),

                  _buildMenuItem(
                    icon: Icons.savings,
                    title: "Gift Economy",
                    show: authController.isOwner,
                    onTap: () => Get.toNamed(AppRoutes.giftEconomySettings),
                  ),

                  _buildMenuItem(
                    icon: Icons.diamond,
                    title: "Diamond Withdrawals",
                    show: true,
                    onTap: () => Get.toNamed(AppRoutes.diamondWithdrawals),
                  ),

                  _buildMenuItem(
                    icon: Icons.report,
                    title: "Content Reports",
                    show: authController.hasPermission('SECURITY_DASHBOARD') || authController.isOwner,
                    onTap: () => Get.toNamed(AppRoutes.contentReports),
                  ),

                  _buildMenuItem(
                    icon: Icons.gavel,
                    title: "Legal Documents",
                    show: authController.isOwner,
                    onTap: () => Get.toNamed(AppRoutes.legalDocuments),
                  ),

                  _buildMenuItem(
                    icon: Icons.support_agent,
                    title: "Support Tickets",
                    show: authController.hasPermission('SECURITY_DASHBOARD') || authController.isOwner,
                    onTap: () => Get.toNamed(AppRoutes.supportTickets),
                  ),

                  const Divider(color: WebTheme.borderColor),

                  // ─── LUXURY / PREMIUM FEATURES ──────────────────────
                  _buildMenuItem(
                    icon: Icons.star,
                    title: "Subscription Tiers",
                    show: authController.isOwner,
                    onTap: () => Get.toNamed(AppRoutes.subscriptionTiers),
                  ),

                  _buildMenuItem(
                    icon: Icons.settings,
                    title: "System Settings",
                    show: authController.isOwner,
                    onTap: () => Get.toNamed(AppRoutes.systemSettings),
                  ),

                  _buildMenuItem(
                    icon: Icons.library_music,
                    title: "Music Library",
                    show: authController.isOwner,
                    onTap: () => Get.toNamed(AppRoutes.musicLibrary),
                  ),

                  _buildMenuItem(
                    icon: Icons.topic,
                    title: "Room Topics",
                    show: authController.isOwner,
                    onTap: () => Get.toNamed(AppRoutes.roomTopics),
                  ),

                  _buildMenuItem(
                    icon: Icons.feed,
                    title: "Feed Moderation",
                    show: authController.hasPermission('SECURITY_DASHBOARD') || authController.isOwner,
                    onTap: () => Get.toNamed(AppRoutes.feedModeration),
                  ),

                  _buildMenuItem(
                    icon: Icons.analytics,
                    title: "Revenue Dashboard",
                    show: authController.isOwner,
                    onTap: () => Get.toNamed(AppRoutes.revenueDashboard),
                  ),

                  const Divider(color: WebTheme.borderColor),

                  _buildMenuItem(
                    icon: Icons.person,
                    title: "My Profile",
                    show: true,
                    onTap: () => Get.toNamed('/my-profile'),
                  ),

                  _buildMenuItem(
                    icon: Icons.lock,
                    title: "Password Settings",
                    show: !authController.permissions.isPasswordLocked.value,
                    onTap: () => Get.toNamed('/settings'),
                  ),
                ],
              ),
            ),

            // नीचे लॉगआउट और यूज़र प्रोफाइल कार्ड
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: WebTheme.borderColor)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      authController.userName.value.isEmpty ? "Admin User" : authController.userName.value,
                      style: const TextStyle(color: Colors.white, fontSize: 14, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: () {
                      AuthController.to.logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// साइडबार आइटम बनाने का हेल्पर विजेट
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool show,
    required VoidCallback onTap,
  }) {
    if (!show) return const SizedBox.shrink(); // अगर परमिशन नहीं है, तो हवा में गायब कर दो

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFA0A0C0)),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
        hoverColor: Colors.orange.withValues(alpha: 0.1),
      ),
    );
  }
}