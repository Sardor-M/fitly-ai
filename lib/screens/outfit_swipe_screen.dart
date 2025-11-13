import 'package:card_swiper/card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/routes/app_routes.dart';
import '../controllers/app_controller.dart';
import '../models/generated_outfit.dart';
import '../utils/constants.dart';

class OutfitSwipeScreen extends GetView<AppController> {
  const OutfitSwipeScreen({super.key});

  static const _pinkColor = Color(0xFFFD2375);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.offAllNamed(AppRoutes.camera),
                    child: Text(
                      AppConstants.appName.toUpperCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.black),
                    onPressed: () => Get.toNamed(AppRoutes.account),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final outfitCount = controller.generatedOutfits.length;
                
                if (outfitCount == 0) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checkroom, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No outfits generated yet',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => Get.back(),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  );
                }

                /** 
                  Here we are setting a key to force Swiper rebuild when itemCount changes
                  This ensures the Swiper updates when new outfits are added
                */
                return Swiper(
                  key: ValueKey('swiper_$outfitCount'),
                  itemBuilder: (_, index) {
                    if (index >= controller.generatedOutfits.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final outfit = controller.generatedOutfits[index];
                    return _buildOutfitCard(outfit, context, controller);
                  },
                  itemCount: outfitCount,
                  pagination: SwiperPagination(
                    builder: DotSwiperPaginationBuilder(
                      activeColor: _pinkColor,
                      color: _pinkColor.withValues(alpha: 0.3),
                      size: 8,
                      activeSize: 12,
                    ),
                  ),
                  onIndexChanged: (index) {
                    if (index < controller.generatedOutfits.length) {
                      controller.currentOutfitIndex.value = index;
                    }
                  },
                  loop: false,
                  viewportFraction: 1.0,
                  scale: 1.0,
                  /** 
                    Here we are forcing the Swiper to rebuild when items change
                    This ensures the Swiper updates when new outfits are added
                  */
                  autoplay: false,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitCard(GeneratedOutfit outfit, BuildContext context, AppController controller) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          /** 
            Here we are building the outfit card
            It is a full screen stretched and clickable image
          */
          GestureDetector(
            onTap: () => _openProductUrl(outfit),
            child: CachedNetworkImage(
              imageUrl: outfit.imageUrl,
              fit: BoxFit.cover, // Changed from contain to cover for full stretch
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade900,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade900,
                child: const Center(
                  child: Icon(Icons.error_outline, size: 48, color: Colors.white),
                ),
              ),
            ),
          ),
          /** 
            Here we are building the gradient overlay at 
            bottom with style, like, and share buttons
          */
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          outfit.style.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(() {
                          final currentIndex = controller.currentOutfitIndex.value;
                          final totalCount = controller.generatedOutfits.length;
                          return Text(
                            '${currentIndex + 1} of $totalCount',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.white),
                        onPressed: () {
                          /** 
                            TODO: Will implement the functionality later
                          */
                        },
                        tooltip: 'Like',
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () => _shareOutfit(outfit),
                        tooltip: 'Share outfit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.open_in_new, color: Colors.white),
                        onPressed: () => _openProductUrl(outfit),
                        tooltip: 'View product',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareOutfit(GeneratedOutfit outfit) async {
    try {
      /** 
        Create a shareable message with the outfit details and image URL
      */
      final shareText = '''✨ Check out this ${outfit.style.toUpperCase()} outfit generated by FIT:LY AI!

      ${outfit.imageUrl}

      Get your own AI-powered style recommendations with FIT:LY! 🎨✨''';

      /** 
        Share the text with the image URL as a clickable link
      */
      await Share.share(
        shareText,
        subject: 'My ${outfit.style} Outfit from FIT:LY',
      );
    } catch (e) {
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _openProductUrl(GeneratedOutfit outfit) async {
    final url = outfit.productUrl;
    if (url == null || url.isEmpty) {
      /** 
        If no URL, show a message
      */
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text('Product URL not available'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (Get.context != null) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            const SnackBar(
              content: Text('Could not open product URL'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text('Error opening URL: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}