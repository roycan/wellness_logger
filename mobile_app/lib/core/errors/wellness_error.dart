/// Base class for all application-specific errors.
/// 
/// This abstract class provides a common interface for all errors in the
/// wellness logger application. It ensures consistent error handling and
/// provides both user-friendly messages and detailed debug information.
/// 
/// All custom errors should extend this class to maintain consistency
/// across the application and enable proper error categorization.
abstract class WellnessError implements Exception {
  /// User-friendly error message that can be displayed in the UI
  String get userMessage;
  
  /// Detailed error message for debugging purposes
  String get debugMessage;
  
  /// Additional context information about the error
  Map<String, dynamic> get context;
  
  /// Error code for categorization and tracking
  String get errorCode;
  
  /// Timestamp when the error occurred
  DateTime get timestamp => DateTime.now();
  
  @override
  String toString() => 'WellnessError($errorCode): $debugMessage';
}

/// Error related to data validation failures.
/// 
/// This error is thrown when user input or data doesn't meet the
/// validation requirements defined in the application.
class DataValidationError extends WellnessError {
  final String field;
  final String reason;
  final dynamic value;
  final String? suggestion;
  
  DataValidationError({
    required this.field,
    required this.reason,
    this.value,
    this.suggestion,
  });
  
  @override
  String get userMessage {
    final baseMessage = 'Please check your $field entry';
    return suggestion != null ? '$baseMessage. $suggestion' : baseMessage;
  }
  
  @override
  String get debugMessage => 'Validation failed for field "$field": $reason';
  
  @override
  String get errorCode => 'VALIDATION_ERROR';
  
