import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/routes/app_routes.dart';
import '../controllers/app_controller.dart';

class AnalysisScreen extends GetView<AppController> {
  const AnalysisScreen({super.key});

  static const _pinkColor = Color(0xFFFD2375);
  static const _lightPinkColor = Color(0xFFFFACCB);

  /** 
    Skin tone colors (fallback if no analysis)
  */
  static const _skinTones = [
    ('Very Fair', Color(0xFFF5E6D3)),
    ('Fair', Color(0xFFE8D5C4)),
    ('Medium', Color(0xFFD4A574)),
    ('Tan', Color(0xFFC68642)),
    ('Dark', Color(0xFF8B4513)),
    ('Deep', Color(0xFF654321)),
  ];

  /** 
    Generate skin tone options from analyzed skin tone
  */
  static List<(String, Color)> _generateSkinToneOptions(String analyzedHex) {
    try {
      final hex = analyzedHex.replaceAll('#', '');
      final r = int.parse(hex.substring(0, 2), radix: 16);
      final g = int.parse(hex.substring(2, 4), radix: 16);
      final b = int.parse(hex.substring(4, 6), radix: 16);
      
      /** 
        Generate variations of the analyzed skin tone
      */
      final options = <(String, Color)>[];
      
      /** 
        Create lighter and darker variations
      */
      for (int i = -2; i <= 2; i++) {
        final factor = 1.0 + (i * 0.15);
        final newR = (r * factor).clamp(0, 255).toInt();
        final newG = (g * factor).clamp(0, 255).toInt();
        final newB = (b * factor).clamp(0, 255).toInt();
        
        final label = i == 0 
            ? 'Your Tone' 
            : i < 0 
                ? 'Lighter ${i.abs()}' 
                : 'Darker $i';
        
        options.add((label, Color.fromRGBO(newR, newG, newB, 1.0)));
      }
      
      return options;
    } catch (e) {
      return _skinTones;
    }
  }

  static IconData _getStyleIcon(String style) {
    final styleLower = style.toLowerCase();
    switch (styleLower) {
      case 'casual':
        return Icons.checkroom;
      case 'minimal':
        return Icons.style;
      case 'romantic':
        return Icons.favorite;
      case 'classic':
        return Icons.business_center;
      case 'sporty':
        return Icons.sports;
      case 'vintage':
        return Icons.access_time;
      case 'streetwear':
        return Icons.checkroom;
      case 'formal':
        return Icons.business_center;
      default:
        return Icons.checkroom;
    }
  }

  static const _styles = [
    ('Casual', Icons.checkroom),
    ('Minimal', Icons.style),
    ('Romantic', Icons.favorite),
    ('Classic', Icons.business_center),
    ('Sporty', Icons.sports),
    ('Vintage', Icons.access_time),
  ];

