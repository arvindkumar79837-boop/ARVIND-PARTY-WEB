import 'package:flutter_test/flutter_test.dart';
import 'package:arvind_party_web/modules/auth/models/role_permission_model.dart';

void main() {
  group('RoleType enum', () {
    test('should have all 18 role values', () {
      expect(RoleType.values.length, 18);
    });

    test('should include ownerWeb role', () {
      expect(RoleType.values, contains(RoleType.ownerWeb));
    });

    test('should include user role', () {
      expect(RoleType.values, contains(RoleType.user));
    });
  });

  group('UserPermissions', () {
    test('should create with default false values', () {
      final permissions = UserPermissions(
        generateCoins: false,
        transferCoins: false,
        approveWithdrawals: false,
        manageStaff: false,
        changeBanners: false,
        giveFrames: false,
        manageAgencies: false,
        addMiniGames: false,
        banUsers: false,
        viewSecurityDashboard: false,
        viewAuditLogs: false,
        passwordLocked: true,
        is2faLocked: false,
      );

      expect(permissions.canGenerateCoins.value, false);
      expect(permissions.isPasswordLocked.value, true);
      expect(permissions.is2faLocked.value, false);
    });

    test('should create with mixed values', () {
      final permissions = UserPermissions(
        generateCoins: true,
        transferCoins: false,
        approveWithdrawals: true,
        manageStaff: true,
        changeBanners: false,
        giveFrames: false,
        manageAgencies: true,
        addMiniGames: false,
        banUsers: true,
        viewSecurityDashboard: true,
        viewAuditLogs: false,
        passwordLocked: false,
        is2faLocked: false,
      );

      expect(permissions.canGenerateCoins.value, true);
      expect(permissions.canTransferCoins.value, false);
      expect(permissions.canApproveWithdrawals.value, true);
      expect(permissions.canManageStaff.value, true);
      expect(permissions.canBanUsers.value, true);
      expect(permissions.isPasswordLocked.value, false);
    });

    group('godMode factory', () {
      test('should grant all permissions', () {
        final permissions = UserPermissions.godMode();

        expect(permissions.canGenerateCoins.value, true);
        expect(permissions.canTransferCoins.value, true);
        expect(permissions.canApproveWithdrawals.value, true);
        expect(permissions.canManageStaff.value, true);
        expect(permissions.canChangeBanners.value, true);
        expect(permissions.canGiveFramesAndEffects.value, true);
        expect(permissions.canManageAgencies.value, true);
        expect(permissions.canAddMiniGames.value, true);
        expect(permissions.canBanUsers.value, true);
        expect(permissions.canViewSecurityDashboard.value, true);
        expect(permissions.canViewAuditLogs.value, true);
      });

      test('should unlock password and 2FA', () {
        final permissions = UserPermissions.godMode();

        expect(permissions.isPasswordLocked.value, false);
        expect(permissions.is2faLocked.value, false);
      });
    });

    group('fromJson factory', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'generateCoins': true,
          'transferCoins': false,
          'approveWithdrawals': true,
          'manageStaff': true,
          'changeBanners': false,
          'giveFrames': true,
          'manageAgencies': false,
          'addMiniGames': true,
          'banUsers': false,
          'viewSecurityDashboard': true,
          'viewAuditLogs': false,
          'passwordLocked': false,
          'is2faLocked': false,
        };

        final permissions = UserPermissions.fromJson(json);

        expect(permissions.canGenerateCoins.value, true);
        expect(permissions.canTransferCoins.value, false);
        expect(permissions.canApproveWithdrawals.value, true);
        expect(permissions.canGiveFramesAndEffects.value, true);
        expect(permissions.canAddMiniGames.value, true);
        expect(permissions.isPasswordLocked.value, false);
      });

      test('should use defaults for missing keys', () {
        final json = <String, dynamic>{};

        final permissions = UserPermissions.fromJson(json);

        expect(permissions.canGenerateCoins.value, false);
        expect(permissions.isPasswordLocked.value, true);
        expect(permissions.is2faLocked.value, false);
      });

      test('should handle null values gracefully', () {
        final json = {
          'generateCoins': null,
          'passwordLocked': null,
          'is2faLocked': null,
        };

        final permissions = UserPermissions.fromJson(json);

        expect(permissions.canGenerateCoins.value, false);
        expect(permissions.isPasswordLocked.value, true);
        expect(permissions.is2faLocked.value, false);
      });
    });

    group('toJson', () {
      test('should serialize to correct map', () {
        final permissions = UserPermissions.godMode();
        final json = permissions.toJson();

        expect(json['generateCoins'], true);
        expect(json['transferCoins'], true);
        expect(json['approveWithdrawals'], true);
        expect(json['passwordLocked'], false);
        expect(json['is2faLocked'], false);
      });

      test('round-trip should preserve values', () {
        final original = UserPermissions(
          generateCoins: true,
          transferCoins: false,
          approveWithdrawals: true,
          manageStaff: false,
          changeBanners: true,
          giveFrames: false,
          manageAgencies: true,
          addMiniGames: false,
          banUsers: true,
          viewSecurityDashboard: false,
          viewAuditLogs: true,
          passwordLocked: false,
          is2faLocked: true,
        );

        final json = original.toJson();
        final restored = UserPermissions.fromJson(json);

        expect(restored.canGenerateCoins.value, original.canGenerateCoins.value);
        expect(restored.canTransferCoins.value, original.canTransferCoins.value);
        expect(restored.isPasswordLocked.value, original.isPasswordLocked.value);
        expect(restored.is2faLocked.value, original.is2faLocked.value);
      });
    });

    test('permissions should be independently mutable', () {
      final permissions = UserPermissions(
        generateCoins: false,
        transferCoins: false,
        approveWithdrawals: false,
        manageStaff: false,
        changeBanners: false,
        giveFrames: false,
        manageAgencies: false,
        addMiniGames: false,
        banUsers: false,
        viewSecurityDashboard: false,
        viewAuditLogs: false,
        passwordLocked: true,
        is2faLocked: false,
      );

      permissions.canGenerateCoins.value = true;
      expect(permissions.canGenerateCoins.value, true);
      expect(permissions.canTransferCoins.value, false);

      permissions.canTransferCoins.value = true;
      expect(permissions.canTransferCoins.value, true);
    });
  });
}
