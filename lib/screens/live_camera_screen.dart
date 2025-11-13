import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/routes/app_routes.dart';
import '../controllers/app_controller.dart';
import '../controllers/camera_controller.dart';
import '../utils/constants.dart';
import '../widgets/camera/camera_preview.dart';
import '../widgets/camera/face_overlay.dart';

class LiveCameraScreen extends GetView<AppCameraController> {
  const LiveCameraScreen({super.key});

  Future<void> _captureAndAnalyze() async {
    if (controller.isBusy.value) return;
    
    controller.isBusy.value = true;
    
    try {
      final XFile? file = await controller.capturePhoto();
      if (file == null) {
        controller.isBusy.value = false;
        return;
      }
      
      final Uint8List bytes = await file.readAsBytes();
      
      /** 
        Here we are ensuring that the AppController
        is initialized before navigation
      */
      AppController appController;
      try {
        appController = Get.find<AppController>();
      } catch (e) {
        appController = Get.put(AppController(), permanent: true);
      }
      
      /** 
        Store selfie in global state
      */
      await appController.setSelfieFromBytes(bytes);
      
      /** 
        Set analyzing state to show loading animation
      */
      appController.isAnalyzing.value = true;
      appController.analysisError.value = '';
      
      /** 
        Wait a bit to ensure state is set
      */
      await Future.delayed(const Duration(milliseconds: 100));
      
      /** 
        Navigate to analysis screen
        This will automatically set isAnalyzing to false when done
      */
      Get.offNamed(AppRoutes.analysis);
      await Future.delayed(const Duration(seconds: 2));
      
      /** 
        Start face analysis in background, 
        it will update UI when done with pre-selections
        This will automatically set isAnalyzing to false when done
      */
      await appController.analyzeFace();
    } catch (e, stackTrace) {
      print('Error in _captureAndAnalyze: $e');
      print('Stack trace: $stackTrace');
      
      /** 
        Reset busy state on error
      */
      controller.isBusy.value = false;
      /** 
        Reset analyzing state on error
      */
      try {
        final appController = Get.find<AppController>();
        appController.isAnalyzing.value = false;
        appController.analysisError.value = 'Failed to process photo: $e';
      } catch (_) {}
      
      if (Get.isSnackbarOpen) {
        Get.back();
      }
      Get.snackbar('Error', 'Failed to process photo: $e');
    } finally {
      controller.isBusy.value = false;
      appController.isAnalyzing.value = false;
      appController.analysisError.value = 'Failed to process photo: $e';
    }
  }

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
                  Text(
                    AppConstants.appName.toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

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
