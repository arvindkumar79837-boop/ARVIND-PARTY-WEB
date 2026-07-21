import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import '../services/role_permission_service.dart';
import '../constants/env_config.dart';
import '../../modules/auth/controllers/role_auth_controller.dart';
import '../../modules/auth/models/role_permission_model.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();
  final _storage = GetStorage();

  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var username = ''.obs;
  var staffId = ''.obs;
  var role = ''.obs;
  var staffName = ''.obs;
  var isOwner = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  void _checkSession() {
    final token = _storage.read('admin_token');
    if (token != null && token.toString().isNotEmpty) {
      isLoggedIn.value = true;
      username.value = _storage.read('admin_username') ?? 'Admin';
      staffId.value = _storage.read('admin_staff_id') ?? '';
      role.value = _storage.read('admin_role') ?? 'admin';
      staffName.value = _storage.read('admin_staff_name') ?? '';
      isOwner.value = _storage.read('admin_is_owner') ?? false;
      _syncPermissionsFromStorage();
    }
  }

  void _syncPermissionsFromStorage() {
    try {
      final permService = Get.find<RolePermissionService>();
      final storedRole = _storage.read('admin_role') ?? 'staff';
      final storedPermissions = _storage.read('admin_permissions');
      final storedIsOwner = _storage.read('admin_is_owner') ?? false;

      if (storedIsOwner) {
        permService.initFromStaff({
          'role': 'owner',
          'roleLevel': 100,
          'permissions': [],
          '_id': _storage.read('admin_staff_id') ?? '',
          'name': _storage.read('admin_staff_name') ?? '',
        });
      } else if (storedPermissions != null) {
        permService.initFromStaff({
          'role': storedRole,
          'permissions': storedPermissions,
          '_id': _storage.read('admin_staff_id') ?? '',
          'name': _storage.read('admin_staff_name') ?? '',
        });
      }

      try {
        final roleAuth = Get.find<RoleAuthController>();
        if (storedIsOwner) {
          roleAuth.loginUser(RoleType.ownerWeb, staffId.value, staffName.value, {}, is2faVerified: true);
        }
      } catch (e) { debugPrint('Error: $e'); }
    } catch (e) { debugPrint('Error: $e'); }
  }

  /// Staff Login — ID + Password
  Future<bool> login(String loginId, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final apiService = Get.find<ApiService>();
      final response = await apiService.post('/staff/login-password', {
        'loginId': loginId.trim(),
        'password': password,
      });

      if (response['success'] == true) {
        final token = response['token'] ?? '';
        final staff = response['staff'] ?? {};
        final staffIsOwner = staff['role'] == 'owner' || staff['isOwner'] == true;

        _saveSession(token, staff, staffIsOwner);
        _syncPermissions(response);
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Login failed';
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Owner Login — Google Sign-In + Firebase Auth
  Future<bool> loginWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final googleSignIn = GoogleSignIn(scopes: ['email']);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        errorMessage.value = 'Google sign-in cancelled';
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await fb.FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        errorMessage.value = 'Failed to get Firebase ID token';
        return false;
      }

      final apiService = Get.find<ApiService>();
      final response = await apiService.post('/auth/admin/verify', {
        'idToken': idToken,
      });

      if (response['success'] == true) {
        final token = response['token'] ?? '';
        final staff = response['staff'] ?? {};
        final staffIsOwner = staff['role'] == 'owner' || staff['isOwner'] == true;

        _saveSession(token, staff, staffIsOwner);
        _syncPermissions(response);
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Not authorized as admin/owner';
        await googleSignIn.signOut();
        await fb.FirebaseAuth.instance.signOut();
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Google login failed: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _saveSession(String token, Map<String, dynamic> staff, bool owner) {
    _storage.write('admin_token', token);
    _storage.write('admin_username', staff['name'] ?? 'Admin');
    _storage.write('admin_staff_id', staff['loginId'] ?? staff['_id'] ?? '');
    _storage.write('admin_staff_name', staff['name'] ?? 'Admin');
    _storage.write('admin_role', staff['role'] ?? 'staff');
    _storage.write('admin_is_owner', owner);

    final perms = staff['permissions'];
    if (perms != null) {
      _storage.write('admin_permissions', perms);
    }

    try {
      Get.find<ApiService>().token = token;
    } catch (e) { debugPrint('Error: $e'); }

    isLoggedIn.value = true;
    username.value = staff['name'] ?? 'Admin';
    staffId.value = staff['loginId'] ?? staff['_id'] ?? '';
    staffName.value = staff['name'] ?? 'Admin';
    role.value = staff['role'] ?? 'staff';
    isOwner.value = owner;
  }

  void _syncPermissions(dynamic response) {
    final staff = response['staff'] ?? {};

    try {
      final permService = Get.find<RolePermissionService>();
      permService.initFromStaff(staff);
    } catch (e) { debugPrint('Error: $e'); }

    try {
      final roleAuth = Get.find<RoleAuthController>();
      if (isOwner.value) {
        roleAuth.loginUser(RoleType.ownerWeb, staffId.value, staffName.value, {}, is2faVerified: true);
      } else {
        final permMap = {
          'generateCoins': staff['permissions']?.contains('treasury.mint') ?? false,
          'transferCoins': staff['permissions']?.contains('treasury.dispatch') ?? false,
          'approveWithdrawals': staff['permissions']?.contains('wallet.withdrawal_approve') ?? false,
          'manageStaff': staff['permissions']?.contains('staff.view') ?? false,
          'changeBanners': staff['permissions']?.contains('announcements.send') ?? false,
          'giveFrames': staff['permissions']?.contains('gifts.view') ?? false,
          'manageAgencies': staff['permissions']?.contains('agency.view') ?? false,
          'addMiniGames': staff['permissions']?.contains('games.view') ?? false,
          'banUsers': staff['permissions']?.contains('users.ban') ?? false,
          'viewSecurityDashboard': staff['permissions']?.contains('security.view') ?? false,
          'viewAuditLogs': staff['permissions']?.contains('audit.view') ?? false,
          'passwordLocked': true,
          'is2faLocked': false,
        };
        roleAuth.loginUser(
          _roleFromString(staff['role'] ?? 'assistant'),
          staff['_id'] ?? '',
          staff['name'] ?? '',
          permMap,
        );
      }
    } catch (e) { debugPrint('Error: $e'); }
  }

  RoleType _roleFromString(String r) {
    switch (r) {
      case 'owner': return RoleType.ownerWeb;
      case 'super_admin': return RoleType.superAdminUid;
      case 'admin': return RoleType.adminUid;
      case 'global_manager': return RoleType.globalManagerWeb;
      case 'country_manager': return RoleType.countryManagerWeb;
      case 'moderator': return RoleType.officialWeb;
      default: return RoleType.user;
    }
  }

  Future<void> logout() async {
    _storage.remove('admin_token');
    _storage.remove('admin_username');
    _storage.remove('admin_staff_id');
    _storage.remove('admin_staff_name');
    _storage.remove('admin_role');
    _storage.remove('admin_is_owner');
    _storage.remove('admin_permissions');

    isLoggedIn.value = false;
    username.value = '';
    staffId.value = '';
    staffName.value = '';
    role.value = '';
    isOwner.value = false;

    try { Get.find<RolePermissionService>().logout(); } catch (e) { debugPrint('Logout cleanup error: $e'); }
    try { Get.find<RoleAuthController>().logout(); } catch (e) { debugPrint('Logout cleanup error: $e'); }
    try { Get.find<ApiService>().token = null; } catch (e) { debugPrint('Logout cleanup error: $e'); }

    try {
      await GoogleSignIn().signOut();
    } catch (e) { debugPrint('Logout cleanup error: $e'); }
    try {
      await fb.FirebaseAuth.instance.signOut();
    } catch (e) { debugPrint('Logout cleanup error: $e'); }

    Get.offAllNamed('/login');
  }
}
