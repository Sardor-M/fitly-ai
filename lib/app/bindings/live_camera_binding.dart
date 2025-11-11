import 'package:get/get.dart';

import '../../controllers/camera_controller.dart';

class LiveCameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppCameraController());
  }
}