  static const _personalColors = [
    'Spring',
    'Summer',
    'Fall',
    'Winter',
  ];

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
                      'FIT:LY',
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
                if (controller.isAnalyzing.value) {
                  /** 
                    Full screen centered loading with no background buttons
                  */
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Analyzing...',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _pinkColor,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'AI is analyzing your face features',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                /** 
                  Show scrollable content when not analyzing
                */
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Obx(() {
                    if (controller.analysisError.value.isNotEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                controller.analysisError.value,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => Get.back(),
                                child: const Text('Go Back'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                  /** 
                    Show UI - will auto-populate when analysis completes
                    If analysis hasn't started or completed, show UI with no pre-selections
                  */
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: _pinkColor,
                            size: 20,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'AI Result',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _pinkColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Skin tone', context),
                      const SizedBox(height: 16),
                      Obx(() {
                        final analyzedSkinTone = controller.faceAnalysis.value?.skinTone;
                        final skinToneOptions = analyzedSkinTone != null
                            ? _generateSkinToneOptions(analyzedSkinTone)
                            : _skinTones;
                        
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: skinToneOptions.map((tone) {
                            final isSelected = controller.selectedSkinTone.value == tone.$1;
                            return _buildSkinToneCircle(tone.$1, tone.$2, isSelected);
                          }).toList(),
                        );
                      }),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Style', context),
                      const SizedBox(height: 16),
                      Obx(() {
                        final recommendedStyles = controller.styleRecommendation.value?.recommendedStyles ?? [];
                        final stylesToShow = recommendedStyles.isNotEmpty
                            ? recommendedStyles.map((style) {\
                                final icon = _getStyleIcon(style);
                                return (style.capitalizeFirst ?? style, icon);
                              }).toList()
                            : _styles;
                        
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: stylesToShow.length,
                          itemBuilder: (context, index) {
                            final style = stylesToShow[index];
                            return Obx(() {
                              final isSelected = controller.selectedStyles.contains(style.$1.toLowerCase());
                              return _buildStyleCard(style.$1, style.$2, context, isSelected);
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Personal Color', context),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: _personalColors.length,
                        itemBuilder: (context, index) {
                          final color = _personalColors[index];
                          return Obx(() {
                            final isSelected = controller.selectedPersonalColor.value == color;
                            return _buildPersonalColorCard(color, context, isSelected);
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                  }),
                );
              }),
            ),

            Obx(() {
              if (controller.isAnalyzing.value) {
                return const SizedBox.shrink();
              }
              
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Obx(() {
                    /** 
                      Enable button if analysis is complete and we have recommendations
                      and the button will auto-select palette/style on press if needed
                    */
                  final isAnalysisComplete = !controller.isAnalyzing.value && 
                      controller.analysisError.value.isEmpty;
                  final hasRecommendations = controller.styleRecommendation.value != null &&
                      controller.styleRecommendation.value!.colorPalettes.isNotEmpty &&
                      controller.styleRecommendation.value!.recommendedStyles.isNotEmpty;
                  
                  final canProceed = isAnalysisComplete && hasRecommendations;
                
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canProceed
                        ? () {
                            if (controller.selectedPalette.value == null &&
                                controller.styleRecommendation.value != null) {
                              final rec = controller.styleRecommendation.value!;
                              if (rec.colorPalettes.isNotEmpty) {
                                controller.selectedPalette.value = rec.colorPalettes.first;
                              }
                            }
                            if (controller.selectedStyle.value == null &&
                                controller.styleRecommendation.value != null) {
                              final rec = controller.styleRecommendation.value!;
                              if (rec.recommendedStyles.isNotEmpty) {
                                final firstStyle = rec.recommendedStyles.first.toLowerCase();
                                controller.selectedStyle.value = firstStyle;
                                if (!controller.selectedStyles.contains(firstStyle)) {
                                  controller.selectedStyles.add(firstStyle);
                                }
                              }
                            }
                            /** 
                              Navigate to outfit generating screen
                            */
                            Get.toNamed(AppRoutes.outfitGenerating);
                          }
                        : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pinkColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ),
                );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
        ),
        const Icon(Icons.more_horiz, color: Colors.grey),
      ],
    );
  }

  Widget _buildSkinToneCircle(String label, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () {
        Get.find<AppController>().selectedSkinTone.value = label;
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _pinkColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? _pinkColor : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStyleCard(String name, IconData icon, BuildContext context, bool isSelected) {
    /** 
      Use lowercase for consistency with how styles are stored
    */
    final styleName = name.toLowerCase();
    
    return InkWell(
      onTap: () {
        final controller = Get.find<AppController>();
        print('Style card tapped: $styleName');
        
        if (controller.selectedStyles.contains(styleName)) {
          controller.selectedStyles.remove(styleName);
          print('Removed style: $styleName, remaining: ${controller.selectedStyles}');
          /** 
            Clear selectedStyle if we removed the last one
          */
          if (controller.selectedStyles.isEmpty) {
            controller.selectedStyle.value = null;
          } else {
            controller.selectedStyle.value = controller.selectedStyles.first;
          }
        } else {
          controller.selectedStyles.add(styleName);
          controller.selectedStyle.value = styleName;
          print('Added style: $styleName, selected: ${controller.selectedStyles}');
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? _pinkColor.withValues(alpha: 0.33) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _pinkColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _pinkColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? _pinkColor : Colors.black87,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? _pinkColor : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalColorCard(String season, BuildContext context, bool isSelected) {
    return GestureDetector(
      onTap: () {
        Get.find<AppController>().selectedPersonalColor.value = season;
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? _pinkColor.withValues(alpha: 0.33) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _pinkColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _pinkColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.palette,
              size: 24,
              color: isSelected ? _pinkColor : Colors.black87,
            ),
            const SizedBox(width: 12),
            Text(
              season,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? _pinkColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
