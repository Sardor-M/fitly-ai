import 'package:camera/camera.dart';
import 'package:get/get.dart';

/// Manages camera lifecycle, preview state, and selfie capture.
class AppCameraController extends GetxController {
  final isInitialized = false.obs;
  final isBusy = false.obs;
  final errorMessage = RxnString();

  CameraController? _controller;
  List<CameraDescription> _cameras = <CameraDescription>[];

  CameraController? get cameraController => _controller;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      errorMessage.value = null;
      isBusy.value = true;
      _cameras = await availableCameras();
      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller?.initialize();
      isInitialized.value = true;
    } catch (error) {
      errorMessage.value = 'Unable to access camera: $error';
    } finally {
      isBusy.value = false;
      update();
    }
  }

  Future<XFile?> capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      errorMessage.value = 'Camera is not ready yet.';
      return null;
    }
    try {
      isBusy.value = true;
      return await _controller?.takePicture();
    } catch (error) {
      errorMessage.value = 'Failed to capture photo: $error';
      return null;
    } finally {
      isBusy.value = false;
    }
  }

  @override
  void onClose() {
    _controller?.dispose();
    super.onClose();
  }
}
