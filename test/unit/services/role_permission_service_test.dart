import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:arvind_party_web/core/services/role_permission_service.dart';

void main() {
  late RolePermissionService service;

  setUp(() {
    Get.testMode = true;
    service = RolePermissionService();
    Get.put(service);
  });

  tearDown(() {
    Get.reset();
  });

  group('RolePermissionService', () {
    group('initial state', () {
      test('should have default role as assistant', () {
        expect(service.currentRole.value, 'assistant');
      });

      test('should not be authenticated initially', () {
        expect(service.isAuthenticated.value, false);
      });

      test('should not be owner initially', () {
        expect(service.isOwner.value, false);
      });

      test('should have empty permissions', () {
        expect(service.permissions.isEmpty, true);
      });
    });

    group('hasPermission', () {
      test('should return true for owner regardless of permissions', () {
        service.isOwner.value = true;
        expect(service.hasPermission('any.permission'), true);
      });

      test('should return true if permission exists', () {
        service.permissions.add('dashboard.view');
        expect(service.hasPermission('dashboard.view'), true);
      });

      test('should return false if permission does not exist', () {
        expect(service.hasPermission('nonexistent.permission'), false);
      });

      test('should return false for empty permissions', () {
        expect(service.hasPermission('dashboard.view'), false);
      });
    });

    group('hasAnyPermission', () {
      test('should return true for owner', () {
        service.isOwner.value = true;
        expect(service.hasAnyPermission(['a', 'b']), true);
      });

      test('should return true if any permission matches', () {
        service.permissions.addAll(['users.view', 'rooms.view']);
        expect(service.hasAnyPermission(['rooms.view', 'gifts.view']), true);
      });

      test('should return false if no permission matches', () {
        service.permissions.addAll(['users.view', 'rooms.view']);
        expect(service.hasAnyPermission(['gifts.view', 'wallet.view']), false);
      });
    });

    group('hasAllPermissions', () {
      test('should return true for owner', () {
        service.isOwner.value = true;
        expect(service.hasAllPermissions(['a', 'b', 'c']), true);
      });

      test('should return true if all permissions exist', () {
        service.permissions.addAll(['a', 'b', 'c']);
        expect(service.hasAllPermissions(['a', 'b', 'c']), true);
      });

      test('should return false if any permission is missing', () {
        service.permissions.addAll(['a', 'b']);
        expect(service.hasAllPermissions(['a', 'b', 'c']), false);
      });
    });

    group('visibleSections', () {
      test('should return all sections for owner', () {
        service.isOwner.value = true;
        final visible = service.visibleSections;
        expect(visible.length, RolePermissionService.sidebarSections.length);
      });

      test('should return matching sections for permission', () {
        service.permissions.add('dashboard.view');
        final visible = service.visibleSections;
        expect(visible.any((s) => s.permissionRequired == 'dashboard.view'), true);
      });

      test('should not return sections without matching permissions', () {
        service.permissions.add('dashboard.view');
        final visible = service.visibleSections;
        expect(visible.any((s) => s.permissionRequired == 'users.view'), false);
      });

      test('should return section if any child permission matches', () {
        service.permissions.add('users.verify');
        final visible = service.visibleSections;
        final userMgmt = visible.firstWhere((s) => s.title == 'User Management');
        expect(userMgmt.children, isNotNull);
        expect(userMgmt.children!.any((c) => c.permissionRequired == 'users.verify'), true);
      });
    });

    group('currentRoleLabel', () {
      test('should return correct label for owner', () {
        service.currentRole.value = 'owner';
        expect(service.currentRoleLabel, 'Owner');
      });

      test('should return correct label for super_admin', () {
        service.currentRole.value = 'super_admin';
        expect(service.currentRoleLabel, 'Super Admin');
      });

      test('should return correct label for assistant', () {
        service.currentRole.value = 'assistant';
        expect(service.currentRoleLabel, 'Assistant');
      });

      test('should return raw value for unknown role', () {
        service.currentRole.value = 'custom_role';
        expect(service.currentRoleLabel, 'custom_role');
      });
    });

    group('initFromStaff', () {
      test('should set all properties from staff data', () {
        service.initFromStaff({
          'role': 'super_admin',
          'roleLevel': 5,
          'permissions': ['dashboard.view', 'users.view', 'wallet.view'],
          '_id': 'staff123',
          'uid': 'uid456',
          'name': 'Test Admin',
        });

        expect(service.currentRole.value, 'super_admin');
        expect(service.currentRoleLevel.value, 5);
        expect(service.isAuthenticated.value, true);
        expect(service.isOwner.value, false);
        expect(service.staffId.value, 'staff123');
        expect(service.staffUid.value, 'uid456');
        expect(service.staffName.value, 'Test Admin');
        expect(service.permissions.length, 3);
      });

      test('should set isOwner for owner role', () {
        service.initFromStaff({
          'role': 'owner',
          'roleLevel': 10,
          'permissions': [],
          '_id': 'owner123',
          'uid': 'owner456',
          'name': 'Platform Owner',
        });

        expect(service.isOwner.value, true);
      });

      test('should handle missing fields gracefully', () {
        service.initFromStaff({});

        expect(service.currentRole.value, 'assistant');
        expect(service.currentRoleLevel.value, 0);
        expect(service.permissions.isEmpty, true);
        expect(service.staffId.value, '');
        expect(service.staffUid.value, '');
        expect(service.staffName.value, '');
      });
    });

    group('logout', () {
      test('should reset all state', () {
        service.initFromStaff({
          'role': 'admin',
          'roleLevel': 3,
          'permissions': ['dashboard.view', 'users.view'],
          '_id': 'staff1',
          'uid': 'uid1',
          'name': 'Admin User',
        });

        service.logout();

        expect(service.currentRole.value, 'assistant');
        expect(service.currentRoleLevel.value, 0);
        expect(service.permissions.isEmpty, true);
        expect(service.isAuthenticated.value, false);
        expect(service.isOwner.value, false);
        expect(service.staffId.value, '');
        expect(service.staffUid.value, '');
        expect(service.staffName.value, '');
      });
    });
  });

  group('SidebarSection', () {
    test('should create with required fields', () {
      final section = SidebarSection(
        title: 'Dashboard',
        icon: 'dashboard',
        route: '/admin/dashboard',
        permissionRequired: 'dashboard.view',
      );

      expect(section.title, 'Dashboard');
      expect(section.icon, 'dashboard');
      expect(section.route, '/admin/dashboard');
      expect(section.permissionRequired, 'dashboard.view');
      expect(section.children, isNull);
    });

    test('should create with children', () {
      final section = SidebarSection(
        title: 'Users',
        icon: 'people',
        route: '/admin/users',
        permissionRequired: 'users.view',
        children: [
          SidebarItem('All Users', '/admin/users', 'users.view'),
        ],
      );

      expect(section.children, isNotNull);
      expect(section.children!.length, 1);
      expect(section.children!.first.title, 'All Users');
    });
  });

  group('SidebarItem', () {
    test('should create with required fields', () {
      final item = SidebarItem('All Users', '/admin/users', 'users.view');

      expect(item.title, 'All Users');
      expect(item.route, '/admin/users');
      expect(item.permissionRequired, 'users.view');
    });
  });
}
