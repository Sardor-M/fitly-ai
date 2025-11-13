import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_bindings.dart';
import 'app/routes/app_routes.dart';
import 'app/themes/app_theme.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
    
  /** 
    Load environment variables from .env file
  */
  await dotenv.load(fileName: '.env');
  
  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
    ),
  );
  runApp(const StyleAIApp());
}

class StyleAIApp extends StatefulWidget {
  const StyleAIApp({super.key});

  @override
  State<StyleAIApp> createState() => _StyleAIAppState();
}

class _StyleAIAppState extends State<StyleAIApp> {
  bool _isLoading = true;
  String _initialRoute = AppRoutes.onboarding;

  @override
  void initState() {
    super.initState();
    _checkAuthAndRoute();
  }

  Future<void> _checkAuthAndRoute() async {
    /** 
      Wait a bit for Supabase to initialize
    */
    await Future.delayed(const Duration(milliseconds: 300));
    
    final session = Supabase.instance.client.auth.currentSession;
    final user = Supabase.instance.client.auth.currentUser;
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _initialRoute = (session != null && user != null)
            ? AppRoutes.welcome
            : AppRoutes.onboarding;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /** 
      Always use GetMaterialApp to prevent layout shifts
      Use key to force rebuild when route changes
    */
    return GetMaterialApp(
      key: ValueKey('${_isLoading}_$_initialRoute'),
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      getPages: AppRoutes.pages,
      initialBinding: AppBindings(),
      initialRoute: _initialRoute,
      /** 
        Use builder to show loading screen while checking auth
      */
      builder: (context, child) {
        if (_isLoading) {
          return _LoadingScreen();
        }
        /** 
          Return the child (the actual route) when loading is complete
        */
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

/** 
  Separate loading screen widget
*/
class _LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading...',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}