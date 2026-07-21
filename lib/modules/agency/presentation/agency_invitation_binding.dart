import 'package:get/get.dart';
import 'agency_invitation_controller.dart';

class AgencyInvitationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgencyInvitationController>(() => AgencyInvitationController());
  }
}