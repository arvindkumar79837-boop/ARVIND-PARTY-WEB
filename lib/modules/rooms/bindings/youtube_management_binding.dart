import 'package:get/get.dart';
import '../youtube_management_view.dart';

class YouTubeManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<YouTubeManagementController>(() => YouTubeManagementController());
  }
}
