import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSecrets {
  const AppSecrets._();

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}

class AppConstants {
  AppConstants._();

  static const appName = 'FIT:LY';
  static const primaryColor = Color(0xFF1B4DE4);
  static const accentColor = Color(0xFF00D6C2);

  static const onboardingSteps = [
    'Capture a quick selfie so our AI can understand your proportions.',
    'Discover the colours that make your skin glow.',
    'Swipe through fully styled outfits curated for your day.',
  ];
}

