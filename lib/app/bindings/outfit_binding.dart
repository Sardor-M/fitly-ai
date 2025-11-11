import 'package:get/get.dart';

import '../../controllers/outfit_controller.dart';
import '../../services/clothing_service.dart';

class OutfitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutfitController(const ClothingService()));
  }
}

