import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../app/routes/app_routes.dart';

class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  late final StreamSubscription<AuthState> _authSubscription;
  
  @override
  void initState() {
    super.initState();
    _handleCallback();
    
    // Listen for auth state changes
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      if (event == AuthChangeEvent.signedIn && session != null) {
        // User successfully signed in
        Get.offAllNamed(AppRoutes.account);
      }
    });
  }
  
  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> _handleCallback() async {
    try {
      // For web, we need to handle the URL fragments properly
      final uri = Uri.base;
      
      // Check if we have access_token in the URL fragment
      if (uri.fragment.contains('access_token')) {
        // Parse the fragment manually
        final fragments = uri.fragment.split('&');
        final params = <String, String>{};
        
        for (final fragment in fragments) {
          final keyValue = fragment.split('=');
          if (keyValue.length == 2) {
            params[keyValue[0]] = Uri.decodeComponent(keyValue[1]);
          }
        }
        
        // If we have access_token, wait a bit for Supabase to process
        if (params.containsKey('access_token')) {
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
      
      // Check if user is already logged in
      final session = Supabase.instance.client.auth.currentSession;
      final user = Supabase.instance.client.auth.currentUser;
      
      if (session != null && user != null) {
        Get.offAllNamed(AppRoutes.account);
      } else {
        // Try to get session from URL one more time
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
        
        // Check again after attempting to get session
        await Future.delayed(Duration(milliseconds: 500));
        
        final checkSession = Supabase.instance.client.auth.currentSession;
        if (checkSession != null) {
          Get.offAllNamed(AppRoutes.account);
        } else {
          // No session found, redirect to onboarding
          Get.offAllNamed(AppRoutes.onboarding);
        }
      }
    } catch (e) {
      print('Auth callback error: $e');
      // On error, check if user exists
      final hasUser = Supabase.instance.client.auth.currentUser != null;
      Get.offAllNamed(hasUser ? AppRoutes.account : AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.purple,
            ),
            SizedBox(height: 20),
            Text(
              'Authenticating...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}