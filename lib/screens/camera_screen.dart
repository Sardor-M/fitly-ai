import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/routes/app_routes.dart';
import '../controllers/analysis_controller.dart';
import '../controllers/camera_controller.dart';
import '../widgets/camera/camera_preview.dart';
import '../widgets/camera/face_overlay.dart';

class CameraScreen extends GetView<AppCameraController> {
  const CameraScreen({super.key});

  Future<void> _captureAndAnalyze() async {
    final file = await controller.capturePhoto();
    if (file == null) return;
    final photo = File(file.path);
    final analysisController = Get.find<AnalysisController>();
    await analysisController.analyzePhoto(photo);
    Get.toNamed(AppRoutes.analysis, arguments: photo);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture your fit'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 80, 24, 16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: const [
                        StyledCameraPreview(),
                        Padding(
                          padding: EdgeInsets.all(18),
                          child: FaceOverlay(),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, -12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 36),
                  child: Column(
                    children: [
                      Text(
                        'Center your face and keep shoulders relaxed. Natural light will give our AI the most accurate read.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => ElevatedButton.icon(
                          onPressed: controller.isBusy.value
                              ? null
                              : () => _captureAndAnalyze(),
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: Text(
                            controller.isBusy.value
                                ? 'Processing...'
                                : 'Capture selfie',
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 24,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: Get.back,
            ),
          ),
        ],
      ),
    );
  }
}

