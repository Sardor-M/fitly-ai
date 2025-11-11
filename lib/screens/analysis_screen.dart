import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/routes/app_routes.dart';
import '../controllers/analysis_controller.dart';
import '../widgets/analysis/color_palette_grid.dart';
import '../widgets/analysis/skin_tone_card.dart';
import '../widgets/common/loading_shimmer.dart';

class AnalysisScreen extends GetView<AnalysisController> {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Uint8List? photoBytes =
        Get.arguments is Uint8List ? Get.arguments as Uint8List : null;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Fit DNA'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (photoBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.memory(
                    photoBytes,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 24),
              Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingShimmer(height: 220, width: double.infinity);
                }
                if (controller.errorMessage.value != null) {
                  return Center(
                    child: Text(
                      controller.errorMessage.value!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  );
                }
                final analysis = controller.analysis.value;
                final colors = controller.dominantColors.toList();
                if (analysis == null) {
                  return Center(
                    child: Text(
                      'Capture a selfie to unlock your personalized analysis.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkinToneCard(
                      title: 'Skin tone & undertone',
                      description: analysis.skinToneDescription,
                      color: Colors.orange.shade300,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Dominant palette',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ColorPaletteGrid(colors: colors),
                    const SizedBox(height: 24),
                    Text(
                      'Best occasions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...analysis.occasions.map(
                      (occasion) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              height: 6,
                              width: 6,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(occasion),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Get.toNamed(AppRoutes.palette,
                            arguments: colors.toList()),
                        child: const Text('Explore colour playbook'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Get.offAllNamed(AppRoutes.outfits),
                        child: const Text('See recommended outfits'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

