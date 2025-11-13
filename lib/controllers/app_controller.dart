import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/color_palette.dart';
import '../models/face_analysis_result.dart';
import '../models/generated_outfit.dart';
import '../models/style_recommendation.dart';
import '../services/mediapipe_analysis_service.dart';
import '../services/outfit_generation_service.dart';
import '../services/segmind_outfit_service.dart';
import '../services/style_recommendation_service.dart';
import 'auth_controller.dart';

class AppController extends GetxController {
  /** 
    User selfie
  */
  Rx<String?> selfiePath = Rx<String?>(null);
  Rx<Uint8List?> selfieBytes = Rx<Uint8List?>(null);
  Rx<String?> selfieBase64 = Rx<String?>(null);

  /** 
    Analysis results
  */
  Rx<FaceAnalysisResult?> faceAnalysis = Rx<FaceAnalysisResult?>(null);
  Rx<StyleRecommendation?> styleRecommendation = Rx<StyleRecommendation?>(null);

  /** 
    Selected preferences
  */
  Rx<ColorPalette?> selectedPalette = Rx<ColorPalette?>(null);
  Rx<String?> selectedStyle = Rx<String?>(null);
  Rx<String?> selectedSkinTone = Rx<String?>(null);
  Rx<String?> selectedPersonalColor = Rx<String?>(null);
  RxList<String> selectedStyles = RxList<String>([]);

  /** 
    Generated outfits
  */
  RxList<GeneratedOutfit> generatedOutfits = RxList<GeneratedOutfit>([]);
  RxBool isGeneratingOutfits = false.obs;
  RxInt currentOutfitIndex = 0.obs;
  RxBool isAnalyzing = false.obs;
  RxString analysisError = ''.obs;

  /** 
    Product URLs for clickable outfits - For Now, using static hardcoded Zara product URLs
  */
  static const List<String> _productUrls = [
    'https://www.zara.com/kr/ko/%E1%84%8F%E1%85%A9%E1%86%B7%E1%84%87%E1%85%B5-%E1%84%85%E1%85%B5%E1%84%87%E1%85%B3-%E1%84%8F%E1%85%A1%E1%86%AF%E1%84%85%E1%85%A1-%E1%84%8C%E1%85%A5%E1%86%B7%E1%84%91%E1%85%A5-p01437343.html?v1=471855638&v2=1885841',
    'https://www.zara.com/kr/ko/%E1%84%91%E1%85%A5-%E1%84%85%E1%85%B5%E1%84%87%E1%85%A5%E1%84%89%E1%85%B5%E1%84%87%E1%85%B3%E1%86%AF-%E1%84%87%E1%85%A9%E1%86%B7%E1%84%87%E1%85%A5-%E1%84%8C%E1%85%A2%E1%84%8F%E1%85%B5%E1%86%BA-p00993400.html?v1=460001213&v2=1885841',
    'https://www.zara.com/kr/ko/limited-edition-%E1%84%87%E1%85%B5%E1%86%AB%E1%84%90%E1%85%B5%E1%84%8C%E1%85%B5-%E1%84%80%E1%85%A1%E1%84%8C%E1%85%AE%E1%86%A8-%E1%84%8C%E1%85%A2%E1%84%8F%E1%85%B5%E1%86%BA-p05479403.html?v1=484486958&v2=1885841',
    'https://www.zara.com/kr/ko/%E1%84%92%E1%85%AE%E1%84%83%E1%85%B3-%E1%84%91%E1%85%A2%E1%84%89%E1%85%B5%E1%86%BC-%E1%84%8C%E1%85%A2%E1%84%8F%E1%85%B5%E1%86%BA-p06987350.html?v1=464544015&v2=1885841',
  ];

  /** 
    Get a random product URL
  */
  String _getRandomProductUrl(int index) {
    return _productUrls[index % _productUrls.length];
  }

  /** 
    Store selfie globally
  */
  Future<void> setSelfie(String path) async {
    try {
      selfiePath.value = path;
      final file = File(path);
      final bytes = await file.readAsBytes();
      selfieBytes.value = bytes;
      selfieBase64.value = base64Encode(bytes);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load image: $e');
    }
  }

