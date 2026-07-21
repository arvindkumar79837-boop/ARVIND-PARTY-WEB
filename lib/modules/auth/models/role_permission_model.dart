import 'package:get/get.dart';

/// अरविंद पार्टी के सभी 15+ रोल्स का Enum
enum RoleType {
  ownerWeb,
  appAdminWeb,
  globalManagerWeb,
  countryManagerWeb,
  superAdminUid,
  adminUid,
  eventManagerUid,
  bdUid,
  superCoinSellerUid,
  normalCoinSellerUid,
  csCustomerServiceUid,
  csLeaderUid,
  ownerAssistantUid,
  adminAssistantUid,
  globalManagerAssistantUid,
  officialWeb,
  officialAssistantUid,
  user
}

/// हर स्टाफ/रोल की परमिशन लिस्ट का मॉडल
class UserPermissions {
  // कॉइन और फाइनेंस कंट्रोल्स
  final canGenerateCoins = false.obs;
  final canTransferCoins = false.obs;
  final canApproveWithdrawals = false.obs;

  // ऐप कंट्रोल्स
  final canManageStaff = false.obs;
  final canChangeBanners = false.obs;
  final canGiveFramesAndEffects = false.obs;
  final canManageAgencies = false.obs;
  final canAddMiniGames = false.obs; // ओनर/एडमिन के लिए गेम ऐड करने की परमिशन

  // सिक्योरिटी कंट्रोल्स
  final canBanUsers = false.obs;
  final canViewSecurityDashboard = false.obs;
  final canViewAuditLogs = false.obs;
  final isPasswordLocked = true.obs; // स्टाफ के लिए हमेशा true रहेगा

  // 2FA Lock
  final is2faLocked = false.obs;

  UserPermissions({
    bool generateCoins = false,
    bool transferCoins = false,
    bool approveWithdrawals = false,
    bool manageStaff = false,
    bool changeBanners = false,
    bool giveFrames = false,
    bool manageAgencies = false,
    bool addMiniGames = false,
    bool banUsers = false,
    bool viewSecurityDashboard = false,
    bool viewAuditLogs = false,
    bool passwordLocked = true,
    bool is2faLocked = false,
  }) {
    canGenerateCoins.value = generateCoins;
    canTransferCoins.value = transferCoins;
    canApproveWithdrawals.value = approveWithdrawals;
    canManageStaff.value = manageStaff;
    canChangeBanners.value = changeBanners;
    canGiveFramesAndEffects.value = giveFrames;
    canManageAgencies.value = manageAgencies;
    canAddMiniGames.value = addMiniGames;
    canBanUsers.value = banUsers;
    canViewSecurityDashboard.value = viewSecurityDashboard;
    canViewAuditLogs.value = viewAuditLogs;
    isPasswordLocked.value = passwordLocked;
    this.is2faLocked.value = is2faLocked;
  }

  /// Special constructor for Owner's God Mode
  factory UserPermissions.godMode() {
    return UserPermissions(
        generateCoins: true, transferCoins: true, approveWithdrawals: true,
        manageStaff: true, changeBanners: true, giveFrames: true,
        manageAgencies: true, addMiniGames: true, banUsers: true,
        viewSecurityDashboard: true, viewAuditLogs: true,
        passwordLocked: false,
        is2faLocked: false
    );
  }

  /// फैक्ट्री कंस्ट्रक्टर: बैकएंड JSON डेटा को मॉडल में बदलने के लिए
  factory UserPermissions.fromJson(Map<String, dynamic> json) {
    return UserPermissions(
      generateCoins: json['generateCoins'] ?? false,
      transferCoins: json['transferCoins'] ?? false,
      approveWithdrawals: json['approveWithdrawals'] ?? false,
      manageStaff: json['manageStaff'] ?? false,
      changeBanners: json['changeBanners'] ?? false,
      giveFrames: json['giveFrames'] ?? false,
      manageAgencies: json['manageAgencies'] ?? false,
      addMiniGames: json['addMiniGames'] ?? false,
      banUsers: json['banUsers'] ?? false,
      viewSecurityDashboard: json['viewSecurityDashboard'] ?? false,
      viewAuditLogs: json['viewAuditLogs'] ?? false,
      passwordLocked: json['passwordLocked'] ?? true,
      is2faLocked: json['is2faLocked'] ?? false,
    );
  }

  /// मॉडल को वापस JSON में बदलने के लिए (बैकएंड सेव करने हेतु)
  Map<String, dynamic> toJson() => {
        'generateCoins': canGenerateCoins.value,
        'transferCoins': canTransferCoins.value,
        'approveWithdrawals': canApproveWithdrawals.value,
        'manageStaff': canManageStaff.value,
        'changeBanners': canChangeBanners.value,
        'giveFrames': canGiveFramesAndEffects.value,
        'manageAgencies': canManageAgencies.value,
        'addMiniGames': canAddMiniGames.value,
        'banUsers': canBanUsers.value,
        'viewSecurityDashboard': canViewSecurityDashboard.value,
        'viewAuditLogs': canViewAuditLogs.value,
        'passwordLocked': isPasswordLocked.value,
        'is2faLocked': is2faLocked.value,
      };
}