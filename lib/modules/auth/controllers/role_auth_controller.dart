import 'package:get/get.dart';
import '../models/role_permission_model.dart';

class RoleAuthController extends GetxController {
  // करंट लॉगिन यूज़र का डेटा — PRODUCTION: default to unprivileged; real role set via loginUser()
  var currentUserRole = RoleType.user.obs;
  var userUid = "".obs;
  var userName = "".obs;

  // Feature flag constants — replace magic strings throughout the codebase
  static const String featureCoinGen = 'COIN_GEN';
  static const String featureCoinTransfer = 'COIN_TRANSFER';
  static const String featureWithdrawApproval = 'WITHDRAW_APPROVAL';
  static const String featureStaffMgt = 'STAFF_MGT';
  static const String featureBanner = 'BANNER';
  static const String featureGiveFrame = 'GIVE_FRAME';
  static const String featureAgency = 'AGENCY';
  static const String featureAddGame = 'ADD_GAME';
  static const String featureBanUser = 'BAN_USER';
  static const String featureSecurityDashboard = 'SECURITY_DASHBOARD';
  static const String featureAuditLogs = 'AUDIT_LOGS';

  // Convenience getter for owner check (used by admin_sidebar_widget and others)
  bool get isOwner => currentUserRole.value == RoleType.ownerWeb;

  // Live permission observer — safe default: no permissions granted
  UserPermissions permissions = UserPermissions();

  @override
  void onInit() {
    super.onInit();
    // Initialize default permissions
    _setupInitialPermissions();
  }

  /// Function to load role and permissions from the backend upon login
  void loginUser(RoleType role, String uid, String name, Map<String, dynamic> permissionJson, {bool is2faVerified = false}) {
    currentUserRole.value = role;
    userUid.value = uid;
    userName.value = name;
    
    // JSON डेटा को परमिशन मॉडल में पार्स करना
    permissions = UserPermissions.fromJson(permissionJson);
    
    // If the role is owner, automatically grant god-mode (all permissions)
    if (currentUserRole.value == RoleType.ownerWeb) {
      _setGodMode();
    }

    // For high-privilege roles, lock permissions until 2FA is complete
    if ([RoleType.ownerWeb, RoleType.superAdminUid, RoleType.globalManagerWeb].contains(role) && !is2faVerified) {
      permissions.is2faLocked.value = true;
    }
    
    update();
  }

  /// Secret logic to enable all powers for the owner at once
  void _setGodMode() {
    permissions = UserPermissions.godMode();
  }

  /// Default blueprint setup
  void _setupInitialPermissions() {
    permissions = UserPermissions(
      generateCoins: currentUserRole.value == RoleType.ownerWeb,
      transferCoins: currentUserRole.value == RoleType.ownerWeb || currentUserRole.value == RoleType.superCoinSellerUid,
      approveWithdrawals: currentUserRole.value == RoleType.ownerWeb || currentUserRole.value == RoleType.officialWeb,
      manageStaff: currentUserRole.value == RoleType.ownerWeb,
      changeBanners: false,
      giveFrames: false,
      manageAgencies: false,
      addMiniGames: currentUserRole.value == RoleType.ownerWeb,
      banUsers: false,
      viewSecurityDashboard: currentUserRole.value == RoleType.ownerWeb,
      viewAuditLogs: currentUserRole.value == RoleType.ownerWeb,
      passwordLocked: currentUserRole.value != RoleType.ownerWeb, // ओनर को छोड़कर सबका पासवर्ड लॉक
      is2faLocked: false,
    );
  }

  /// Security check before changing password
  bool attemptPasswordChange() {
    if (permissions.isPasswordLocked.value) {
      if (!Get.testMode) {
        Get.snackbar(
          "Action Denied",
          "Security Alert: Your role does not allow password modification. Contact Owner.",
          snackPosition: SnackPosition.BOTTOM,
          maxWidth: 400,
        );
      }
      return false; // Password change not allowed
    }
    return true; // Is owner, permission granted
  }

  /// Permission check tool to hide/show sidebar or any UI button
  bool hasPermission(String feature) {
    if (permissions.is2faLocked.value) return false; // Block all features if 2FA is pending
    if (currentUserRole.value == RoleType.ownerWeb) return true; // ओनर सब देख सकता है

    switch (feature) {
      case featureCoinGen: return permissions.canGenerateCoins.value;
      case featureCoinTransfer: return permissions.canTransferCoins.value;
      case featureWithdrawApproval: return permissions.canApproveWithdrawals.value;
      case featureStaffMgt: return permissions.canManageStaff.value;
      case featureBanner: return permissions.canChangeBanners.value;
      case featureGiveFrame: return permissions.canGiveFramesAndEffects.value;
      case featureAgency: return permissions.canManageAgencies.value;
      case featureAddGame: return permissions.canAddMiniGames.value;
      case featureBanUser: return permissions.canBanUsers.value;
      case featureSecurityDashboard: return permissions.canViewSecurityDashboard.value;
      case featureAuditLogs: return permissions.canViewAuditLogs.value;
      default: return false;
    }
  }

  /// Reset role and permissions on logout
  void logout() {
    currentUserRole.value = RoleType.user;
    userUid.value = '';
    userName.value = '';
    _setupInitialPermissions();
    update();
  }
}