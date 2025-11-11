import 'package:get/get.dart';

import '../../screens/analysis_screen.dart';
import '../../screens/camera_screen.dart';
import '../../screens/live_camera_screen.dart';
import '../../screens/color_palette_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/outfit_swipe_screen.dart';
import '../../screens/product_detail_screen.dart';
import '../../screens/splash_screen.dart';
import '../bindings/live_camera_binding.dart';
import '../bindings/outfit_binding.dart';
import '../../screens/my_account_screen.dart';
import '../../screens/auth_callback_screen.dart';

/// Central registry for all navigator routes and transitions.
class AppRoutes {
  AppRoutes._();

  static const onboarding = '/';
  static const camera = '/camera';
  static const cameraLive = '/camera_live';
  static const analysis = '/analysis';
  static const palette = '/palette';
  static const outfits = '/outfits';
  static const account = '/account';
  static const authCallback = '/auth/callback';
  static const productDetail = '/product';

  static final pages = <GetPage>[
    GetPage(
      name: onboarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: authCallback,
      page: () => const AuthCallbackScreen(),
    ),
    GetPage(
      name: camera,
      page: () => const CameraScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: cameraLive,
      page: () => const LiveCameraScreen(),
      binding: LiveCameraBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: analysis,
      page: () => const AnalysisScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: palette,
      page: () => const ColorPaletteScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: outfits,
      page: () => const OutfitSwipeScreen(),
      binding: OutfitBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: account,
      page: () => const MyAccountScreen(),
    ),
    GetPage(
      name: productDetail,
      page: () => const ProductDetailScreen(),
    ),
  ];
}