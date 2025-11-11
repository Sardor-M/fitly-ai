import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/routes/app_routes.dart';
import '../services/api_service.dart';

/**
 * Handles authentication state and Google OAuth with Supabase.
 * It is also used to check if the user is logged in.
 * It is also used to sign in with Google.
 * It is also used to sign out.
 */
class AuthController extends GetxController {
  AuthController(this._apiService);

  final ApiService _apiService;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  bool get isLoggedIn => Supabase.instance.client.auth.currentUser != null;

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await _apiService.signInWithGoogle();
      Get.offAllNamed(AppRoutes.outfits);
    } catch (error) {
      errorMessage.value = 'Google sign in failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _apiService.signOut();
    Get.offAllNamed(AppRoutes.onboarding);
  }
}

