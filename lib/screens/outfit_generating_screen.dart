import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/routes/app_routes.dart';
import '../controllers/app_controller.dart';
import '../utils/constants.dart';

class OutfitGeneratingScreen extends StatefulWidget {
  const OutfitGeneratingScreen({super.key});

  @override
  State<OutfitGeneratingScreen> createState() => _OutfitGeneratingScreenState();
}

class _OutfitGeneratingScreenState extends State<OutfitGeneratingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Timer? _countdownTimer;
  int _secondsRemaining = 60;
  String _statusText = 'Cooking';
  int _statusIndex = 0;
  final List<String> _statusMessages = ['Cooking', 'Generating', 'Creating'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startCountdown();
    _startStatusRotation();

    /** 
      Start generating outfits
    */
    _startGeneration();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _secondsRemaining = 60; // Reset to 60 seconds
          }
        });
      }
    });
  }

  void _startStatusRotation() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _statusIndex = (_statusIndex + 1) % _statusMessages.length;
          _statusText = _statusMessages[_statusIndex];
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _startGeneration() async {
    final controller = Get.find<AppController>();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Ensure we have required data
    if (controller.selfieBase64.value == null) {
      if (mounted) {
        Get.snackbar('Error', 'No selfie image available');
        Get.back();
      }
      return;
    }
    
    if (controller.selectedPalette.value == null) {
      /** 
        Auto-select first palette if available
      */
      if (controller.styleRecommendation.value != null) {
        final rec = controller.styleRecommendation.value!;
        if (rec.colorPalettes.isNotEmpty) {
          controller.selectedPalette.value = rec.colorPalettes.first;
        }
      }
      
      if (controller.selectedPalette.value == null) {
        if (mounted) {
          Get.snackbar('Error', 'Please select a color palette first');
          Get.back();
        }
        return;
      }
    }

    /** 
      Start monitoring for outfit completion
    */
    _monitorOutfitGeneration(controller);
    
    /** 
      Generate outfits
    */
    try {
      await controller.generateOutfits();
    } catch (e) {
      if (mounted) {
        print('Generation error: $e');
        Get.snackbar('Error', 'Failed to generate outfits: $e');
        Get.back();
      }
    }
  }

  void _monitorOutfitGeneration(AppController controller) {
    bool hasNavigated = false;
    
    /** 
      Monitor outfit generation progress
    */
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (!hasNavigated && controller.generatedOutfits.isNotEmpty) {
        hasNavigated = true;
        timer.cancel();
        /** 
          Navigate immediately when first image is ready
        */
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Get.offNamed(AppRoutes.outfits);
          }
        });
      } else if (!controller.isGeneratingOutfits.value && 
                 controller.generatedOutfits.isEmpty) {
        /** 
          Generation finished but no outfits - might be an error
        */
        timer.cancel();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && controller.generatedOutfits.isEmpty) {
            Get.snackbar('Error', 'Failed to generate outfits. Please try again.');
            Get.back();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<AppController>();

    return Scaffold(
      body: Stack(
        children: [
          /** 
            Blurred background with selfie (if available)
          */
          if (controller.selfieBytes.value != null)
            Positioned.fill(
              child: Image.memory(
                controller.selfieBytes.value!,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              color: Colors.black87,
            ),
          /** 
            Dark overlay
          */
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),
          /** 
            Blur effect
          */
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          SafeArea(
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
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Icon(Icons.person, color: Colors.white),
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                                value: _animation.value,
                              ),
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withValues(alpha: 0.4),
                                ),
                                strokeWidth: 2,
                                value: 1.0 - _animation.value,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Obx(() {
                      final isGenerating = controller.isGeneratingOutfits.value;
                      return Column(
                        children: [
                          Text(
                            'Ai is $_statusText~~~!',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Obx(() {
                            final outfitCount = controller.generatedOutfits.length;
                            return Text(
                              isGenerating
                                  ? outfitCount > 0
                                      ? '$outfitCount outfit${outfitCount > 1 ? 's' : ''} ready! More in $_secondsRemaining seconds'
                                      : 'New images in $_secondsRemaining seconds'
                                  : 'Almost ready...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                              textAlign: TextAlign.center,
                            );
                          }),
                        ],
                      );
                    }),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

