import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/camera_controller.dart';
import '../common/loading_shimmer.dart';

class StyledCameraPreview extends GetView<AppCameraController> {
  const StyledCameraPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.errorMessage.value != null) {
        return Center(
          child: Text(
            controller.errorMessage.value!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        );
      }

      if (!controller.isInitialized.value) {
        return const LoadingShimmer(height: 420, width: double.infinity);
      }

      final camController = controller.cameraController!;
      return ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: AspectRatio(
          aspectRatio: camController.value.aspectRatio,
          child: CameraPreview(camController),
        ),
      );
    });
  }
}

