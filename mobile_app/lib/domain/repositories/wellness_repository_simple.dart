import '../../domain/entities/analytics_data.dart';
import '../../domain/entities/wellness_entry.dart';

/// Simple repository interface for wellness data operations.
/// 
/// This repository provides a clean interface for CRUD operations
/// and basic analytics on wellness entries. It follows the Repository
/// pattern to abstract data access from business logic.
/// 
/// The repository is designed to be:
/// - Simple and focused on core functionality
/// - Easy to test with mock implementations
/// - Extensible for future features
/// - Offline-first with local storage
abstract class WellnessRepository {
  // === LIFECYCLE ===
  
  /// Initializes the repository and sets up storage.
  /// Returns true if initialization was successful.
  Future<bool> initialize();
  
  /// Cleans up resources and closes connections.
  Future<void> dispose();
  
  /// Returns true if the repository is ready for operations.
  bool get isReady;
  
  // === CORE CRUD OPERATIONS ===
  
  /// Creates a new wellness entry.
  /// 
  /// Throws [StorageException] if:
  /// - Entry validation fails
  /// - Storage operation fails
  /// - Entry with same ID already exists
  Future<void> createEntry(WellnessEntry entry);
  
  /// Retrieves a wellness entry by ID.
  /// 
  /// Returns null if no entry is found with the given ID.
  /// Throws [StorageException] if storage operation fails.
  Future<WellnessEntry?> getEntryById(String id);
  
  /// Retrieves all wellness entries with optional filtering.
  /// 
  /// Parameters:
  /// - [startDate]: Filter entries from this date (inclusive)
  /// - [endDate]: Filter entries until this date (inclusive)
  /// - [entryType]: Filter by entry type (e.g., 'svt_episode', 'exercise')
  /// - [limit]: Maximum number of entries to return
  /// - [offset]: Number of entries to skip (for pagination)
  /// 
  /// Returns a list of entries matching the criteria.
  /// Throws [StorageException] if storage operation fails.
  Future<List<WellnessEntry>> getAllEntries({
    DateTime? startDate,
    DateTime? endDate,
    String? entryType,
    int? limit,
    int? offset,
  });
  
  /// Updates an existing wellness entry.
  /// 
  /// Throws [StorageException] if:
  /// - Entry validation fails
  /// - Storage operation fails
  /// - Entry with the given ID is not found
  Future<void> updateEntry(WellnessEntry entry);
  
  /// Deletes a wellness entry by ID.
  /// 
  /// Returns true if the entry was found and deleted, false if not found.
  /// Throws [StorageException] if storage operation fails.
  Future<bool> deleteEntry(String id);
  
  /// Deletes multiple entries by their IDs.
  /// 
  /// Returns the number of entries successfully deleted.
  /// Throws [StorageException] if storage operation fails.
  Future<int> deleteEntries(List<String> ids);
  
  /// Gets the total count of entries with optional filtering.
  /// 
  /// Parameters match [getAllEntries] but only returns the count.
  /// Throws [StorageException] if storage operation fails.
  Future<int> getEntryCount({
    DateTime? startDate,
    DateTime? endDate,
    String? entryType,
  });
  
  // === ANALYTICS OPERATIONS ===
  
  /// Retrieves analytics data for the specified date range.
  /// 
  /// If no date range is specified, returns analytics for all entries.
  /// Throws [StorageException] if calculation fails.
  Future<AnalyticsData> getAnalyticsData({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Calculates entry streaks for different entry types.
  /// 
  /// Returns a map where keys are entry types and values are streak counts.
  /// Throws [StorageException] if calculation fails.
  Future<Map<String, int>> getEntryStreaks();
  
  /// Gets entry statistics grouped by type.
  /// 
  /// Returns a map where keys are entry types and values are counts.
  /// Optionally filtered by date range.
  /// Throws [StorageException] if calculation fails.
  Future<Map<String, int>> getEntryStats({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  // === IMPORT/EXPORT OPERATIONS ===
  
  /// Imports wellness entries from JSON data.
  /// 
  /// The JSON should contain an 'entries' array with wellness entry objects.
  /// Existing entries with the same IDs will be updated.
  /// Throws [StorageException] if import fails or data is invalid.
  Future<void> importFromJson(Map<String, dynamic> jsonData);
  
  /// Imports wellness entries from CSV data.
  /// 
  /// The CSV should have headers matching the entry fields.
  /// Throws [StorageException] if import fails or data is invalid.
  Future<void> importFromCsv(String csvData);
  
  /// Exports wellness entries to JSON format.
  /// 
  /// Parameters allow filtering which entries to export.
  /// Returns a JSON object with metadata and entry array.
  /// Throws [StorageException] if export fails.
  Future<Map<String, dynamic>> exportToJson({
    DateTime? startDate,
    DateTime? endDate,
    String? entryType,
  });
  
  /// Exports wellness entries to CSV format.
  /// 
  /// Parameters allow filtering which entries to export.
  /// Returns a CSV string with headers and entry data.
  /// Throws [StorageException] if export fails.
  Future<String> exportToCsv({
    DateTime? startDate,
    DateTime? endDate,
    String? entryType,
  });
  
  // === MAINTENANCE OPERATIONS ===
  
  /// Clears all wellness entries from storage.
  /// 
  /// This operation cannot be undone.
  /// Throws [StorageException] if operation fails.
  Future<void> clearAllEntries();
  
  /// Gets information about the storage backend.
  /// 
  /// Returns a map with storage statistics and metadata.
  /// Throws [StorageException] if operation fails.
  Future<Map<String, dynamic>> getStorageInfo();
}
