import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../app/routes/app_routes.dart';
import '../controllers/analysis_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/common/loading_shimmer.dart';

class AnalysisScreen extends GetView<AnalysisController> {
  const AnalysisScreen({super.key});

  static const _pinkColor = Color(0xFFFD2375);
  static const _lightPinkColor = Color(0xFFFFACCB);

  // Skin tone colors
  static const _skinTones = [
    ('Very Fair', Color(0xFFF5E6D3)),
    ('Fair', Color(0xFFE8D5C4)),
    ('Medium', Color(0xFFD4A574)),
    ('Tan', Color(0xFFC68642)),
    ('Dark', Color(0xFF8B4513)),
    ('Deep', Color(0xFF654321)),
  ];

  // Style data with SVG icons
  static const _styles = [
    ('Casual', 'assets/icons/casual.svg'),
    ('Minimal', 'assets/icons/minimal.svg'),
    ('Romantic', 'assets/icons/romantic.svg'),
    ('Classic', 'assets/icons/classic.svg'),
    ('Sporty', 'assets/icons/sporty.svg'),
    ('Vintage', 'assets/icons/vintage.svg'),
  ];

  // Personal color (아이콘 + 이름만 표시)
  static const _personalColors = [
    ('Spring', 'assets/icons/spring.svg'),
    ('Summer', 'assets/icons/summer.svg'),
    ('Fall', 'assets/icons/fall.svg'),
    ('Winter', 'assets/icons/winter.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FIT:LY',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          final authController = Get.find<AuthController>();
                          authController.signOut();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: _pinkColor,
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: LoadingShimmer(height: 220, width: double.infinity),
                    );
                  }

                  if (controller.errorMessage.value != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          controller.errorMessage.value!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    );
                  }

                  if (controller.analysis.value == null) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // AI RESULT Title
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: _pinkColor,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AI RESULT',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _pinkColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Skin tone
                      _buildSectionTitle('Skin tone', context),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _skinTones.map((tone) {
                          return Obx(() {
                            final isSelected = controller.selectedSkinTone.value == tone.$1;
                            return _buildSkinToneCircle(tone.$1, tone.$2, isSelected);
                          });
                        }).toList(),
                      ),
                      const SizedBox(height: 32),

                      // Style
                      _buildSectionTitle('Style', context),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: _styles.length,
                        itemBuilder: (context, index) {
                          final style = _styles[index];
                          return Obx(() {
                            final isSelected = controller.selectedStyles.contains(style.$1);
                            return _buildStyleCard(style.$1, style.$2, context, isSelected);
                          });
                        },
                      ),
                      const SizedBox(height: 32),

                      // Personal Color (아이콘 + 텍스트만)
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
                            final isSelected = controller.selectedPersonalColor.value == color.$1;
                            return _buildPersonalColorCard(color.$1, color.$2, context, isSelected);
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                }),
              ),
            ),

            // NEXT Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final colors = controller.dominantColors.toList();
                    if (colors.isNotEmpty) {
                      Get.toNamed(AppRoutes.palette, arguments: colors);
                    } else {
                      Get.toNamed(AppRoutes.outfits);
                    }
                  },
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
              ),
            ),
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
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? _pinkColor : Colors.grey.shade300,
              width: isSelected ? 3 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _pinkColor.withOpacity(0.3),
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
    );
  }

  Widget _buildStyleCard(String name, String iconPath, BuildContext context, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? _pinkColor.withOpacity(0.33) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? _pinkColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: _pinkColor.withOpacity(0.2),
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
          _buildStyleIcon(iconPath, context),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleIcon(String iconPath, BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: SvgPicture.asset(
        iconPath,
        width: 48,
        height: 48,
        fit: BoxFit.contain,
        semanticsLabel: iconPath,
        placeholderBuilder: (context) {
          print('Loading SVG: $iconPath');
          return const SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error rendering SVG: $iconPath - $error');
          print('Stack trace: $stackTrace');
          // SVG가 너무 복잡해서 렌더링 실패 시 아이콘으로 대체
          return const Icon(Icons.checkroom, size: 32, color: Colors.black87);
        },
      ),
    );
  }

  Widget _buildPersonalColorCard(String season, String iconPath, BuildContext context, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? _pinkColor.withOpacity(0.33) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? _pinkColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: _pinkColor.withOpacity(0.2),
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
          SizedBox(
            width: 28,
            height: 28,
            child: SvgPicture.asset(
              iconPath,
              width: 28,
              height: 28,
              fit: BoxFit.contain,
              semanticsLabel: iconPath,
              placeholderBuilder: (context) {
                print('Loading SVG: $iconPath');
                return const SizedBox(
                  width: 28,
                  height: 28,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print('Error rendering SVG: $iconPath - $error');
                print('Stack trace: $stackTrace');
                return const Icon(Icons.palette, size: 24, color: Colors.black87);
              },
            ),
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
    );
  }
}