  @override
  Map<String, dynamic> get context => {
    'field': field,
    'reason': reason,
    'value': value,
    'suggestion': suggestion,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Error related to local storage operations.
/// 
/// This error is thrown when database operations fail, such as
/// read/write operations, migrations, or corruption issues.
class StorageError extends WellnessError {
  final String operation;
  final String details;
  final Exception? originalException;
  
  StorageError({
    required this.operation,
    required this.details,
    this.originalException,
  });
  
  @override
  String get userMessage => 'Unable to save your data. Please try again.';
  
  @override
  String get debugMessage => 'Storage operation "$operation" failed: $details';
  
  @override
  String get errorCode => 'STORAGE_ERROR';
  
  @override
  Map<String, dynamic> get context => {
    'operation': operation,
    'details': details,
    'originalException': originalException?.toString(),
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Error related to data export operations.
/// 
/// This error is thrown when CSV export or data sharing operations fail.
class ExportError extends WellnessError {
  final String exportType;
  final String reason;
  final int? entryCount;
  
  ExportError({
    required this.exportType,
    required this.reason,
    this.entryCount,
  });
  
  @override
  String get userMessage => 'Unable to export your data. Please try again.';
  
  @override
  String get debugMessage => 'Export operation "$exportType" failed: $reason';
  
  @override
  String get errorCode => 'EXPORT_ERROR';
  
  @override
  Map<String, dynamic> get context => {
    'exportType': exportType,
    'reason': reason,
    'entryCount': entryCount,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Error related to analytics calculations.
/// 
/// This error is thrown when statistical analysis or insights
/// generation fails due to insufficient data or calculation errors.
class AnalyticsError extends WellnessError {
  final String analysisType;
  final String reason;
  final Map<String, dynamic>? analysisContext;
  
  AnalyticsError({
    required this.analysisType,
    required this.reason,
    this.analysisContext,
  });
  
  @override
  String get userMessage => 'Unable to generate insights. Please try again.';
  
  @override
  String get debugMessage => 'Analytics operation "$analysisType" failed: $reason';
  
  @override
  String get errorCode => 'ANALYTICS_ERROR';
  
  @override
  Map<String, dynamic> get context => {
    'analysisType': analysisType,
    'reason': reason,
    'analysisContext': analysisContext,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Error related to data import/migration operations.
/// 
/// This error is thrown when importing data from the web version
/// or migrating between app versions fails.
class MigrationError extends WellnessError {
  final String migrationType;
  final String reason;
  final String? sourceVersion;
  final String? targetVersion;
  
  MigrationError({
    required this.migrationType,
    required this.reason,
    this.sourceVersion,
    this.targetVersion,
  });
  
  @override
  String get userMessage => 'Unable to import your data. Please check the file format.';
  
  @override
  String get debugMessage => 'Migration "$migrationType" failed: $reason';
  
  @override
  String get errorCode => 'MIGRATION_ERROR';
  
  @override
  Map<String, dynamic> get context => {
    'migrationType': migrationType,
    'reason': reason,
    'sourceVersion': sourceVersion,
    'targetVersion': targetVersion,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Network-related errors (for future cloud features).
/// 
/// This error is thrown when network operations fail, such as
/// cloud sync or remote backup operations.
class NetworkError extends WellnessError {
  final String operation;
  final int? statusCode;
  final String? endpoint;
  
  NetworkError({
    required this.operation,
    this.statusCode,
    this.endpoint,
  });
  
  @override
  String get userMessage => 'Network connection failed. Please check your internet connection.';
  
  @override
  String get debugMessage => 'Network operation "$operation" failed${statusCode != null ? ' with status $statusCode' : ''}';
  
  @override
  String get errorCode => 'NETWORK_ERROR';
  
  @override
  Map<String, dynamic> get context => {
    'operation': operation,
    'statusCode': statusCode,
    'endpoint': endpoint,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Utility class for error handling and reporting.
/// 
/// Provides common error handling patterns and utilities for
/// consistent error management throughout the application.
class ErrorHandler {
  /// Converts any exception to a WellnessError
  static WellnessError fromException(Exception exception, {String? context}) {
    if (exception is WellnessError) {
      return exception;
    }
    
    // Convert common Flutter/Dart exceptions to WellnessError
    if (exception.toString().contains('database') || 
        exception.toString().contains('storage')) {
      return StorageError(
        operation: context ?? 'unknown',
        details: exception.toString(),
        originalException: exception,
      );
    }
    
    // Default to generic error
    return _GenericError(
      message: exception.toString(),
      context: context,
      originalException: exception,
    );
  }
  
  /// Determines if an error is recoverable
  static bool isRecoverable(WellnessError error) {
    switch (error.errorCode) {
      case 'NETWORK_ERROR':
      case 'EXPORT_ERROR':
        return true;
      case 'STORAGE_ERROR':
      case 'MIGRATION_ERROR':
        return false;
      default:
        return true;
    }
  }
  
  /// Gets suggested user actions for an error
  static List<String> getSuggestedActions(WellnessError error) {
    switch (error.errorCode) {
      case 'VALIDATION_ERROR':
        return ['Check your input and try again'];
      case 'STORAGE_ERROR':
        return ['Restart the app', 'Free up device storage', 'Contact support'];
      case 'EXPORT_ERROR':
        return ['Try again', 'Check available storage space'];
      case 'ANALYTICS_ERROR':
        return ['Add more entries for better insights', 'Try again later'];
      case 'MIGRATION_ERROR':
        return ['Check file format', 'Try a different export file'];
      case 'NETWORK_ERROR':
        return ['Check internet connection', 'Try again later'];
      default:
        return ['Try again', 'Restart the app if problem persists'];
    }
  }
}

/// Generic error for uncategorized exceptions
class _GenericError extends WellnessError {
  final String message;
  final String? contextInfo;
  final Exception? originalException;
  
  _GenericError({
    required this.message,
    String? context,
    this.originalException,
  }) : contextInfo = context;
  
  @override
  String get userMessage => 'Something went wrong. Please try again.';
  
  @override
  String get debugMessage => message;
  
  @override
  String get errorCode => 'GENERIC_ERROR';
  
  @override
  Map<String, dynamic> get context => {
    'message': message,
    'context': contextInfo,
    'originalException': originalException?.toString(),
    'timestamp': timestamp.toIso8601String(),
  };
}
