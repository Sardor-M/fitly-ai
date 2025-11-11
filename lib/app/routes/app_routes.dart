import 'package:get/get.dart';

import '../../screens/analysis_screen.dart';
import '../../screens/camera_screen.dart';
import '../../screens/color_palette_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/outfit_swipe_screen.dart';
import '../../screens/product_detail_screen.dart';
import '../../screens/splash_screen.dart';

/// Central registry for all navigator routes and transitions.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const camera = '/camera';
  static const analysis = '/analysis';
  static const palette = '/palette';
  static const outfits = '/outfits';
  static const productDetail = '/product';

  static final pages = <GetPage>[
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: camera,
      page: () => const CameraScreen(),
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
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: productDetail,
      page: () => const ProductDetailScreen(),
    ),
  ];
}

