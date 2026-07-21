import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:arvind_party_web/core/constants/auth_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return '/tmp/test_storage';
    });
  });

  setUp(() async {
    Get.testMode = true;
  });

  tearDown(() async {
    Get.reset();
    try {
      await GetStorage.init();
      final storage = GetStorage();
      await storage.erase();
    } catch (_) {}
  });

  group('AuthController', () {
    group('initial state', () {
      test('should not be logged in initially', () {
        final controller = AuthController();
        Get.put(controller);
        expect(controller.isLoggedIn.value, false);
      });

      test('should not be loading initially', () {
        final controller = AuthController();
        Get.put(controller);
        expect(controller.isLoading.value, false);
      });

      test('should have empty error message', () {
        final controller = AuthController();
        Get.put(controller);
        expect(controller.errorMessage.value, '');
      });

      test('should have empty username', () {
        final controller = AuthController();
        Get.put(controller);
        expect(controller.username.value, '');
      });

      test('should have empty role', () {
        final controller = AuthController();
        Get.put(controller);
        expect(controller.role.value, '');
      });

      test('should not be owner initially', () {
        final controller = AuthController();
        Get.put(controller);
        expect(controller.isOwner.value, false);
      });
    });

    group('session restoration', () {
      test('should restore session from stored token', () async {
        await GetStorage.init();
        final storage = GetStorage();
        await storage.write('admin_token', 'existing_token');
        await storage.write('admin_username', 'stored_user');
        await storage.write('admin_role', 'moderator');

        final restoredController = AuthController();
        Get.put(restoredController);
        restoredController.onInit();

        expect(restoredController.isLoggedIn.value, true);
        expect(restoredController.username.value, 'stored_user');
        expect(restoredController.role.value, 'moderator');
      });

      test('should not restore session without token', () async {
        await GetStorage.init();
        final storage = GetStorage();
        await storage.erase();

        final ctrl = AuthController();
        Get.put(ctrl);
        ctrl.onInit();
        expect(ctrl.isLoggedIn.value, false);
        expect(ctrl.username.value, '');
      });
    });

    group('reactive state', () {
      test('isLoggedIn should be reactive', () {
        final controller = AuthController();
        Get.put(controller);
        var observedValue = false;
        ever(controller.isLoggedIn, (val) => observedValue = val);
        controller.isLoggedIn.value = true;
        expect(observedValue, true);
      });

      test('isLoading should be reactive', () {
        final controller = AuthController();
        Get.put(controller);
        var observedValue = false;
        ever(controller.isLoading, (val) => observedValue = val);
        controller.isLoading.value = true;
        expect(observedValue, true);
      });
    });
  });
}
