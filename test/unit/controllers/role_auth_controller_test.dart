import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:arvind_party_web/modules/auth/controllers/role_auth_controller.dart';
import 'package:arvind_party_web/modules/auth/models/role_permission_model.dart';

void main() {
  late RoleAuthController controller;

  setUp(() {
    Get.testMode = true;
    controller = RoleAuthController();
    Get.put(controller);
  });

  tearDown(() {
    Get.reset();
  });

  group('RoleAuthController', () {
    group('initial state', () {
      test('should have default role as user', () {
        expect(controller.currentUserRole.value, RoleType.user);
      });

      test('should have empty uid initially', () {
        expect(controller.userUid.value, '');
      });

      test('should have empty name initially', () {
        expect(controller.userName.value, '');
      });

      test('should have initialized permissions', () {
        expect(controller.permissions, isNotNull);
      });
    });

    group('loginUser', () {
      test('should set role, uid and name', () {
        controller.loginUser(
          RoleType.adminUid,
          'uid123',
          'Test Admin',
          {},
        );

        expect(controller.currentUserRole.value, RoleType.adminUid);
        expect(controller.userUid.value, 'uid123');
        expect(controller.userName.value, 'Test Admin');
      });

      test('should grant god mode for ownerWeb role', () {
        controller.loginUser(
          RoleType.ownerWeb,
          'owner1',
          'Owner',
          {},
          is2faVerified: true,
        );

        expect(controller.permissions.canGenerateCoins.value, true);
        expect(controller.permissions.canManageStaff.value, true);
        expect(controller.permissions.canViewSecurityDashboard.value, true);
        expect(controller.permissions.isPasswordLocked.value, false);
      });

      test('should lock 2FA for high-privilege roles', () {
        controller.loginUser(
          RoleType.superAdminUid,
          'super1',
          'Super Admin',
          {},
          is2faVerified: false,
        );

        expect(controller.permissions.is2faLocked.value, true);
      });

      test('should not lock 2FA when verified', () {
        controller.loginUser(
          RoleType.superAdminUid,
          'super1',
          'Super Admin',
          {},
          is2faVerified: true,
        );

        expect(controller.permissions.is2faLocked.value, false);
      });

      test('should not lock 2FA for low-privilege roles', () {
        controller.loginUser(
          RoleType.normalCoinSellerUid,
          'seller1',
          'Coin Seller',
          {},
        );

        expect(controller.permissions.is2faLocked.value, false);
      });

      test('should parse permissions from JSON', () {
        controller.loginUser(
          RoleType.adminUid,
          'admin1',
          'Admin',
          {
            'generateCoins': false,
            'transferCoins': true,
            'approveWithdrawals': true,
            'manageStaff': false,
            'changeBanners': true,
            'giveFrames': false,
            'manageAgencies': true,
            'addMiniGames': false,
            'banUsers': true,
            'viewSecurityDashboard': false,
            'viewAuditLogs': true,
            'passwordLocked': true,
            'is2faLocked': false,
          },
        );

        expect(controller.permissions.canGenerateCoins.value, false);
        expect(controller.permissions.canTransferCoins.value, true);
        expect(controller.permissions.canApproveWithdrawals.value, true);
        expect(controller.permissions.canManageStaff.value, false);
        expect(controller.permissions.canChangeBanners.value, true);
        expect(controller.permissions.canManageAgencies.value, true);
        expect(controller.permissions.canBanUsers.value, true);
        expect(controller.permissions.canViewSecurityDashboard.value, false);
        expect(controller.permissions.canViewAuditLogs.value, true);
      });
    });

    group('hasPermission', () {
      test('should return true for owner on any feature', () {
        controller.loginUser(
          RoleType.ownerWeb,
          'o1',
          'Owner',
          {},
          is2faVerified: true,
        );
        expect(controller.hasPermission('COIN_GEN'), true);
        expect(controller.hasPermission('STAFF_MGT'), true);
        expect(controller.hasPermission('NONEXISTENT'), true);
      });

      test('should return false when 2FA is locked', () {
        controller.loginUser(
          RoleType.superAdminUid,
          's1',
          'Super',
          {},
          is2faVerified: false,
        );

        expect(controller.hasPermission('COIN_GEN'), false);
      });

      test('should check specific permissions for non-owner roles', () {
        controller.loginUser(RoleType.adminUid, 'a1', 'Admin', {
          'generateCoins': false,
          'transferCoins': true,
          'approveWithdrawals': false,
          'manageStaff': true,
          'banUsers': false,
          'viewSecurityDashboard': true,
        });

        expect(controller.hasPermission('COIN_GEN'), false);
        expect(controller.hasPermission('COIN_TRANSFER'), true);
        expect(controller.hasPermission('STAFF_MGT'), true);
        expect(controller.hasPermission('SECURITY_DASHBOARD'), true);
        expect(controller.hasPermission('BAN_USER'), false);
      });

      test('should return false for unknown features', () {
        controller.loginUser(RoleType.adminUid, 'a1', 'Admin', {});
        expect(controller.hasPermission('UNKNOWN_FEATURE'), false);
      });
    });

    group('attemptPasswordChange', () {
      test('should allow password change for owner', () {
        controller.loginUser(
          RoleType.ownerWeb,
          'o1',
          'Owner',
          {},
          is2faVerified: true,
        );
        expect(controller.attemptPasswordChange(), true);
      });

      test('should deny password change for locked roles', () {
        controller.loginUser(RoleType.adminUid, 'a1', 'Admin', {
          'passwordLocked': true,
        });
        expect(controller.attemptPasswordChange(), false);
      });

      test('should allow password change when unlocked', () {
        controller.loginUser(RoleType.adminUid, 'a1', 'Admin', {
          'passwordLocked': false,
        });
        expect(controller.attemptPasswordChange(), true);
      });
    });
  });
}
