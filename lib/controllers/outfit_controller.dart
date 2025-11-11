import 'package:get/get.dart';

import '../models/outfit.dart';
import '../services/clothing_service.dart';

/// Loads AI-curated outfits and tracks the active selection.
class OutfitController extends GetxController {
  OutfitController(this._clothingService);

  final ClothingService _clothingService;

  final outfits = <Outfit>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOutfits();
  }

  Future<void> fetchOutfits() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final result = await _clothingService.fetchRecommendedOutfits();
      outfits.assignAll(result);
    } catch (error) {
      errorMessage.value = 'Unable to load outfits, please refresh.';
    } finally {
      isLoading.value = false;
    }
  }

  void setCurrentIndex(int index) {
    currentIndex.value = index;
  }
}

