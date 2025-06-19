import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
/// - Offline-first data storage using Hive
/// - Clean Architecture with BLoC state management
/// - Comprehensive health insights and analytics
/// - CSV export functionality for medical consultations
/// - Material Design 3 UI with accessibility support
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logging
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  logger.i('🚀 Starting Wellness Logger App');
  
  try {
    // Initialize Hive for local storage
    await Hive.initFlutter();
    logger.i('📦 Hive initialized successfully');
    
    // Set preferred orientations (portrait only for better UX)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Initialize service locator (dependency injection)
    await setupServiceLocator();
    logger.i('🔧 Service locator configured');
    
    // Run the app
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
      
      // Accessibility and Error handling
      builder: (context, child) {
        // Configure error widget
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bug_report, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (kDebugMode)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        errorDetails.exception.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          );
        };
        
        // Return child with text scaling limits
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.4,
            ),
          ),
          child: child!,
        );
      },
      
      // Home screen
      home: const SplashScreen(),
    );
  }
}
