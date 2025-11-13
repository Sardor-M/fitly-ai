import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../app/routes/app_routes.dart';
import '../controllers/app_controller.dart';
import '../utils/constants.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  static const _pinkColor = Color(0xFFFD2375);
  static const _lightPinkColor = Color(0xFFFFACCB);

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
        await _analyzePhoto();
      } else {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToLiveCamera() async {
    if (_isProcessing) return;
    
    try {
      /** 
        Here we are ensuring that the AppController
        is initialized before navigation
      */
      try {
        Get.find<AppController>();
      } catch (e) {
        Get.put(AppController(), permanent: true);
      }
      
      /** 
        Small delay to ensure navigator is ready
      */
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        await Get.toNamed(AppRoutes.cameraLive);
      }
    } catch (e) {
      print('Navigation error: $e');
      /** 
        If navigation fails, try again after a delay
      */
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Get.toNamed(AppRoutes.cameraLive);
          }
        });
      }
    }
  }

  Future<void> _analyzePhoto() async {
    if (_imageBytes == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      /** 
        Ensure AppController is available
      */
      AppController appController;
      try {
        appController = Get.find<AppController>();
      } catch (e) {
        appController = Get.put(AppController(), permanent: true);
      }
      
        // Store selfie in global state
      await appController.setSelfieFromBytes(_imageBytes!);
      
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
        Navigate to analysis screen (will show loading animation)
      */
      if (mounted) {
        Get.offNamed(AppRoutes.analysis);
        
        /** 
          Wait 1-2 seconds to show "Analyzing..." animation
        */
        await Future.delayed(const Duration(seconds: 2));
      }
      
      /** 
        Start face analysis in background (will update UI when done with pre-selections)
        This will automatically set isAnalyzing to false when done
      */ 
      await appController.analyzeFace();
    } catch (e, stackTrace) {
      print('Error in _analyzePhoto: $e');
      print('Stack trace: $stackTrace');
      
      try {
        final appController = Get.find<AppController>();
        appController.isAnalyzing.value = false;
        appController.analysisError.value = 'Analysis failed: $e';
      } catch (_) {}
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Get.back();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
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
                  GestureDetector(
                    onTap: () {
                      /** 
                        Navigate to camera route (home page)
                      */
                      Get.offAllNamed(AppRoutes.camera);
                    },
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

            /** 
              Navigation bar with back button and title
            */
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

            /** 
              Expanded container for the image picker
            */
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
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
                    child: _imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Select a photo',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: _pinkColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            /** 
              Action buttons - Camera and Gallery
            */
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () {
                              /** 
                                We make sure that the callback is executed after the frame is rendered
                              */
                              SchedulerBinding.instance.addPostFrameCallback((_) {
                                _navigateToLiveCamera();
                              });
                            },
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text(
                        'Take Selfie',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pinkColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, color: Colors.white),
                      label: const Text(
                        'Select from Gallery',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pinkColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /** 
              Info message about the AI analyzing the photo
            */
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _lightPinkColor,
                  borderRadius: BorderRadius.circular(10),
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