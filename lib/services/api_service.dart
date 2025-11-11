import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/constants.dart';

class ApiService {
  ApiService._internal()
      : dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.supabaseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
        );

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio dio;

  SupabaseClient get client => Supabase.instance.client;

  Future<void> signInWithGoogle() async {
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback/',
    );
  }

  Future<void> signOut() => client.auth.signOut();
}

