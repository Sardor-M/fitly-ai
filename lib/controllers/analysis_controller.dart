import 'dart:typed_data';

import 'package:get/get.dart';

import '../models/user_analysis.dart';
import '../services/ai_service.dart';

/// Coordinates AI-assisted analysis of captured selfies.
class AnalysisController extends GetxController {
  AnalysisController(this._aiService);

  final AIService _aiService;

  final analysis = Rxn<UserAnalysis>();
  final dominantColors = <int>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  // Selected items from AI analysis
  final selectedSkinTone = RxnString();
  final selectedStyles = <String>[].obs;
  final selectedPersonalColor = RxnString();

  Future<void> analyzePhoto(Uint8List photoBytes) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await _aiService.analyzeUser(photoBytes);
      analysis.value = result.analysis;
      dominantColors.assignAll(result.palette);
      
      // TODO: AI 분석 결과에 따라 선택된 항목 설정
      // 임시로 랜덤하게 선택 (나중에 실제 AI 결과로 교체)
      _setSelectedItemsFromAnalysis(result.analysis);
    } catch (error) {
      errorMessage.value = 'We could not analyze that photo. Please retry.';
    } finally {
      isLoading.value = false;
    }
  }

  void _setSelectedItemsFromAnalysis(UserAnalysis analysis) {
    // 임시: 랜덤하게 선택 (나중에 실제 AI 결과로 교체)
    final skinTones = ['Very Fair', 'Fair', 'Medium', 'Tan', 'Dark', 'Deep'];
    final styles = ['Casual', 'Minimal', 'Romantic', 'Classic', 'Sporty', 'Vintage'];
    final personalColors = ['Spring', 'Summer', 'Fall', 'Winter'];
    
    selectedSkinTone.value = skinTones[2]; // Medium
    selectedStyles.assignAll([styles[0], styles[1]]); // Casual, Minimal
    selectedPersonalColor.value = personalColors[0]; // Spring
  }
}

