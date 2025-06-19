import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'main_navigation_screen.dart';

/// Splash screen displayed during app initialization.
/// 
/// This screen is shown while the app performs initial setup tasks such as:
/// - Loading user preferences
/// - Initializing database connections
/// - Checking for data migrations
/// - Setting up analytics services
/// 
/// The splash screen provides visual feedback to users and ensures
/// a smooth transition to the main app interface.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    // Start animation
    _animationController.forward();
    
    // Navigate to main app after initialization
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Initializes the app and navigates to the main screen.
  /// 
  /// This method simulates the app initialization process and then
  /// shows a simple message. In Phase 1, this will navigate to the main app.
  Future<void> _initializeApp() async {
    try {
      // Simulate initialization delay
      await Future.delayed(const Duration(seconds: 3));
      
      // TODO: Add actual initialization logic here in Phase 1
      // - Load user preferences
      // - Check for data migrations  
      // - Initialize analytics
      // - Preload critical data
      
      if (mounted) {
        // For now, just show a simple message
        _showWelcomeMessage();
      }
    } catch (error) {
      // Handle initialization errors
      if (mounted) {
        _showErrorDialog(error.toString());
      }
    }
  }

  /// Shows a welcome message after initialization, then navigates to main app.
  void _showWelcomeMessage() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Welcome to Wellness Logger!'),
        content: const Text(
          'Your personal health tracking app is ready.\n\n'
          'Phase 3: UI Foundation complete! 🎉\n\n'
          'You can now navigate between screens and see the basic UI structure.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToMainApp();
            },
            child: const Text('Get Started!'),
          ),
        ],
      ),
    );
  }

  /// Navigates to the main application screen.
  void _navigateToMainApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(),
      ),
    );
  }

  /// Shows an error dialog if initialization fails.
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Initialization Error'),
        content: Text(
          'Failed to initialize the app:\n\n$error',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeApp(); // Retry initialization
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon/Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius * 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite,
                        size: 60,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.largePadding * 2),
                    
                    // App Name
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.smallPadding),
                    
                    // App Description
                    Text(
                      AppConstants.appDescription,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: AppConstants.largePadding * 2),
                    
                    // Loading Indicator
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Loading Text
                    Text(
                      'Initializing...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
