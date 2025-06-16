/// Application-wide constants for the Wellness Logger app.
/// 
/// This file contains all the constant values used throughout the application
/// including app metadata, UI dimensions, colors, and configuration values.
/// 
/// Following the single source of truth principle, all constants should be
/// defined here to maintain consistency and make updates easier.
class AppConstants {
  // Prevent instantiation
  AppConstants._();
  
  // App Metadata
  static const String appName = 'Wellness Logger';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Track SVT episodes, exercise, and medication';
  
  // Database
  static const String databaseName = 'wellness_logger.db';
  static const int databaseVersion = 1;
  
  // Hive Box Names
  static const String entriesBoxName = 'wellness_entries';
  static const String settingsBoxName = 'app_settings';
  static const String analyticsBoxName = 'analytics_cache';
  
  // UI Dimensions
  static const double minimumTouchTarget = 44.0; // iOS/Android accessibility
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Entry Types
  static const String entryTypeSVT = 'SVT Episode';
  static const String entryTypeExercise = 'Exercise';
  static const String entryTypeMedication = 'Medication';
  
  static const List<String> entryTypes = [
    entryTypeSVT,
    entryTypeExercise,
    entryTypeMedication,
  ];
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy at HH:mm';
  
  // CSV Export
  static const String csvFileName = 'wellness_logger_export';
  static const List<String> csvHeaders = [
    'Date',
    'Time',
    'Type',
    'Duration',
    'Dosage',
    'Comments',
  ];
  
  // Analytics
  static const int defaultAnalyticsDays = 30;
  static const int maxAnalyticsDays = 365;
  
  // Performance
  static const int maxEntriesPerPage = 50;
  static const int searchDebounceMs = 300;
  
  // Validation
  static const int maxCommentLength = 500;
  static const int maxDurationMinutes = 999;
  
  // Quick Entry Defaults
  static const Map<String, String> quickEntryDefaults = {
    entryTypeSVT: '2 minutes',
    entryTypeExercise: '30 minutes', 
    entryTypeMedication: 'usual dose',
  };
  
  // Colors (Material 3 compatible)
  static const int primaryColorValue = 0xFF6750A4;
  static const int secondaryColorValue = 0xFF625B71;
  static const int errorColorValue = 0xFFBA1A1A;
  
  // Entry Type Colors
  static const Map<String, int> entryTypeColors = {
    entryTypeSVT: 0xFFE57373,      // Light Red
    entryTypeExercise: 0xFF81C784,  // Light Green
    entryTypeMedication: 0xFF64B5F6, // Light Blue
  };
  
  // Feature Flags (for future enhancements)
  static const bool enableAdvancedAnalytics = false;
  static const bool enableCloudSync = false;
  static const bool enableNotifications = false;
  
  // Debug Settings
  static const bool enablePerformanceLogging = true;
  static const bool enableDebugTools = true;
}

/// URL constants for external links and resources
class AppUrls {
  AppUrls._();
  
  static const String privacyPolicy = 'https://example.com/privacy';
  static const String termsOfService = 'https://example.com/terms';
  static const String supportEmail = 'support@wellnesslogger.com';
  static const String githubRepo = 'https://github.com/user/wellness-logger';
}

/// Regular expressions for validation
class AppRegex {
  AppRegex._();
  
  // Duration validation (e.g., "5 minutes", "1.5 hours")
  static final RegExp duration = RegExp(r'^\d+(\.\d+)?\s*(min|minute|minutes|hr|hour|hours|sec|second|seconds)s?$', caseSensitive: false);
  
  // Dosage validation - allows any non-empty text for flexible input
  static final RegExp dosage = RegExp(r'^.+$', caseSensitive: false);
  
  // Time format validation (HH:mm or H:mm)
  static final RegExp timeFormat = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
}
