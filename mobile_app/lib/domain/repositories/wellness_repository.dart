import '../entities/wellness_entry.dart';
import '../entities/analytics_data.dart';

/// Repository interface for wellness data operations.
/// 
/// This interface defines the business logic layer for data access,
/// abstracting the underlying data sources and providing a clean API
/// for the presentation layer.
/// 
/// **AI-Friendly**: Clear business rules and data transformation
/// **Student-Friendly**: High-level operations with clear purpose
/// **Test-Friendly**: Easy to mock and test business logic
abstract class WellnessRepository {
  /// Initialize the repository and its data sources
  Future<bool> initialize();
  
  /// Clean up repository resources
  Future<void> dispose();
  
  /// Check if the repository is ready for operations
  bool get isReady;
  
  // Entry Management
  
  /// Create a new wellness entry
  /// 
  /// [entry] The entry to create
  /// Returns the created entry with any generated fields
  /// Throws [RepositoryException] if creation fails
  Future<WellnessEntry> createEntry(WellnessEntry entry);
  
  /// Get a wellness entry by ID
  /// 
  /// [id] The unique identifier of the entry
  /// Returns the entry if found, null otherwise
  Future<WellnessEntry?> getEntryById(String id);
  
  /// Get entries with optional filtering and pagination
  /// 
  /// [page] Page number (0-based)
  /// [pageSize] Number of entries per page
  /// [type] Filter by entry type
  /// [startDate] Filter entries after this date
  /// [endDate] Filter entries before this date
  /// [searchQuery] Search in comments and other text fields
  /// Returns a paginated result with entries and metadata
  Future<PaginatedEntries> getEntries({
    int page = 0,
    int pageSize = 20,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  });
  
  /// Get recent entries for quick access
  /// 
  /// [limit] Maximum number of entries to return
  /// [types] Filter by specific entry types
  /// Returns the most recent entries
  Future<List<WellnessEntry>> getRecentEntries({
    int limit = 10,
    List<String>? types,
  });
  
  /// Update an existing wellness entry
  /// 
  /// [entry] The entry with updated data
  /// Returns the updated entry
  /// Throws [RepositoryException] if update fails or entry not found
  Future<WellnessEntry> updateEntry(WellnessEntry entry);
  
  /// Delete a wellness entry
  /// 
  /// [id] The ID of the entry to delete
  /// Returns true if deleted, false if not found
  /// Throws [RepositoryException] if deletion fails
  Future<bool> deleteEntry(String id);
  
  /// Delete multiple entries
  /// 
  /// [ids] List of entry IDs to delete
  /// Returns the number of entries actually deleted
  Future<int> deleteEntries(List<String> ids);
  
  // Statistics and Analytics
  
  /// Get entry count statistics
  /// 
  /// [startDate] Count entries after this date
  /// [endDate] Count entries before this date
  /// [groupBy] Group counts by type, date, etc.
  /// Returns statistics grouped by the specified criterion
  Future<Map<String, int>> getEntryStats({
    DateTime? startDate,
    DateTime? endDate,
    String groupBy = 'type',
  });
  
  /// Get analytics data for a date range
  /// 
  /// [startDate] Start of the analysis period
  /// [endDate] End of the analysis period
  /// [forceRefresh] If true, recalculate instead of using cache
  /// Returns computed analytics data
  Future<AnalyticsData> getAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    bool forceRefresh = false,
  });
  
  /// Get entries for calendar view
  /// 
  /// [month] The month to get entries for
  /// [year] The year to get entries for
  /// Returns entries grouped by date
  Future<Map<DateTime, List<WellnessEntry>>> getCalendarEntries({
    required int month,
    required int year,
  });
  
  // Data Import/Export
  
  /// Import entries from external data
  /// 
  /// [data] The data to import (JSON format)
  /// [source] The source of the data (csv, json, etc.)
  /// [mergeStrategy] How to handle existing entries
  /// Returns import statistics
  Future<ImportResult> importData({
    required List<Map<String, dynamic>> data,
    required String source,
    ImportMergeStrategy mergeStrategy = ImportMergeStrategy.skipExisting,
  });
  
  /// Export entries to external format
  /// 
  /// [startDate] Export entries after this date
  /// [endDate] Export entries before this date
  /// [format] The export format (csv, json)
  /// [includeMetadata] Whether to include metadata
  /// Returns the exported data
  Future<ExportResult> exportData({
    DateTime? startDate,
    DateTime? endDate,
    ExportFormat format = ExportFormat.json,
    bool includeMetadata = true,
  });
  
  // Data Management
  
  /// Perform data cleanup and optimization
  /// 
  /// [removeCorrupted] Remove corrupted entries
  /// [optimizeStorage] Optimize storage space
  /// Returns cleanup statistics
  Future<CleanupResult> performCleanup({
    bool removeCorrupted = true,
    bool optimizeStorage = true,
  });
  
  /// Get repository health and status information
  /// 
  /// Returns information about storage health, data integrity, etc.
  Future<RepositoryHealth> getHealthStatus();
  
  /// Create a backup of all data
  /// 
  /// Returns backup information
  Future<BackupResult> createBackup();
  
  /// Restore data from a backup
  /// 
  /// [backupData] The backup data to restore
  /// [strategy] How to handle existing data
  /// Returns restore statistics
  Future<RestoreResult> restoreFromBackup({
    required Map<String, dynamic> backupData,
    RestoreStrategy strategy = RestoreStrategy.merge,
  });
}

