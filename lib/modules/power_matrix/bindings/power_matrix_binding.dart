import 'package:get/get.dart';
import '../controllers/power_matrix_controller.dart';

class PowerMatrixBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PowerMatrixController>(() => PowerMatrixController());
  }
}
