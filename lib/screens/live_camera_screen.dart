import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/routes/app_routes.dart';
import '../controllers/analysis_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/camera_controller.dart';
import '../utils/constants.dart';
import '../widgets/camera/camera_preview.dart';
import '../widgets/camera/face_overlay.dart';

class LiveCameraScreen extends GetView<AppCameraController> {
  const LiveCameraScreen({super.key});

  Future<void> _captureAndAnalyze() async {
    final XFile? file = await controller.capturePhoto();
    if (file == null) return;
    final Uint8List bytes = await file.readAsBytes();
    final analysisController = Get.find<AnalysisController>();
    await analysisController.analyzePhoto(bytes);
    Get.toNamed(AppRoutes.analysis, arguments: bytes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and logout (same as camera_screen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppConstants.appName.toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: authController.signOut,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFFD2375),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Logout'),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.person, color: Colors.black),
                    ],
                  ),
                ],
              ),
            ),

            // Navigation bar with back button and title (same as camera_screen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Upload Photo',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Live camera preview area in the same container style
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
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
              ),
            ),

            const SizedBox(height: 32),

            // Single Capture button (same style section)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isBusy.value ? null : _captureAndAnalyze,
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: Text(
                      controller.isBusy.value ? 'Processing...' : 'Camera',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFD2375),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Info message (same as camera_screen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFACCB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '✨ AI analyzes your skin tone and fashion taste to find the perfect look for you',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
