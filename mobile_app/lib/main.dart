import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/service_locator_simple.dart';
import 'presentation/screens/splash_screen.dart';

/// Main entry point for the Wellness Logger mobile application.
/// 
/// This app helps users track SVT episodes, exercise routines, and medication
/// intake with offline functionality and comprehensive analytics.
/// 
/// Features:
/// Main entry point for the Wellness Logger mobile application.
/// 
/// This app helps users track SVT episodes, exercise routines, and medication
/// intake with offline functionality and comprehensive analytics.
/// 
/// Features:
/// - Offline-first data storage using Hive
/// - Clean Architecture with BLoC state management
/// - Comprehensive health insights and analytics
/// - CSV export functionality for medical consultations
/// - Material Design 3 UI with accessibility support
/// - Production-grade error handling and crash reporting
void main() async {
  await _initializeApp();
}

/// Initialize the application with all required services and configurations
Future<void> _initializeApp() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logging
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: !kReleaseMode,
      printEmojis: !kReleaseMode,
    ),
  );
  logger.i('🚀 Starting Wellness Logger App');
  
  try {
    
    // Note: Hive initialization is handled by HiveLocalDataSource
    // This ensures proper initialization order and test compatibility
    logger.i('📦 Hive will be initialized by data source');
    debugPrint('🔍 MAIN: Starting app initialization...');
    
    // Set preferred orientations (portrait only for better UX)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    debugPrint('🔍 MAIN: Screen orientation set');
    
    // Initialize service locator (dependency injection)
    await setupServiceLocator();
    logger.i('🔧 Service locator configured');
    debugPrint('🔍 MAIN: Service locator setup complete');
    
    // Run the app
    debugPrint('🔍 MAIN: Starting Flutter app...');
    runApp(const WellnessLoggerApp());
    
  } catch (error, stackTrace) {
    logger.e('❌ Failed to initialize app', error: error, stackTrace: stackTrace);
    
    // Run a minimal error app
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to start app',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

/// Root widget of the Wellness Logger application.
/// 
/// Configures the app theme, routes, and global settings.
class WellnessLoggerApp extends StatelessWidget {
  const WellnessLoggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Home screen
      home: const SplashScreen(),
    );
  }
}
