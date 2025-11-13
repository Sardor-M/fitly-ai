import 'package:get/get.dart';

import '../controllers/analysis_controller.dart';
import '../controllers/app_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/camera_controller.dart';
import '../controllers/outfit_controller.dart';
import '../services/ai_service.dart';
import '../services/api_service.dart';
import '../services/clothing_service.dart';
import '../utils/color_analyzer.dart';

/** 
  Registers global dependencies for the application lifecycle.
*/
class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put(AuthController(Get.find<ApiService>()), permanent: true);
    Get.put(AppController(), permanent: true);
    Get.put(AppCameraController());
    Get.lazyPut(
      () => AnalysisController(AIService(const ColorAnalyzer())),
      fenix: true,
    );
    Get.lazyPut(() => OutfitController(const ClothingService()));
  }
}

