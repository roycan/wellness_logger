import '../../domain/entities/wellness_entry.dart';
import '../../domain/entities/analytics_data.dart';

/// Abstract interface for local data storage operations.
/// 
/// This interface defines the contract for all local storage implementations
/// providing a consistent API for data access regardless of the underlying
/// storage technology (Hive, SQLite, etc.).
/// 
/// **AI-Friendly**: Clear interface with documented contracts
/// **Student-Friendly**: Simple CRUD operations with examples
/// **Test-Friendly**: Easy to mock for unit testing
abstract class LocalDataSource {
  /// Initialize the local storage system
  /// 
  /// This method should be called once during app startup to prepare
  /// the storage system for use. Returns true if successful.
  Future<bool> initialize();
  
  /// Close the local storage system and cleanup resources
  Future<void> close();
  
  /// Check if the storage system is ready for operations
  bool get isInitialized;
  
  // CRUD Operations for Wellness Entries
  
  /// Save a wellness entry to local storage
  /// 
  /// [entry] The wellness entry to save
  /// Returns the saved entry with any generated fields (like auto-generated IDs)
  /// Throws [StorageException] if the operation fails
  Future<WellnessEntry> saveEntry(WellnessEntry entry);
  
  /// Retrieve a wellness entry by its unique ID
  /// 
  /// [id] The unique identifier of the entry
  /// Returns the entry if found, null if not found
  /// Throws [StorageException] if the operation fails
  Future<WellnessEntry?> getEntry(String id);
  
  /// Retrieve all wellness entries, optionally filtered
  /// 
  /// [limit] Maximum number of entries to return (default: no limit)
  /// [offset] Number of entries to skip (default: 0)
  /// [type] Filter by entry type (e.g., 'SVT Episode', 'Exercise')
  /// [startDate] Filter entries after this date (inclusive)
  /// [endDate] Filter entries before this date (inclusive)
  /// Returns a list of entries matching the criteria
  Future<List<WellnessEntry>> getEntries({
    int? limit,
    int offset = 0,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Update an existing wellness entry
  /// 
  /// [entry] The entry with updated values
  /// Returns the updated entry
  /// Throws [StorageException] if the entry doesn't exist or update fails
  Future<WellnessEntry> updateEntry(WellnessEntry entry);
  
  /// Delete a wellness entry by ID
  /// 
  /// [id] The unique identifier of the entry to delete
  /// Returns true if the entry was deleted, false if not found
  /// Throws [StorageException] if the operation fails
  Future<bool> deleteEntry(String id);
  
  /// Delete multiple entries by IDs
  /// 
  /// [ids] List of entry IDs to delete
  /// Returns the number of entries actually deleted
  Future<int> deleteEntries(List<String> ids);
  
  /// Get the total count of entries, optionally filtered
  /// 
  /// [type] Filter by entry type
  /// [startDate] Filter entries after this date
  /// [endDate] Filter entries before this date
  /// Returns the count of matching entries
  Future<int> getEntryCount({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  // Bulk Operations
  
  /// Save multiple entries in a single transaction
  /// 
  /// [entries] List of entries to save
  /// Returns the list of saved entries
  /// If any entry fails, the entire operation is rolled back
  Future<List<WellnessEntry>> saveEntries(List<WellnessEntry> entries);
  
  /// Import entries from external data (e.g., CSV, JSON)
  /// 
  /// [entries] List of entries to import
  /// [overwriteExisting] If true, existing entries with same ID are updated
  /// Returns import statistics: {added: count, updated: count, errors: count}
  Future<Map<String, int>> importEntries(
    List<WellnessEntry> entries, {
    bool overwriteExisting = false,
  });
  
  /// Export all entries to a serializable format
  /// 
  /// [startDate] Export entries after this date
  /// [endDate] Export entries before this date
  /// Returns a list of entries in JSON format
  Future<List<Map<String, dynamic>>> exportEntries({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  // Analytics Data Operations
  
  /// Save analytics data to local cache
  /// 
  /// [analytics] The analytics data to cache
  Future<void> saveAnalytics(AnalyticsData analytics);
  
  /// Retrieve cached analytics data
  /// 
  /// [key] The cache key (e.g., date range identifier)
  /// Returns cached analytics if available and not expired
  Future<AnalyticsData?> getAnalytics(String key);
  
  /// Clear analytics cache
  /// 
  /// [olderThan] Clear cache entries older than this date
  Future<void> clearAnalyticsCache({DateTime? olderThan});
  
  // Database Maintenance
  
  /// Perform database maintenance operations
  /// 
  /// This includes cleanup, optimization, and integrity checks
  /// Returns maintenance statistics
  Future<Map<String, dynamic>> performMaintenance();
  
  /// Get storage statistics
  /// 
  /// Returns information about storage usage, entry counts, etc.
  Future<Map<String, dynamic>> getStorageStats();
}
