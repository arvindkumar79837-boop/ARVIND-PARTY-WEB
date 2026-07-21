// ═══════════════════════════════════════════════════════════════════════════
// BINDING: SecurityBinding — Injects SecurityApiService + SecurityController
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import './security_api_service.dart';
import './security_controller.dart';

class SecurityBinding implements Bindings {
  @override
  void dependencies() {
    // Reuse the existing ApiService from the app root
    final api = Get.find<ApiService>();
    Get.put(SecurityApiService(api));
    Get.put(SecurityController(), permanent: true);
  }
}