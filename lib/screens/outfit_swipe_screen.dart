import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../controllers/outfit_controller.dart';
import '../widgets/common/loading_shimmer.dart';
import '../widgets/outfit/outfit_card.dart';

/// Browse recommended outfits with swipeable cards.
class OutfitSwipeScreen extends GetView<OutfitController> {
  const OutfitSwipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Styled for you'),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            onPressed: () => Get.toNamed(AppRoutes.palette,
                arguments: controller.outfits.isNotEmpty
                    ? controller.outfits.first.colors
                    : <int>[]),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: authController.signOut,
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemBuilder: (_, __) =>
                  const LoadingShimmer(height: 320, width: double.infinity),
              separatorBuilder: (_, __) => const SizedBox(height: 24),
              itemCount: 3,
            );
          }
          if (controller.errorMessage.value != null) {
            return Center(
              child: Text(controller.errorMessage.value!),
            );
          }
          if (controller.outfits.isEmpty) {
            return Center(
              child: TextButton(
                onPressed: controller.fetchOutfits,
                child: const Text('Tap to refresh outfits'),
              ),
            );
          }
          final theme = Theme.of(context);
          return Swiper(
            itemBuilder: (_, index) {
              final outfit = controller.outfits[index];
              return OutfitCard(
                outfit: outfit,
                onTap: () =>
                    Get.toNamed(AppRoutes.productDetail, arguments: outfit),
              );
            },
            itemCount: controller.outfits.length,
            pagination: SwiperPagination(
              builder: DotSwiperPaginationBuilder(
                activeColor: theme.colorScheme.primary,
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                size: 8,
                activeSize: 16,
              ),
            ),
            onIndexChanged: controller.setCurrentIndex,
            loop: false,
            viewportFraction: 0.88,
            scale: 0.94,
          );
        }),
      ),
    );
  }
}

