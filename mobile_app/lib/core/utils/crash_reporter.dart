import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Production-grade error handling and crash reporting utility.
/// 
/// This class provides comprehensive error tracking, logging, and reporting
/// capabilities for production apps, including crash reports, performance
/// monitoring, and user feedback collection.
class CrashReporter {
  static CrashReporter? _instance;
  static CrashReporter get instance => _instance ??= CrashReporter._();
  
  CrashReporter._();
  
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 3,
      errorMethodCount: 8,
      lineLength: 120,
      colors: !kReleaseMode,
      printEmojis: !kReleaseMode,
    ),
  );
  
  bool _isInitialized = false;
  late PackageInfo _packageInfo;
  late String _deviceInfo;
  
  /// Initialize the crash reporter with app and device information.
  /// Should be called early in app startup.
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Get app information
      _packageInfo = await PackageInfo.fromPlatform();
      
      // Get device information
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceInfo = 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt}) - ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceInfo = 'iOS ${iosInfo.systemVersion} - ${iosInfo.model}';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        _deviceInfo = 'Linux ${linuxInfo.prettyName} - ${linuxInfo.machineId}';
      } else {
        _deviceInfo = 'Unknown Platform';
      }
      
      // Set up global error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        recordFlutterError(details);
      };
      
      // Handle platform errors (non-Flutter errors)
      PlatformDispatcher.instance.onError = (error, stack) {
        recordError(error, stack, fatal: true);
        return true;
      };
      
      _isInitialized = true;
      _logger.i('CrashReporter initialized successfully');
      
    } catch (e, stack) {
      _logger.e('Failed to initialize CrashReporter: $e\n$stack');
    }
  }
  
  /// Record a Flutter framework error
  void recordFlutterError(FlutterErrorDetails details) async {
    try {
      final errorReport = await _createErrorReport(
        error: details.exception,
        stackTrace: details.stack,
        context: details.context?.toString(),
        library: details.library,
        fatal: false, // FlutterErrorDetails doesn't have fatal property
        errorType: 'Flutter Error',
      );
      
      if (kReleaseMode) {
        _logToFile(errorReport);
      } else {
        _logger.e('Flutter Error: ${details.exception}');
      }
      
    } catch (e) {
      _logger.e('Failed to record Flutter error', e);
    }
  }
  
  /// Record a general error with optional context
  void recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? customData,
    bool fatal = false,
  }) async {
    try {
      final errorReport = await _createErrorReport(
        error: error,
        stackTrace: stackTrace,
        context: context,
        customData: customData,
        fatal: fatal,
        errorType: 'Application Error',
      );
      
      if (kReleaseMode) {
        _logToFile(errorReport);
      } else {
        _logger.e('Application Error: $error');
      }
      
    } catch (e) {
      _logger.e('Failed to record error: $e');
    }
  }
  
  /// Record a warning (non-fatal issue)
  void recordWarning(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? customData,
  }) async {
    try {
      final warningReport = await _createErrorReport(
        error: error ?? message,
        stackTrace: stackTrace,
        customData: customData,
        fatal: false,
        errorType: 'Warning',
      );
      
      if (kReleaseMode) {
        _logToFile(warningReport);
      } else {
        _logger.w(message);
      }
      
    } catch (e) {
      _logger.e('Failed to record warning', e);
    }
  }
  
  /// Log an informational message
  void logInfo(String message, {Map<String, dynamic>? data}) {
    try {
      if (kReleaseMode) {
        _logToFile({
          'type': 'Info',
          'message': message,
          'data': data,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } else {
        _logger.i(message);
      }
    } catch (e) {
      _logger.e('Failed to log info: $e');
    }
  }
  
  /// Record a performance metric
  void recordPerformance(
    String metric,
    Duration duration, {
    Map<String, dynamic>? additionalData,
  }) {
    try {
      final performanceData = {
        'type': 'Performance',
        'metric': metric,
        'duration_ms': duration.inMilliseconds,
        'timestamp': DateTime.now().toIso8601String(),
        'additional_data': additionalData,
        ...await _getAppContext(),
      };
      
      if (kReleaseMode) {
        _logToFile(performanceData);
      } else {
        _logger.d('Performance: $metric took ${duration.inMilliseconds}ms');
      }
      
    } catch (e) {
      _logger.e('Failed to record performance metric: $e');
    }
  }
  
  /// Create a comprehensive error report
  Future<Map<String, dynamic>> _createErrorReport({
    required dynamic error,
    StackTrace? stackTrace,
    String? context,
    String? library,
    Map<String, dynamic>? customData,
    bool fatal = false,
    required String errorType,
  }) async {
    return {
      'type': errorType,
      'error': error.toString(),
      'stack_trace': stackTrace?.toString(),
      'context': context,
      'library': library,
      'fatal': fatal,
      'custom_data': customData,
      'timestamp': DateTime.now().toIso8601String(),
      ...(_isInitialized ? await _getAppContext() : {}),
    };
  }
  
  /// Get app context information asynchronously
  Future<Map<String, dynamic>> _getAppContext() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _getAppContextSync();
  }
  
  /// Get app context information synchronously
  Map<String, dynamic> _getAppContextSync() {
    return {
      'app_version': _packageInfo.version,
      'build_number': _packageInfo.buildNumber,
      'package_name': _packageInfo.packageName,
      'device_info': _deviceInfo,
      'platform': Platform.operatingSystem,
      'debug_mode': kDebugMode,
      'release_mode': kReleaseMode,
    };
  }
  
  /// Log data to file (in production)
  void _logToFile(Map<String, dynamic> data) {
    // In a real production app, this would write to:
    // - Local log files for later upload
    // - Remote logging service (Firebase Crashlytics, Sentry, etc.)
    // - Analytics service
    
    // For now, we'll use the logger with a specific format
    _logger.i('PRODUCTION_LOG: ${data.toString()}');
  }
  
  /// Test the crash reporting system
  void testCrashReporting() {
    if (!kReleaseMode) {
      _logger.i('Testing crash reporting system...');
      
      // Test info logging
      logInfo('Test info message', data: {'test': true});
      
      // Test warning
      recordWarning('Test warning message', customData: {'test': true});
      
      // Test error (non-fatal)
      recordError('Test error message', StackTrace.current, context: 'Test context');
      
      // Test performance metric
      recordPerformance('test_operation', const Duration(milliseconds: 100));
      
      _logger.i('Crash reporting test completed');
    }
  }
  
  /// Handle zone errors (catches async errors)
  static void runAppWithErrorHandling(void Function() app) {
    runZonedGuarded(
      () {
        app();
      },
      (error, stack) {
        CrashReporter.instance.recordError(
          error,
          stack,
          context: 'Uncaught async error',
          fatal: true,
        );
      },
    );
  }
}

/// Extension to make error reporting easier throughout the app
extension ErrorReportingExtensions on Object {
  /// Quick method to report an error
  void reportError([StackTrace? stack, String? context]) {
    CrashReporter.instance.recordError(this, stack, context: context);
  }
}
