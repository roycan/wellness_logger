import '../../core/errors/wellness_error.dart';

/// Enum defining different types of storage exceptions.
enum StorageExceptionType {
  /// Database connection or setup error
  databaseError,
  
  /// Entry not found in storage
  entryNotFound,
  
  /// Invalid data provided for operation
  invalidData,
  
  /// General operation failure
  operationFailed,
  
  /// Import operation failed
  importFailed,
  
  /// Export operation failed
  exportFailed,
  
  /// Storage corruption detected
  corruptionDetected,
}

/// Exception class for storage-related errors.
/// 
/// This exception is thrown when storage operations fail and provides
/// detailed information about the error type and context.
class StorageException extends WellnessError {
  /// The specific type of storage exception
  final StorageExceptionType type;
  
  /// Additional error context
  final Map<String, dynamic> _context;
  
  /// The original error that caused this exception (if any)
  final Object? originalError;
  
  /// The error message
  final String message;
  
  /// Creates a new storage exception.
  StorageException(
    this.message, {
    required this.type,
    Map<String, dynamic>? context,
    this.originalError,
  }) : _context = context ?? const {};

  @override
  String get userMessage {
    switch (type) {
      case StorageExceptionType.databaseError:
        return 'Database connection issue. Please try again.';
      case StorageExceptionType.entryNotFound:
        return 'The requested entry could not be found.';
      case StorageExceptionType.invalidData:
        return 'The provided data is invalid. Please check and try again.';
      case StorageExceptionType.operationFailed:
        return 'Operation failed. Please try again.';
      case StorageExceptionType.importFailed:
        return 'Failed to import data. Please check the file format.';
      case StorageExceptionType.exportFailed:
        return 'Failed to export data. Please try again.';
      case StorageExceptionType.corruptionDetected:
        return 'Data corruption detected. Please contact support.';
    }
  }

  @override
  String get debugMessage => message;

  @override
  String get errorCode => 'STORAGE_${type.name.toUpperCase()}';

  @override
  Map<String, dynamic> get context => Map.unmodifiable(_context);

  /// Creates a storage exception for database errors.
  factory StorageException.databaseError(String message, {Object? originalError}) {
    return StorageException(
      message,
      type: StorageExceptionType.databaseError,
      originalError: originalError,
    );
  }

  /// Creates a storage exception for entry not found errors.
  factory StorageException.entryNotFound(String entryId) {
    return StorageException(
      'Entry with ID "$entryId" not found',
      type: StorageExceptionType.entryNotFound,
      context: {'entryId': entryId},
    );
  }

  /// Creates a storage exception for invalid data errors.
  factory StorageException.invalidData(String message, {Map<String, dynamic>? context}) {
    return StorageException(
      message,
      type: StorageExceptionType.invalidData,
      context: context,
    );
  }

  /// Creates a storage exception for operation failures.
  factory StorageException.operationFailed(String operation, {Object? originalError}) {
    return StorageException(
      'Operation "$operation" failed',
      type: StorageExceptionType.operationFailed,
      context: {'operation': operation},
      originalError: originalError,
    );
  }

  /// Creates a storage exception for import failures.
  factory StorageException.importFailed(String message, {Object? originalError}) {
    return StorageException(
      message,
      type: StorageExceptionType.importFailed,
      originalError: originalError,
    );
  }

  /// Creates a storage exception for export failures.
  factory StorageException.exportFailed(String message, {Object? originalError}) {
    return StorageException(
      message,
      type: StorageExceptionType.exportFailed,
      originalError: originalError,
    );
  }

  /// Creates a storage exception for initialization failures.
  factory StorageException.initializationFailed(String message, {Object? originalError}) {
    return StorageException(
      message,
      type: StorageExceptionType.databaseError,
      originalError: originalError,
    );
  }

  /// Creates a storage exception for save operation failures.
  factory StorageException.saveFailed(String entryId, Object error) {
    return StorageException(
      'Failed to save entry "$entryId"',
      type: StorageExceptionType.operationFailed,
      context: {'entryId': entryId},
      originalError: error,
    );
  }

  /// Creates a storage exception for read operation failures.
  factory StorageException.readFailed(String identifier, Object error) {
    return StorageException(
      'Failed to read data "$identifier"',
      type: StorageExceptionType.operationFailed,
      context: {'identifier': identifier},
      originalError: error,
    );
  }

  /// Creates a storage exception for update operation failures.
  factory StorageException.updateFailed(String entryId, Object error) {
    return StorageException(
      'Failed to update entry "$entryId"',
      type: StorageExceptionType.operationFailed,
      context: {'entryId': entryId},
      originalError: error,
    );
  }

  /// Creates a storage exception for delete operation failures.
  factory StorageException.deleteFailed(String entryId, Object error) {
    return StorageException(
      'Failed to delete entry "$entryId"',
      type: StorageExceptionType.operationFailed,
      context: {'entryId': entryId},
      originalError: error,
    );
  }

  /// Creates a storage exception for bulk operation failures.
  factory StorageException.bulkOperationFailed(String operation, Object error) {
    return StorageException(
      'Bulk operation "$operation" failed',
      type: StorageExceptionType.operationFailed,
      context: {'operation': operation},
      originalError: error,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'StorageException',
      'errorCode': errorCode,
      'userMessage': userMessage,
      'debugMessage': debugMessage,
      'context': context,
      'originalError': originalError?.toString(),
      'storageType': type.name,
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer('StorageException: $message');
    
    if (originalError != null) {
      buffer.write('\nCaused by: $originalError');
    }
    
    if (context.isNotEmpty) {
      buffer.write('\nContext: $context');
    }
    
    return buffer.toString();
  }
}