/// Paginated result for entry queries
class PaginatedEntries {
  final List<WellnessEntry> entries;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  
  const PaginatedEntries({
    required this.entries,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
  });
  
  bool get hasNextPage => (currentPage + 1) * pageSize < totalCount;
  bool get hasPreviousPage => currentPage > 0;
  int get totalPages => (totalCount / pageSize).ceil();
}

/// Result of data import operation
class ImportResult {
  final int totalProcessed;
  final int successful;
  final int skipped;
  final int failed;
  final List<String> errors;
  final DateTime timestamp;
  
  const ImportResult({
    required this.totalProcessed,
    required this.successful,
    required this.skipped,
    required this.failed,
    required this.errors,
    required this.timestamp,
  });
  
  bool get hasErrors => failed > 0 || errors.isNotEmpty;
  double get successRate => totalProcessed > 0 ? successful / totalProcessed : 1.0;
}

/// Result of data export operation
class ExportResult {
  final String data;
  final ExportFormat format;
  final int entryCount;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  
  const ExportResult({
    required this.data,
    required this.format,
    required this.entryCount,
    required this.timestamp,
    this.metadata,
  });
}

/// Result of cleanup operation
class CleanupResult {
  final int corruptedRemoved;
  final int duplicatesRemoved;
  final int totalCleaned;
  final bool storageOptimized;
  final DateTime timestamp;
  
  const CleanupResult({
    required this.corruptedRemoved,
    required this.duplicatesRemoved,
    required this.totalCleaned,
    required this.storageOptimized,
    required this.timestamp,
  });
}

/// Repository health information
class RepositoryHealth {
  final bool isHealthy;
  final double dataIntegrityScore;
  final int totalEntries;
  final int corruptedEntries;
  final Map<String, dynamic> storageInfo;
  final List<String> issues;
  final DateTime lastCheck;
  
  const RepositoryHealth({
    required this.isHealthy,
    required this.dataIntegrityScore,
    required this.totalEntries,
    required this.corruptedEntries,
    required this.storageInfo,
    required this.issues,
    required this.lastCheck,
  });
}

/// Result of backup operation
class BackupResult {
  final String backupId;
  final int entryCount;
  final int sizeBytes;
  final DateTime timestamp;
  final String checksum;
  
  const BackupResult({
    required this.backupId,
    required this.entryCount,
    required this.sizeBytes,
    required this.timestamp,
    required this.checksum,
  });
}

/// Result of restore operation
class RestoreResult {
  final int totalEntries;
  final int restored;
  final int skipped;
  final int failed;
  final List<String> errors;
  final DateTime timestamp;
  
  const RestoreResult({
    required this.totalEntries,
    required this.restored,
    required this.skipped,
    required this.failed,
    required this.errors,
    required this.timestamp,
  });
  
  bool get hasErrors => failed > 0 || errors.isNotEmpty;
  double get successRate => totalEntries > 0 ? restored / totalEntries : 1.0;
}

/// Strategy for handling existing entries during import
enum ImportMergeStrategy {
  skipExisting,
  overwriteExisting,
  createDuplicates,
  updateExisting,
}

/// Export format options
enum ExportFormat {
  json,
  csv,
  xlsx,
}

/// Strategy for restoring from backup
enum RestoreStrategy {
  replace,
  merge,
  skipExisting,
}