  Future<void> setSelfieFromBytes(Uint8List bytes) async {
    try {
      selfieBytes.value = bytes;
      selfieBase64.value = base64Encode(bytes);

      if (kIsWeb) {
        /** 
          On web, we can't use File I/O, so we'll use a data URL approach
          Store a placeholder path that we can identify as web
        */
        selfiePath.value = 'web://selfie_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        try {
          /** 
            Save to temp file for analysis (mobile/desktop)
          */
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/selfie_${DateTime.now().millisecondsSinceEpoch}.jpg');
          await file.writeAsBytes(bytes);
          selfiePath.value = file.path;
        } catch (fileError) {
          /** 
            Even if file save fails, we can still use the bytes for web analysis
          */
          selfiePath.value = 'memory://selfie_${DateTime.now().millisecondsSinceEpoch}';
        }
      }
    } catch (e, stackTrace) {
      print('Error setting selfie: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar('Error', 'Failed to process image: $e');
    }
  }

  /** 
    Analyze face
  */
  Future<void> analyzeFace() async {
    if (selfiePath.value == null) {
      analysisError.value = 'No selfie image available';
      return;
    }

    isAnalyzing.value = true;
    analysisError.value = '';

    try {
      /** 
        Use MediaPipe for face analysis
      */
      final result = await MediaPipeAnalysisService.analyzeFace(selfiePath.value!);
      faceAnalysis.value = result;

      /** 
        Generate style recommendations
      */
      styleRecommendation.value =
          StyleRecommendationService.recommendStyle(result);
      
      /** 
        Randomly pre-select all components based on analysis results
      */
      final random = DateTime.now().millisecondsSinceEpoch;
      
      if (styleRecommendation.value != null) {
        final rec = styleRecommendation.value!;
        
        // Randomly select a palette
        if (rec.colorPalettes.isNotEmpty) {
          final paletteIndex = (random % 100) % rec.colorPalettes.length;
          selectedPalette.value = rec.colorPalettes[paletteIndex];
        } else {
          /** 
            No color palettes available in recommendation
          */
          Get.snackbar('Error', 'No color palettes available in recommendation');
        }
        
        /** 
          Randomly select 1-3 styles
        */
        if (rec.recommendedStyles.isNotEmpty) {
          final numStyles = ((random % 1000) % 3) + 1; // 1-3 styles
          final shuffledStyles = List<String>.from(rec.recommendedStyles);
          shuffledStyles.shuffle();
          final selectedStylesList = shuffledStyles.take(numStyles).map((s) => s.toLowerCase()).toList();
          
          selectedStyle.value = selectedStylesList.first;
          selectedStyles.clear();
          selectedStyles.addAll(selectedStylesList);
        } else {
          /** 
            No recommended styles available
          */
          Get.snackbar('Error', 'No recommended styles available');
        }
      } else {
        /** 
          No recommended styles available
        */
        Get.snackbar('Error', 'Style recommendation is null');
      }
      
      /** 
        Randomly select personal color (seasonal type)
      */
      final seasonalType = result.seasonalType.toLowerCase();
      final personalColors = ['Spring', 'Summer', 'Fall', 'Winter'];
      /** 
        70% chance to use analyzed seasonal type, 30% random
      */
      if ((random % 10) < 7) {
        /** 
          Use analyzed seasonal type
        */
        if (seasonalType == 'spring') {
          selectedPersonalColor.value = 'Spring';
        } else if (seasonalType == 'summer') {
          selectedPersonalColor.value = 'Summer';
        } else if (seasonalType == 'autumn' || seasonalType == 'fall') {
          selectedPersonalColor.value = 'Fall';
        } else if (seasonalType == 'winter') {
          selectedPersonalColor.value = 'Winter';
        }
      } else {
        /** 
          Random selection
        */
        selectedPersonalColor.value = personalColors[(random % 10000) % personalColors.length];
      }
      /** 
        Selected personal color: ${selectedPersonalColor.value}
      */
      _mapSkinToneFromHex(result.skinTone);
      /** 
        Randomly select one of the skin tone variations
      */
      final skinToneOptions = ['Very Fair', 'Fair', 'Medium', 'Tan', 'Dark', 'Deep'];
      /** 
        60% chance to use analyzed skin tone, 40% random
      */
      if ((random % 10) < 6 && selectedSkinTone.value != null) {
        /** 
          Keep the analyzed skin tone
        */
        selectedSkinTone.value = result.skinTone;
      } else {
        selectedSkinTone.value = skinToneOptions[(random % 100000) % skinToneOptions.length];
      }
    } catch (e, stackTrace) {
      /** 
        Analysis error
      */
      Get.snackbar('Error', 'Failed to analyze face: $e');
      analysisError.value = 'Failed to analyze face: $e';
      Get.snackbar('Analysis Error', analysisError.value);
    } finally {
      isAnalyzing.value = false;
    }
  }

