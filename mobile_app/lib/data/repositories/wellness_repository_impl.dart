import 'package:flutter/foundation.dart';

import '../../domain/entities/analytics_data.dart';
import '../../domain/entities/wellness_entry.dart';
import '../../domain/entities/svt_episode.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/repositories/wellness_repository_simple.dart';
import '../datasources/local_data_source.dart';
import '../datasources/storage_exception.dart';

/// Implementation of [WellnessRepositorySimple] using local data source.
/// 
/// This repository acts as a bridge between the domain layer and data layer,
/// providing business logic validation and error handling on top of the
/// raw data operations.
class WellnessRepositoryImpl implements WellnessRepositorySimple {
  final LocalDataSource _localDataSource;
  bool _isInitialized = false;

  WellnessRepositoryImpl({
    required LocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<bool> initialize() async {
    try {
      // Initialize the local data source
      final result = await _localDataSource.initialize();
      if (result) {
        _isInitialized = true;
        debugPrint('WellnessRepository initialized successfully');
        return true;
      } else {
        _isInitialized = false;
        debugPrint('Failed to initialize WellnessRepository: LocalDataSource initialization failed');
        return false;
      }
    } catch (e) {
      _isInitialized = false;
      debugPrint('Failed to initialize WellnessRepository: $e');
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      _isInitialized = false;
      debugPrint('WellnessRepository disposed');
    } catch (e) {
      debugPrint('Error disposing WellnessRepository: $e');
    }
  }

  @override
  bool get isReady => _isInitialized;

  @override
  Future<void> createEntry(WellnessEntry entry) async {
    _ensureInitialized();
    
    try {
      // Validate entry before saving
      _validateEntry(entry);
      
      await _localDataSource.saveEntry(entry);
      
      debugPrint('Successfully created entry: ${entry.id}');
    } on StorageException {
      // Re-throw storage exceptions as-is
      rethrow;
    } catch (e) {
      // Wrap unexpected errors in StorageException
      throw StorageException.operationFailed(
        'create entry',
        originalError: e,
      );
    }
  }

  @override
  Future<WellnessEntry?> getEntryById(String id) async {
    _ensureInitialized();
    
    try {
      if (id.isEmpty) {
        throw StorageException.invalidData('Entry ID cannot be empty');
      }

      return await _localDataSource.getEntry(id);
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException.operationFailed(
        'get entry by ID',
        originalError: e,
      );
    }
  }

  @override
  Future<List<WellnessEntry>> getAllEntries({
    DateTime? startDate,
    DateTime? endDate,
    String? entryType,
    int? limit,
    int? offset,
  }) async {
    _ensureInitialized();
    
    try {
      // Validate parameters
      _validateDateRange(startDate, endDate);
      _validatePaginationParams(limit, offset);

      return await _localDataSource.getEntries(
        startDate: startDate,
        endDate: endDate,
        type: entryType,
        limit: limit,
        offset: offset ?? 0,
      );
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException.operationFailed(
        'get all entries',
        originalError: e,
      );
    }
  }

  @override
  Future<void> updateEntry(WellnessEntry entry) async {
    _ensureInitialized();
    
    try {
      // Validate entry before updating
      _validateEntry(entry);

      // Check if entry exists
      final existingEntry = await _localDataSource.getEntry(entry.id);
      if (existingEntry == null) {
        throw StorageException.entryNotFound(entry.id);
      }

      await _localDataSource.updateEntry(entry);
      
      debugPrint('Successfully updated entry: ${entry.id}');
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException.operationFailed(
        'update entry',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> deleteEntry(String id) async {
    _ensureInitialized();
    
    try {
      if (id.isEmpty) {
        throw StorageException.invalidData('Entry ID cannot be empty');
      }

      // Check if entry exists before deletion
      final existingEntry = await _localDataSource.getEntry(id);
      if (existingEntry == null) {
        return false; // Entry doesn't exist
      }

      await _localDataSource.deleteEntry(id);
      
      debugPrint('Successfully deleted entry: $id');
      return true;
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException.operationFailed(
        'delete entry',
        originalError: e,
      );
    }
  }

  @override
  Future<int> deleteEntries(List<String> ids) async {
    _ensureInitialized();
    
    try {
      if (ids.isEmpty) {
        return 0;
      }

      int deletedCount = 0;
      for (final id in ids) {
        try {
          final success = await deleteEntry(id);
          if (success) deletedCount++;
        } catch (e) {
          // Continue with other deletions even if one fails
          debugPrint('Failed to delete entry $id: $e');
        }
      }

      debugPrint('Successfully deleted $deletedCount out of ${ids.length} entries');
      return deletedCount;
    } catch (e) {
      throw StorageException.operationFailed(
        'delete multiple entries',
        originalError: e,
      );
    }
  }

  @override
  Future<int> getEntryCount({
    DateTime? startDate,
    DateTime? endDate,
    String? entryType,
  }) async {
    _ensureInitialized();
    
    try {
      _validateDateRange(startDate, endDate);

      return await _localDataSource.getEntryCount(
        startDate: startDate,
        endDate: endDate,
        type: entryType,
      );
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException.operationFailed(
        'get entry count',
        originalError: e,
      );
    }
  }

  @override
  Future<AnalyticsData> getAnalyticsData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _ensureInitialized();
    
    try {
      _validateDateRange(startDate, endDate);

      // Get all entries in the date range
      final entries = await _localDataSource.getEntries(
        startDate: startDate,
        endDate: endDate,
      );

      // Calculate basic analytics
      return _calculateAnalytics(entries, startDate, endDate);
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException.operationFailed(
        'get analytics data',
        originalError: e,
      );
    }
  }

  @override
  Future<Map<String, int>> getEntryStreaks() async {
    _ensureInitialized();
    
    try {
      final entries = await _localDataSource.getEntries();
      return _calculateStreaks(entries);
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException.operationFailed(
        'get entry streaks',
        originalError: e,
      );
    }
  }

  @override
  Future<Map<String, int>> getEntryStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _ensureInitialized();
    
    try {
      _validateDateRange(startDate, endDate);

      final entries = await _localDataSource.getEntries(
        startDate: startDate,
        endDate: endDate,
      );

      // Group by entry type and count
      final stats = <String, int>{};
      for (final entry in entries) {
        final type = entry.runtimeType.toString().toLowerCase();
        stats[type] = (stats[type] ?? 0) + 1;
      }

      return stats;
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException.operationFailed(
        'get entry statistics',
        originalError: e,
      );
    }
  }

  @override
  Future<void> importFromJson(Map<String, dynamic> jsonData) async {
    _ensureInitialized();
    
    try {
      if (jsonData.isEmpty) {
        throw StorageException.invalidData('JSON data cannot be empty');
      }

      // Validate JSON structure
      _validateImportData(jsonData);

      // Parse entries from JSON
      final entriesJson = jsonData['entries'] as List<dynamic>?;
      if (entriesJson == null || entriesJson.isEmpty) {
        throw StorageException.invalidData('No entries found in JSON data');
      }

      final entries = entriesJson
          .map((json) => WellnessEntry.fromJson(json as Map<String, dynamic>))
          .toList();

      // Import entries using LocalDataSource
      await _localDataSource.importEntries(entries, overwriteExisting: true);
      
      debugPrint('Successfully imported ${entries.length} entries from JSON');
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException.importFailed(
        'Failed to import from JSON: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<void> importFromCsv(String csvData) async {
    _ensureInitialized();
    
    try {
      if (csvData.trim().isEmpty) {
        throw StorageException.invalidData('CSV data cannot be empty');
      }

      // Parse CSV data into WellnessEntry objects
      final entries = _parseCsvData(csvData);
      
      if (entries.isEmpty) {
        throw StorageException.invalidData('No valid entries found in CSV data');
      }

      // Import entries using LocalDataSource
      await _localDataSource.importEntries(entries, overwriteExisting: true);
      
      debugPrint('Successfully imported ${entries.length} entries from CSV');
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException.importFailed(
        'Failed to import from CSV: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> exportToJson({
    DateTime? startDate,
    DateTime? endDate,
    String? entryType,
  }) async {
    _ensureInitialized();
    
    try {
      _validateDateRange(startDate, endDate);

      final entries = await _localDataSource.getEntries(
        startDate: startDate,
        endDate: endDate,
        type: entryType,
      );

      final exportData = {
        'version': '1.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'totalEntries': entries.length,
        'entries': entries.map((e) => e.toJson()).toList(),
      };

      debugPrint('Successfully exported ${entries.length} entries to JSON');
      
      return exportData;
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException.exportFailed(
        'Failed to export to JSON: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<String> exportToCsv({
    DateTime? startDate,
    DateTime? endDate,
    String? entryType,
  }) async {
    _ensureInitialized();
    
    try {
      _validateDateRange(startDate, endDate);

      final entries = await _localDataSource.getEntries(
        startDate: startDate,
        endDate: endDate,
        type: entryType,
      );

      // Generate CSV string from entries
      final csvData = _generateCsvData(entries);
      
      debugPrint('Successfully exported ${entries.length} entries to CSV');
      
      return csvData;
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException.exportFailed(
        'Failed to export to CSV: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<void> clearAllEntries() async {
    _ensureInitialized();
    
    try {
      // Get all entries to get their IDs
      final entries = await _localDataSource.getEntries();
      
      if (entries.isNotEmpty) {
        final entryIds = entries.map((entry) => entry.id).toList();
        await _localDataSource.deleteEntries(entryIds);
      }
      
      debugPrint('Successfully cleared ${entries.length} entries');
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException.operationFailed(
        'clear all entries',
        originalError: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getStorageInfo() async {
    _ensureInitialized();
    
    try {
      final storageStats = await _localDataSource.getStorageStats();
      
      return {
        ...storageStats,
        'isInitialized': _isInitialized,
        'lastAccessed': DateTime.now().toIso8601String(),
      };
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException.operationFailed(
        'get storage info',
        originalError: e,
      );
    }
  }

  // === PRIVATE HELPER METHODS ===

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StorageException.operationFailed(
        'Repository not initialized. Call initialize() first.',
      );
    }
  }

  void _validateEntry(WellnessEntry entry) {
    if (entry.id.isEmpty) {
      throw StorageException.invalidData('Entry ID cannot be empty');
    }

    if (entry.timestamp.isAfter(DateTime.now())) {
      throw StorageException.invalidData(
        'Entry timestamp cannot be in the future',
      );
    }
  }

  void _validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      if (startDate.isAfter(endDate)) {
        throw StorageException.invalidData(
          'Start date cannot be after end date',
        );
      }
    }
  }

  void _validatePaginationParams(int? limit, int? offset) {
    if (limit != null && limit <= 0) {
      throw StorageException.invalidData('Limit must be greater than 0');
    }

    if (offset != null && offset < 0) {
      throw StorageException.invalidData('Offset cannot be negative');
    }
  }

  void _validateImportData(Map<String, dynamic> jsonData) {
    if (!jsonData.containsKey('entries')) {
      throw StorageException.invalidData(
        'Import data must contain "entries" field',
      );
    }

    final entries = jsonData['entries'];
    if (entries is! List) {
      throw StorageException.invalidData('Entries field must be a list');
    }

    // Validate each entry has required fields
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (entry is! Map<String, dynamic>) {
        throw StorageException.invalidData(
          'Entry at index $i must be a JSON object',
        );
      }

      // Check for required fields
      final requiredFields = ['id', 'timestamp', 'type'];
      for (final field in requiredFields) {
        if (!entry.containsKey(field) || entry[field] == null) {
          throw StorageException.invalidData(
            'Entry at index $i missing required field: $field',
          );
        }
      }
    }

    debugPrint('Import data validation passed for ${entries.length} entries');
  }

  AnalyticsData _calculateAnalytics(
    List<WellnessEntry> entries,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final now = DateTime.now();
    final effectiveStartDate = startDate ?? (entries.isNotEmpty ? 
        entries.map((e) => e.timestamp).reduce((a, b) => a.isBefore(b) ? a : b) : now);
    final effectiveEndDate = endDate ?? now;
    
    // Calculate week and month boundaries
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    
    // Initialize counters
    int totalSvtEpisodes = 0;
    int episodesThisWeek = 0;
    int episodesThisMonth = 0;
    double totalSvtDuration = 0;
    
    int totalExercise = 0;
    int exerciseThisWeek = 0;
    int exerciseThisMonth = 0;
    double totalExerciseDuration = 0;
    
    int totalMedication = 0;
    int medicationThisWeek = 0;
    int medicationThisMonth = 0;
    
    final svtTriggers = <String, int>{};
    final exerciseTypes = <String, int>{};
    final insights = <String>[];
    
    // Process entries
    for (final entry in entries) {
      final type = entry.type.toLowerCase();
      
      switch (type) {
        case 'svt_episode':
        case 'svt episode':
          totalSvtEpisodes++;
          if (entry.timestamp.isAfter(oneWeekAgo)) episodesThisWeek++;
          if (entry.timestamp.isAfter(oneMonthAgo)) episodesThisMonth++;
          
          // Try to extract duration from SVT episode if it's actually an SvtEpisode
          if (entry is SvtEpisode && entry.duration != null) {
            // Parse duration string like "15 minutes" to seconds
            final durationStr = entry.duration!.toLowerCase();
            if (durationStr.contains('minute')) {
              final minutes = int.tryParse(durationStr.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
              totalSvtDuration += minutes * 60.0;
            } else if (durationStr.contains('second')) {
              final seconds = int.tryParse(durationStr.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
              totalSvtDuration += seconds.toDouble();
            }
          }
          
          // Extract triggers from comments if available
          if (entry.comments != null) {
            final comments = entry.comments!.toLowerCase();
            if (comments.contains('stress')) svtTriggers['stress'] = (svtTriggers['stress'] ?? 0) + 1;
            if (comments.contains('caffeine')) svtTriggers['caffeine'] = (svtTriggers['caffeine'] ?? 0) + 1;
            if (comments.contains('exercise')) svtTriggers['exercise'] = (svtTriggers['exercise'] ?? 0) + 1;
          }
          break;
          
        case 'exercise':
          totalExercise++;
          if (entry.timestamp.isAfter(oneWeekAgo)) exerciseThisWeek++;
          if (entry.timestamp.isAfter(oneMonthAgo)) exerciseThisMonth++;
          
          // Try to extract duration from Exercise if it's actually an Exercise
          if (entry is Exercise && entry.duration != null) {
            final durationStr = entry.duration!.toLowerCase();
            if (durationStr.contains('minute')) {
              final minutes = int.tryParse(durationStr.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
              totalExerciseDuration += minutes * 60.0;
            } else if (durationStr.contains('hour')) {
              final hours = int.tryParse(durationStr.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
              totalExerciseDuration += hours * 3600.0;
            }
          }
          
          // Extract exercise type from comments
          if (entry.comments != null) {
            final comments = entry.comments!.toLowerCase();
            if (comments.contains('running')) {
              exerciseTypes['running'] = (exerciseTypes['running'] ?? 0) + 1;
            } else if (comments.contains('walking')) {
              exerciseTypes['walking'] = (exerciseTypes['walking'] ?? 0) + 1;
            } else if (comments.contains('cycling')) {
              exerciseTypes['cycling'] = (exerciseTypes['cycling'] ?? 0) + 1;
            } else {
              exerciseTypes['other'] = (exerciseTypes['other'] ?? 0) + 1;
            }
          }
          break;
          
        case 'medication':
          totalMedication++;
          if (entry.timestamp.isAfter(oneWeekAgo)) medicationThisWeek++;
          if (entry.timestamp.isAfter(oneMonthAgo)) medicationThisMonth++;
          break;
      }
    }
    
    // Calculate averages
    final avgSvtDuration = totalSvtEpisodes > 0 ? 
        totalSvtDuration / totalSvtEpisodes : 0.0;
    final avgExerciseDuration = totalExercise > 0 ?
        totalExerciseDuration / totalExercise : 0.0;
    
    // Calculate adherence rate (simplified)
    final adherenceRate = entries.isNotEmpty ? 
        (medicationThisMonth / 30.0).clamp(0.0, 1.0) : 0.0;
    
    // Calculate data completeness
    final dataCompleteness = entries.isNotEmpty ? 1.0 : 0.0;
    
    // Generate insights
    if (totalSvtEpisodes > 0) {
      insights.add('You had $totalSvtEpisodes SVT episodes in the selected period');
    }
    if (totalExercise > 0) {
      insights.add('You exercised $totalExercise times');
    }
    if (episodesThisWeek > episodesThisMonth - episodesThisWeek) {
      insights.add('SVT episodes increased this week');
    }
    
    return AnalyticsData(
      startDate: effectiveStartDate,
      endDate: effectiveEndDate,
      totalSvtEpisodes: totalSvtEpisodes,
      averageEpisodeDuration: avgSvtDuration,
      episodesThisWeek: episodesThisWeek,
      episodesThisMonth: episodesThisMonth,
      totalExerciseSessions: totalExercise,
      averageExerciseDuration: avgExerciseDuration,
      exerciseSessionsThisWeek: exerciseThisWeek,
      exerciseSessionsThisMonth: exerciseThisMonth,
      totalMedicationTaken: totalMedication,
      medicationTakenThisWeek: medicationThisWeek,
      medicationTakenThisMonth: medicationThisMonth,
      adherenceRate: adherenceRate,
      svtTriggerPatterns: svtTriggers,
      exerciseTypeFrequency: exerciseTypes,
      insights: insights,
      totalEntries: entries.length,
      dataCompleteness: dataCompleteness,
      lastUpdated: now,
    );
  }

  Map<String, int> _calculateStreaks(List<WellnessEntry> entries) {
    final streaks = <String, int>{};
    
    // Group entries by type and date
    final entriesByType = <String, List<DateTime>>{};
    
    for (final entry in entries) {
      final type = entry.runtimeType.toString().toLowerCase();
      final date = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      
      entriesByType.putIfAbsent(type, () => []).add(date);
    }

    // Calculate streaks for each type
    for (final entry in entriesByType.entries) {
      final type = entry.key;
      final dates = entry.value.toSet().toList()..sort();
      
      int currentStreak = 0;
      int maxStreak = 0;
      DateTime? previousDate;
      
      for (final date in dates) {
        if (previousDate == null || 
            date.difference(previousDate).inDays == 1) {
          currentStreak++;
          maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
        } else {
          currentStreak = 1;
        }
        previousDate = date;
      }
      
      streaks[type] = maxStreak;
    }

    return streaks;
  }

  /// Parses CSV data into a list of WellnessEntry objects
  List<WellnessEntry> _parseCsvData(String csvData) {
    final entries = <WellnessEntry>[];
    final lines = csvData.split('\n');
    
    if (lines.isEmpty) return entries;
    
    // Get headers from first line
    final headers = lines.first.split(',').map((h) => h.trim()).toList();
    
    // Process data lines
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      try {
        final values = line.split(',').map((v) => v.trim()).toList();
        if (values.length >= headers.length) {
          // Create a map from headers and values
          final entryData = <String, dynamic>{};
          for (int j = 0; j < headers.length; j++) {
            entryData[headers[j]] = values[j];
          }
          
          // Convert to WellnessEntry
          final entry = WellnessEntry.fromJson(entryData);
          entries.add(entry);
        }
      } catch (e) {
        debugPrint('Error parsing CSV line $i: $e');
        // Continue with other lines
      }
    }
    
    return entries;
  }

  /// Generates CSV data from a list of WellnessEntry objects
  String _generateCsvData(List<WellnessEntry> entries) {
    if (entries.isEmpty) return '';
    
    final buffer = StringBuffer();
    
    // Write headers
    final headers = [
      'id', 'timestamp', 'type', 'comments', 'duration',
    ];
    buffer.writeln(headers.join(','));
    
    // Write entry data
    for (final entry in entries) {
      final values = [
        _escapeCsvValue(entry.id),
        _escapeCsvValue(entry.timestamp.toIso8601String()),
        _escapeCsvValue(entry.type),
        _escapeCsvValue(entry.comments ?? ''),
        _escapeCsvValue(_extractDuration(entry)),
      ];
      buffer.writeln(values.join(','));
    }
    
    return buffer.toString();
  }

  /// Extracts duration information from specific entry types
  String _extractDuration(WellnessEntry entry) {
    if (entry is SvtEpisode && entry.duration != null) {
      return entry.duration!;
    } else if (entry is Exercise && entry.duration != null) {
      return entry.duration!;
    }
    return '';
  }

  /// Escapes CSV values to handle commas, quotes, and newlines
  String _escapeCsvValue(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
