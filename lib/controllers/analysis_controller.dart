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

  Future<void> analyzePhoto(Uint8List photoBytes) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await _aiService.analyzeUser(photoBytes);
      analysis.value = result.analysis;
      dominantColors.assignAll(result.palette);
    } catch (error) {
      errorMessage.value = 'We could not analyze that photo. Please retry.';
    } finally {
      isLoading.value = false;
    }
  }
}

