import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/routes/app_routes.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  AuthController(this._apiService);

  final ApiService _apiService;

  final isLoading = false.obs;
  final errorMessage = RxnString();
  late final StreamSubscription<AuthState> _authSub;

  @override
  void onInit() {
    super.onInit();
    _authSub =
        Supabase.instance.client.auth.onAuthStateChange.listen((AuthState data) {
      if (data.event == AuthChangeEvent.signedIn &&
          data.session?.user != null) {
        Get.offAllNamed(AppRoutes.welcome);
      }
      if (data.event == AuthChangeEvent.signedOut) {
        Get.offAllNamed(AppRoutes.onboarding);
      }
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await _apiService.signInWithGoogle();
    } catch (error) {
      errorMessage.value = 'Google sign in failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _apiService.signOut();
    } finally {
      isLoading.value = false;
    }
  }

  User? get currentUser => Supabase.instance.client.auth.currentUser;

  @override
  void onClose() {
    _authSub.cancel();
    super.onClose();
  }
}