  /** 
    Generate outfits with prefetching (uses Segmind for fast generation)
  */
  Future<void> generateOutfits() async {
    if (selfieBase64.value == null || selectedPalette.value == null) {
      Get.snackbar('Error', 'Please select a color palette first');
      return;
    }

    /** 
      Use fast generation with Segmind
    */
    await generateOutfitsFast();
  }

  /** 
    Fast outfit generation with Segmind (2-4 seconds per outfit)
  */
  Future<void> generateOutfitsFast() async {
    if (selfieBase64.value == null || selectedPalette.value == null) {
      Get.snackbar('Error', 'Please select a color palette first');
      return;
    }

    isGeneratingOutfits.value = true;
    generatedOutfits.clear();
    currentOutfitIndex.value = 0;

    try {
      /** 
        Create outfit descriptions based on selected palette and styles
      */
      final outfitDescriptions = _createOutfitDescriptions();

      /** 
        Generate first 3 immediately (takes 2-4 seconds each with Segmind)
      */
      final firstBatch = outfitDescriptions.take(3).toList();

      for (int i = 0; i < firstBatch.length; i++) {
        try {
          /** 
            Generating outfit ${i + 1}/${firstBatch.length}...
          */
          Get.snackbar('Info', 'Generating outfit ${i + 1}/${firstBatch.length}...');
          final startTime = DateTime.now();
          
          final imageUrl = await SegmindOutfitService.generateOutfit(
            selfieBase64: selfieBase64.value!,
            outfitDescription: firstBatch[i]['description'] as String,
            style: firstBatch[i]['style'] as String,
            seedIndex: i * 100,
          );

          final duration = DateTime.now().difference(startTime);
          print('✅ Outfit ${i + 1} generated in ${duration.inSeconds}s: ${imageUrl.substring(0, 50)}...');

          /** 
            Add to list as soon as generated with random product URL
          */
          generatedOutfits.add(GeneratedOutfit(
            imageUrl: imageUrl,
            style: firstBatch[i]['style'] as String,
            index: i,
            productUrl: _getRandomProductUrl(i),
          ));

          /** 
            Update UI immediately
          */
          update();
        } catch (e) {
          Get.snackbar('Error', 'Failed to generate outfit ${i + 1}: $e');
        }
      }

      /** 
        First batch complete. Total outfits: ${generatedOutfits.length}
      */
      Get.snackbar('Info', 'First batch complete. Total outfits: ${generatedOutfits.length}');

      // Generate rest in background
      if (outfitDescriptions.length > 3) {
        _generateBackgroundOutfits(outfitDescriptions.skip(3).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate outfits: $e');
    } finally {
      isGeneratingOutfits.value = false;
    }
  }

  Future<void> _generateBackgroundOutfits(List<Map<String, dynamic>> descriptions) async {    
    for (int i = 0; i < descriptions.length && i < 5; i++) {
      try {
        final startTime = DateTime.now();
        
        /** 
          Generate background outfit
        */
        final imageUrl = await SegmindOutfitService.generateOutfit(
          selfieBase64: selfieBase64.value!,
          outfitDescription: descriptions[i]['description'] as String,
          style: descriptions[i]['style'] as String,
          seedIndex: (i + 3) * 100,
        );

        final duration = DateTime.now().difference(startTime);
        /** 
          Background outfit ${i + 1} generated in ${duration.inSeconds}s
        */
        Get.snackbar('Info', 'Background outfit ${i + 1} generated in ${duration.inSeconds}s');

        generatedOutfits.add(GeneratedOutfit(
          imageUrl: imageUrl,
          style: descriptions[i]['style'] as String,
          index: i + 3,
          productUrl: _getRandomProductUrl(i + 3),
        ));

        update();
      } catch (e) {
        Get.snackbar('Error', 'Failed to generate background outfit ${i + 1}: $e');
      }
    }
  }

  List<Map<String, dynamic>> _createOutfitDescriptions() {
    if (selectedPalette.value == null) {
      return [];
    }

    final colors = selectedPalette.value!.colors;
    final styles = selectedStyles.isNotEmpty
        ? selectedStyles.toList()
        : (styleRecommendation.value?.recommendedStyles ?? ['casual', 'formal', 'streetwear', 'classic']);

    List<Map<String, dynamic>> descriptions = [];
    for (final style in styles.take(5)) {
      for (final color in colors.take(2)) {
        if (descriptions.length >= 8) break;
        
        descriptions.add({
          'description': _getOutfitDescription(style, color),
          'style': style,
          'color': color,
        });
      }
      if (descriptions.length >= 8) break;
    }

    while (descriptions.length < 3) {
      final style = styles[descriptions.length % styles.length];
      final color = colors[descriptions.length % colors.length];
      descriptions.add({
        'description': _getOutfitDescription(style, color),
        'style': style,
        'color': color,
      });
    }

    return descriptions;
  }

  String _getOutfitDescription(String style, String color) {
    final colorName = color.replaceAll('#', '').toLowerCase();
    final styleLower = style.toLowerCase();

    /* 
    For now, using static hardcoded outfit descriptions
    */
    final templates = {
      'casual': '$colorName t-shirt with blue jeans and white sneakers, full body outfit, natural lighting, standing pose, street style',
      'formal': '$colorName business suit with dress shirt, formal pants, dress shoes, full body professional outfit, office setting, confident pose',
      'streetwear': '$colorName hoodie with cargo pants and sneakers, full body streetwear outfit, urban background, casual pose',
      'classic': '$colorName button-up shirt with tailored pants, leather loafers, full body classic outfit, timeless style, elegant pose',
      'minimal': '$colorName minimalist t-shirt with slim fit pants, clean sneakers, full body minimal outfit, simple style, neutral pose',
      'romantic': '$colorName blouse with flowy skirt, elegant shoes, full body romantic outfit, soft lighting, graceful pose',
      'vintage': '$colorName vintage shirt with high-waisted pants, retro shoes, full body vintage outfit, classic style, nostalgic pose',
      'sporty': '$colorName athletic top with sport pants, running shoes, full body sporty outfit, active wear, dynamic pose',
      'summer': '$colorName summer dress with sandals, full body outfit, bright lighting, relaxed pose',
    };

    return templates[styleLower] ?? templates['casual']!;
  }

  void _mapSkinToneFromHex(String hex) {
    /** 
      Convert hex to approximate skin tone category
    */
    final hexCode = hex.replaceAll('#', '');
    if (hexCode.length < 6) {
      selectedSkinTone.value = 'Medium';
      return;
    }
    
    try {
      final r = int.parse(hexCode.substring(0, 2), radix: 16);
      final g = int.parse(hexCode.substring(2, 4), radix: 16);
      final b = int.parse(hexCode.substring(4, 6), radix: 16);
      final brightness = (r + g + b) / 3;
      
      if (brightness > 220) {
        selectedSkinTone.value = 'Very Fair';
      } else if (brightness > 200) {
        selectedSkinTone.value = 'Fair';
      } else if (brightness > 150) {
        selectedSkinTone.value = 'Medium';
      } else if (brightness > 120) {
        selectedSkinTone.value = 'Tan';
      } else if (brightness > 80) {
        selectedSkinTone.value = 'Dark';
      } else {
        selectedSkinTone.value = 'Deep';
      }
    } catch (e) {
      print('Error mapping skin tone: $e');
      selectedSkinTone.value = 'Medium'; 
    }
  }

  Future<void> prefetchMoreOutfits() async {
    if (selfieBase64.value == null || selectedPalette.value == null) return;

    try {
      final userId = Get.find<AuthController>().currentUser?.id;

      final allStyles = styleRecommendation.value?.recommendedStyles ??
          ['casual', 'formal', 'classic', 'streetwear'];
      final remainingStyles = allStyles
          .where((s) => s != selectedStyle.value)
          .take(5) 
          .toList();

      if (remainingStyles.isEmpty) {
        Get.snackbar('Error', 'No remaining styles to prefetch');
        return;
      }

      for (int i = 0; i < remainingStyles.length; i++) {
        try {
          final style = remainingStyles[i];
          print('🎨 Generating outfit ${i + 1}/${remainingStyles.length} with style: $style');
          
          final outfitUrl = await OutfitGenerationService.generateSingleOutfit(
            selfieBase64: selfieBase64.value!,
            palette: selectedPalette.value!,
            style: style,
            index: generatedOutfits.length,
            userId: userId,
          );
          
          
          /** 
            Add to list immediately so UI updates
          */
          generatedOutfits.add(GeneratedOutfit(
            imageUrl: outfitUrl,
            style: style,
            index: generatedOutfits.length,
          ));
        } catch (e) {
          Get.snackbar('Error', 'Failed to generate prefetch outfit $i: $e');
        }
      }
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate prefetch outfits: $e');
    }
  }

  /** 
    Clear all data
  */
  void clearAll() {
    selfiePath.value = null;
    selfieBytes.value = null;
    selfieBase64.value = null;
    faceAnalysis.value = null;
    styleRecommendation.value = null;
    selectedPalette.value = null;
    selectedStyle.value = null;
    selectedSkinTone.value = null;
    selectedPersonalColor.value = null;
    selectedStyles.clear();
    generatedOutfits.clear();
    currentOutfitIndex.value = 0;
  }
}

