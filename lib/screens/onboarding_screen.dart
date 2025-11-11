import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../widgets/auth/auth_layout.dart';
import '../widgets/auth/brand_logo.dart';
import '../widgets/auth/social_sign_in_button.dart';

/// Landing experience for the Fitly sign-up flow.
class OnboardingScreen extends GetView<AuthController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AuthLayout(
      title: "Welcome to Fitly",
      subtitle: "Sign in with Google to continue",
      spacing: 48,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BrandLogo(size: 80),
          const SizedBox(height: 24),
        ],
      ),
      action: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => SocialSignInButton.google(
              onPressed: controller.signInWithGoogle,
              isLoading: controller.isLoading.value,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Effortless styling, powered by computer vision.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

