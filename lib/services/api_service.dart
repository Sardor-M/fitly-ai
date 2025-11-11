import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/constants.dart';

class ApiService {
  ApiService._internal()
      : dio = Dio(
          BaseOptions(
            baseUrl: AppSecrets.supabaseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
        );

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio dio;

  SupabaseClient get client => Supabase.instance.client;

  Future<void> signInWithGoogle() async {
    final redirect = kIsWeb
        ? '${Uri.base.origin}/#/auth/callback'
        : 'io.supabase.flutter://login-callback/';

    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirect,
    );
  }

  Future<void> signOut() => client.auth.signOut();
}

