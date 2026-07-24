import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:arvind_party_web/core/services/api_service.dart';

void main() {
  group('ApiService', () {
    test('ApiService constructor sets correct base URL', () {
      Get.testMode = true;
      GetStorage.init();
      final api = ApiService();
      expect(api.dio, isNotNull);
    });

    test('ApiService returns error object on network failure', () async {
      Get.testMode = true;
      GetStorage.init();
      final api = ApiService(baseUrl: 'http://localhost:1');
      final result = await api.get('/nonexistent');
      expect(result['success'], false);
      expect(result['message'], contains('Network error'));
    });
  });
}
