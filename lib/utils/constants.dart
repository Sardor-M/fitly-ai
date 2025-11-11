import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const appName = 'FIT:LY';

  /// TODO(sardor): Replace the placeholders with your Supabase credentials.
  static const supabaseUrl = 'https://YOUR-SUPABASE-PROJECT.supabase.co';
  static const supabaseAnonKey = 'YOUR-SUPABASE-ANON-KEY';

  static const primaryColor = Color(0xFF1B4DE4);
  static const accentColor = Color(0xFF00D6C2);

  static const onboardingSteps = [
    'Capture a quick selfie so our AI can understand your proportions.',
    'Discover the colours that make your skin glow.',
    'Swipe through fully styled outfits curated for your day.',
  ];
}

