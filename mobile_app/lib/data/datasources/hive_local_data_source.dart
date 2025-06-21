import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/wellness_entry.dart';
import '../../domain/entities/analytics_data.dart';
import '../../core/constants/app_constants.dart';
import 'local_data_source.dart';
import 'storage_exception.dart';

/// Hive implementation of local data storage.
/// 
/// This implementation uses Hive for local data persistence, providing
/// fast NoSQL storage with excellent Flutter integration.
/// 
/// **AI-Friendly**: Well-structured with clear error handling
/// **Student-Friendly**: Simple to understand with good documentation
/// **Test-Friendly**: Easy to mock and test in isolation
class HiveLocalDataSource implements LocalDataSource {
  static const String _entriesBoxName = AppConstants.entriesBoxName;
  static const String _analyticsBoxName = AppConstants.analyticsBoxName;
  static const String _metadataBoxName = 'metadata';
  
  final Logger _logger = Logger();
  final String? _testDirectory;
  
  Box<Map<dynamic, dynamic>>? _entriesBox;
  Box<Map<dynamic, dynamic>>? _analyticsBox;
  Box<Map<dynamic, dynamic>>? _metadataBox;
  
  bool _isInitialized = false;
  
  /// Creates a new HiveLocalDataSource.
  /// 
  /// [testDirectory] - Optional directory path for testing.
  /// If provided, Hive will be initialized with this path instead of using
  /// the default application documents directory.
  HiveLocalDataSource({String? testDirectory}) : _testDirectory = testDirectory;
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  Future<bool> initialize() async {
    try {
      _logger.i('🔄 Initializing Hive local data source...');
      
      // For production, always use Flutter's document directory
      // Note: Hive.initFlutter() is safe to call multiple times
      if (_testDirectory != null) {
        // For testing, use the provided directory
        Hive.init(_testDirectory!);
      } else {
        // For production, use Flutter's document directory
        await Hive.initFlutter();
      }
      
      _logger.i('📂 Hive initialized, opening boxes...');
      
      // Open the boxes for data storage
      _entriesBox = await Hive.openBox<Map<dynamic, dynamic>>(_entriesBoxName);
      _analyticsBox = await Hive.openBox<Map<dynamic, dynamic>>(_analyticsBoxName);
      _metadataBox = await Hive.openBox<Map<dynamic, dynamic>>(_metadataBoxName);
      
      _logger.i('📦 Opened Hive boxes: entries=${_entriesBox!.length}, analytics=${_analyticsBox!.length}');
      
      _isInitialized = true;
      
      // Perform initial data integrity check
      await _performIntegrityCheck();
      
      _logger.i('✅ Hive local data source initialized successfully');
      return true;
    } catch (error, stackTrace) {
      _logger.e('Failed to initialize Hive local data source: $error', stackTrace: stackTrace);
      _isInitialized = false;
      throw StorageException.initializationFailed(error.toString());
    }
  }
  
  @override
  Future<void> close() async {
    try {
      await _entriesBox?.close();
      await _analyticsBox?.close();
      await _metadataBox?.close();
      
      _entriesBox = null;
      _analyticsBox = null;
      _metadataBox = null;
      _isInitialized = false;
      
      _logger.i('Hive local data source closed');
    } catch (error) {
      _logger.w('Error closing Hive local data source: $error');
    }
  }
  
  void _ensureInitialized() {
    if (!_isInitialized || _entriesBox == null) {
      throw StorageException.initializationFailed('Data source not initialized');
    }
  }
  
  @override
  Future<WellnessEntry> saveEntry(WellnessEntry entry) async {
    _ensureInitialized();
    
    try {
      final json = entry.toJson();
      
      // DEBUG: Log before saving
      debugPrint('🔍 DATASOURCE: About to save entry ${entry.id} to Hive box');
      debugPrint('🔍 DATASOURCE: Box has ${_entriesBox!.length} entries before save');
      
      await _entriesBox!.put(entry.id, json);
      
      // CRITICAL: Ensure data is flushed to disk immediately
      await _entriesBox!.flush();
      
      // DEBUG: Log after saving and flushing
      debugPrint('🔍 DATASOURCE: Saved and flushed. Box now has ${_entriesBox!.length} entries');
      debugPrint('🔍 DATASOURCE: Verifying save by reading back entry ${entry.id}');
      
      // Immediate verification - try to read it back
      final verification = _entriesBox!.get(entry.id);
      if (verification != null) {
        debugPrint('✅ DATASOURCE: VERIFIED - Entry ${entry.id} is readable from box');
      } else {
        debugPrint('❌ DATASOURCE: CRITICAL ERROR - Entry ${entry.id} NOT found in box after save!');
      }
      
      // Update metadata
      await _updateMetadata('lastSave', DateTime.now().toIso8601String());
      await _incrementCounter('totalEntries');
      
      // Flush metadata box too
      await _metadataBox!.flush();
      
      _logger.i('✅ SAVED AND FLUSHED entry: ${entry.id} (${entry.type})');
      return entry;
    } catch (error) {
      _logger.e('❌ Failed to save entry ${entry.id}: $error');
      throw StorageException.saveFailed(entry.id, error);
    }
  }
  
  @override
  Future<WellnessEntry?> getEntry(String id) async {
    _ensureInitialized();
    
    try {
      final jsonMap = _entriesBox!.get(id);
      if (jsonMap == null) {
        return null;
      }
      
      // CRITICAL FIX: Handle both Map<dynamic, dynamic> and Map<String, dynamic>
      Map<String, dynamic> json;
      try {
        if (jsonMap is Map<String, dynamic>) {
          json = jsonMap;
        } else if (jsonMap is Map) {
          // More defensive conversion for any Map type
          json = <String, dynamic>{};
          jsonMap.forEach((key, value) {
            json[key.toString()] = value;
          });
        } else {
          throw Exception('Unexpected data type: ${jsonMap.runtimeType}');
        }
      } catch (conversionError) {
        _logger.e('Type conversion failed for entry $id: $conversionError');
        throw conversionError;
      }
      
      return WellnessEntry.fromJson(json);
    } catch (error) {
      _logger.e('Failed to get entry $id: $error');
      throw StorageException.readFailed(id, error);
    }
  }
  
  @override
  Future<List<WellnessEntry>> getEntries({
    int? limit,
    int offset = 0,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _ensureInitialized();
    
    // DEBUG: Comprehensive logging on app start
    debugPrint('🔍 DATASOURCE: === LOADING ENTRIES FROM HIVE ===');
    debugPrint('🔍 DATASOURCE: Box is open: ${_entriesBox!.isOpen}');
    debugPrint('🔍 DATASOURCE: Box length: ${_entriesBox!.length}');
    debugPrint('🔍 DATASOURCE: Box keys: ${_entriesBox!.keys.toList()}');
    debugPrint('🔍 DATASOURCE: Box path: ${_entriesBox!.path}');
    
    _logger.i('🔍 Loading entries from Hive box (total: ${_entriesBox!.length})');
    
    try {
      final allEntries = <WellnessEntry>[];
      
      // Get all entries from Hive
      int index = 0;
      for (final jsonMap in _entriesBox!.values) {
        try {
          debugPrint('🔍 DATASOURCE: Processing entry $index: ${jsonMap.toString().substring(0, 50)}...');
          
          // CRITICAL FIX: Handle both Map<dynamic, dynamic> and Map<String, dynamic>
          Map<String, dynamic> json;
          try {
            if (jsonMap is Map<String, dynamic>) {
              json = jsonMap;
            } else if (jsonMap is Map) {
              // More defensive conversion for any Map type
              json = <String, dynamic>{};
              jsonMap.forEach((key, value) {
                json[key.toString()] = value;
              });
            } else {
              throw Exception('Unexpected data type: ${jsonMap.runtimeType}');
            }
          } catch (conversionError) {
            debugPrint('❌ DATASOURCE: Type conversion failed for entry: $conversionError');
            throw conversionError;
          }
          
          final entry = WellnessEntry.fromJson(json);
          
          // Apply filters
          if (type != null && entry.type != type) continue;
          
          if (startDate != null && entry.timestamp.isBefore(startDate)) continue;
          
          if (endDate != null && entry.timestamp.isAfter(endDate)) continue;
          
          allEntries.add(entry);
          debugPrint('✅ DATASOURCE: Successfully loaded entry ${entry.id} (${entry.type})');
        } catch (error) {
          _logger.w('Skipping corrupted entry: $error');
          debugPrint('❌ DATASOURCE: Corrupted entry at index $index: $error');
        }
        index++;
      }
      
      // Sort by timestamp (newest first)
      allEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Apply offset and limit
      final startIndex = offset.clamp(0, allEntries.length);
      final endIndex = limit != null 
          ? (startIndex + limit).clamp(0, allEntries.length)
          : allEntries.length;

      final result = allEntries.sublist(startIndex, endIndex);
      debugPrint('🔍 DATASOURCE: Returning ${result.length} entries after filtering');
      
      return result;
    } catch (error) {
      _logger.e('Failed to get entries: $error');
      debugPrint('❌ DATASOURCE: CRITICAL ERROR loading entries: $error');
      throw StorageException.readFailed('entries_query', error);
    }
  }
  
  @override
  Future<WellnessEntry> updateEntry(WellnessEntry entry) async {
    _ensureInitialized();
    
    try {
      // Check if entry exists
      if (!_entriesBox!.containsKey(entry.id)) {
        throw StorageException.updateFailed(
          entry.id, 
          'Entry not found',
        );
      }
      
      final json = entry.toJson();
      await _entriesBox!.put(entry.id, json);
      
      // Update metadata
      await _updateMetadata('lastUpdate', DateTime.now().toIso8601String());
      
      _logger.d('Updated entry: ${entry.id}');
      return entry;
    } catch (error) {
      _logger.e('Failed to update entry ${entry.id}: $error');
      throw StorageException.updateFailed(entry.id, error);
    }
  }
  
  @override
  Future<bool> deleteEntry(String id) async {
    _ensureInitialized();
    
    try {
      final existed = _entriesBox!.containsKey(id);
      if (existed) {
        await _entriesBox!.delete(id);
        await _updateMetadata('lastDelete', DateTime.now().toIso8601String());
        await _decrementCounter('totalEntries');
        _logger.d('Deleted entry: $id');
      }
      return existed;
    } catch (error) {
      _logger.e('Failed to delete entry $id: $error');
      throw StorageException.deleteFailed(id, error);
    }
  }
  
  @override
  Future<int> deleteEntries(List<String> ids) async {
    _ensureInitialized();
    
    int deletedCount = 0;
    
    try {
      for (final id in ids) {
        if (_entriesBox!.containsKey(id)) {
          await _entriesBox!.delete(id);
          deletedCount++;
        }
      }
      
      if (deletedCount > 0) {
        await _updateMetadata('lastBulkDelete', DateTime.now().toIso8601String());
        await _decrementCounter('totalEntries', deletedCount);
      }
      
      _logger.d('Deleted $deletedCount out of ${ids.length} entries');
      return deletedCount;
    } catch (error) {
      _logger.e('Failed to delete entries: $error');
      throw StorageException.bulkOperationFailed(
        'delete entries',
        error,
      );
    }
  }
  
  @override
  Future<int> getEntryCount({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _ensureInitialized();
    
    try {
      int count = 0;
      
      for (final jsonMap in _entriesBox!.values) {
        try {
          final json = Map<String, dynamic>.from(jsonMap);
          final entryType = json['type'] as String?;
          final timestampStr = json['timestamp'] as String?;
          
          if (type != null && entryType != type) continue;
          
          if (timestampStr != null && (startDate != null || endDate != null)) {
            final timestamp = DateTime.parse(timestampStr);
            if (startDate != null && timestamp.isBefore(startDate)) continue;
            if (endDate != null && timestamp.isAfter(endDate)) continue;
          }
          
          count++;
        } catch (error) {
          _logger.w('Skipping corrupted entry in count: $error');
        }
      }
      
      return count;
    } catch (error) {
      _logger.e('Failed to count entries: $error');
      throw StorageException.readFailed('entry_count', error);
    }
  }
  
  @override
  Future<List<WellnessEntry>> saveEntries(List<WellnessEntry> entries) async {
    _ensureInitialized();
    
    final savedEntries = <WellnessEntry>[];
    
    try {
      // Use batch operation for better performance
      final batch = <String, Map<String, dynamic>>{};
      
      for (final entry in entries) {
        batch[entry.id] = entry.toJson();
      }
      
      await _entriesBox!.putAll(batch);
      savedEntries.addAll(entries);
      
      // Update metadata
      await _updateMetadata('lastBulkSave', DateTime.now().toIso8601String());
      await _incrementCounter('totalEntries', entries.length);
      
      _logger.d('Saved ${entries.length} entries in batch');
      return savedEntries;
    } catch (error) {
      _logger.e('Failed to save entries batch: $error');
      throw StorageException.bulkOperationFailed(
        'save entries batch',
        error,
      );
    }
  }
  
  @override
  Future<Map<String, int>> importEntries(
    List<WellnessEntry> entries, {
    bool overwriteExisting = false,
  }) async {
    _ensureInitialized();
    
    int addedCount = 0;
    int updatedCount = 0;
    int errorCount = 0;
    
    try {
      for (final entry in entries) {
        try {
          final exists = _entriesBox!.containsKey(entry.id);
          
          if (exists && !overwriteExisting) {
            errorCount++;
            continue;
          }
          
          await _entriesBox!.put(entry.id, entry.toJson());
          
          if (exists) {
            updatedCount++;
          } else {
            addedCount++;
          }
        } catch (error) {
          _logger.w('Failed to import entry ${entry.id}: $error');
          errorCount++;
        }
      }
      
      // Update metadata
      await _updateMetadata('lastImport', DateTime.now().toIso8601String());
      await _incrementCounter('totalEntries', addedCount);
      
      _logger.i('Import completed: $addedCount added, $updatedCount updated, $errorCount errors');
      
      return {
        'added': addedCount,
        'updated': updatedCount,
        'errors': errorCount,
      };
    } catch (error) {
      _logger.e('Failed to import entries: $error');
      throw StorageException.bulkOperationFailed(
        'import entries',
        Exception('Failed to import $errorCount out of ${entries.length} entries'),
      );
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> exportEntries({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _ensureInitialized();
    
    try {
      final exportData = <Map<String, dynamic>>[];
      
      for (final jsonMap in _entriesBox!.values) {
        try {
          final json = Map<String, dynamic>.from(jsonMap);
          
          // Apply date filters if specified
          if (startDate != null || endDate != null) {
            final timestampStr = json['timestamp'] as String?;
            if (timestampStr != null) {
              final timestamp = DateTime.parse(timestampStr);
              if (startDate != null && timestamp.isBefore(startDate)) continue;
              if (endDate != null && timestamp.isAfter(endDate)) continue;
            }
          }
          
          exportData.add(json);
        } catch (error) {
          _logger.w('Skipping corrupted entry in export: $error');
        }
      }
      
      // Sort by timestamp
      exportData.sort((a, b) {
        final timestampA = DateTime.tryParse(a['timestamp'] as String? ?? '');
        final timestampB = DateTime.tryParse(b['timestamp'] as String? ?? '');
        if (timestampA == null || timestampB == null) return 0;
        return timestampA.compareTo(timestampB);
      });
      
      _logger.d('Exported ${exportData.length} entries');
      return exportData;
    } catch (error) {
      _logger.e('Failed to export entries: $error');
      throw StorageException.bulkOperationFailed(
        'export entries',
        error,
      );
    }
  }
  
  @override
  Future<void> saveAnalytics(AnalyticsData analytics) async {
    _ensureInitialized();
    
    try {
      final key = _generateAnalyticsKey(analytics.startDate, analytics.endDate);
      await _analyticsBox!.put(key, analytics.toJson());
      _logger.d('Saved analytics data for key: $key');
    } catch (error) {
      _logger.e('Failed to save analytics: $error');
      throw StorageException.saveFailed('analytics', error);
    }
  }
  
  @override
  Future<AnalyticsData?> getAnalytics(String key) async {
    _ensureInitialized();
    
    try {
      final jsonMap = _analyticsBox!.get(key);
      if (jsonMap == null) return null;
      
      final json = Map<String, dynamic>.from(jsonMap);
      return AnalyticsData.fromJson(json);
    } catch (error) {
      _logger.e('Failed to get analytics for key $key: $error');
      throw StorageException.readFailed('analytics_$key', error);
    }
  }
  
  @override
  Future<void> clearAnalyticsCache({DateTime? olderThan}) async {
    _ensureInitialized();
    
    try {
      if (olderThan == null) {
        await _analyticsBox!.clear();
        _logger.d('Cleared all analytics cache');
      } else {
        final keysToDelete = <String>[];
        
        for (final entry in _analyticsBox!.toMap().entries) {
          try {
            final json = Map<String, dynamic>.from(entry.value);
            final lastUpdated = DateTime.parse(json['lastUpdated'] as String);
            if (lastUpdated.isBefore(olderThan)) {
              keysToDelete.add(entry.key);
            }
          } catch (error) {
            // If we can't parse the date, remove the entry
            keysToDelete.add(entry.key);
          }
        }
        
        for (final key in keysToDelete) {
          await _analyticsBox!.delete(key);
        }
        
        _logger.d('Cleared ${keysToDelete.length} old analytics entries');
      }
    } catch (error) {
      _logger.e('Failed to clear analytics cache: $error');
      throw StorageException.deleteFailed('analytics_cache', error);
    }
  }
  
  @override
  Future<Map<String, dynamic>> performMaintenance() async {
    _ensureInitialized();
    
    try {
      final stats = <String, dynamic>{};
      
      // Perform integrity check
      final integrityResult = await _performIntegrityCheck();
      stats['integrityCheck'] = integrityResult;
      
      // Compact storage
      await _entriesBox!.compact();
      await _analyticsBox!.compact();
      await _metadataBox!.compact();
      stats['compacted'] = true;
      
      // Update maintenance timestamp
      await _updateMetadata('lastMaintenance', DateTime.now().toIso8601String());
      
      _logger.i('Maintenance completed successfully');
      return stats;
    } catch (error) {
      _logger.e('Maintenance failed: $error');
      throw StorageException(
        'Maintenance operation failed: $error',
        type: StorageExceptionType.operationFailed,
        originalError: error,
      );
    }
  }
  
  @override
  Future<Map<String, dynamic>> getStorageStats() async {
    _ensureInitialized();
    
    try {
      final entriesCount = _entriesBox!.length;
      final analyticsCount = _analyticsBox!.length;
      
      // Get type breakdown
      final typeBreakdown = <String, int>{};
      for (final jsonMap in _entriesBox!.values) {
        try {
          final json = Map<String, dynamic>.from(jsonMap);
          final type = json['type'] as String? ?? 'Unknown';
          typeBreakdown[type] = (typeBreakdown[type] ?? 0) + 1;
        } catch (error) {
          typeBreakdown['Corrupted'] = (typeBreakdown['Corrupted'] ?? 0) + 1;
        }
      }
      
      return {
        'totalEntries': entriesCount,
        'analyticsCount': analyticsCount,
        'typeBreakdown': typeBreakdown,
        'lastSave': _metadataBox!.get('lastSave'),
        'lastUpdate': _metadataBox!.get('lastUpdate'),
        'lastMaintenance': _metadataBox!.get('lastMaintenance'),
      };
    } catch (error) {
      _logger.e('Failed to get storage stats: $error');
      throw StorageException.readFailed('storage_stats', error);
    }
  }
  
  // Helper methods
  
  String _generateAnalyticsKey(DateTime startDate, DateTime endDate) {
    return 'analytics_${startDate.millisecondsSinceEpoch}_${endDate.millisecondsSinceEpoch}';
  }
  
  Future<void> _updateMetadata(String key, String value) async {
    try {
      await _metadataBox!.put(key, {'value': value, 'timestamp': DateTime.now().toIso8601String()});
    } catch (error) {
      _logger.w('Failed to update metadata $key: $error');
    }
  }
  
  Future<void> _incrementCounter(String key, [int amount = 1]) async {
    try {
      final current = _metadataBox!.get(key)?['value'] as int? ?? 0;
      await _metadataBox!.put(key, {'value': current + amount, 'timestamp': DateTime.now().toIso8601String()});
    } catch (error) {
      _logger.w('Failed to increment counter $key: $error');
    }
  }
  
  Future<void> _decrementCounter(String key, [int amount = 1]) async {
    try {
      final current = _metadataBox!.get(key)?['value'] as int? ?? 0;
      await _metadataBox!.put(key, {'value': (current - amount).clamp(0, double.infinity).toInt(), 'timestamp': DateTime.now().toIso8601String()});
    } catch (error) {
      _logger.w('Failed to decrement counter $key: $error');
    }
  }
  
  Future<Map<String, dynamic>> _performIntegrityCheck() async {
    int totalEntries = 0;
    int corruptedEntries = 0;
    int validEntries = 0;
    
    try {
      for (final jsonMap in _entriesBox!.values) {
        totalEntries++;
        try {
          // CRITICAL FIX: Handle both Map<dynamic, dynamic> and Map<String, dynamic>
          Map<String, dynamic> json;
          if (jsonMap is Map<String, dynamic>) {
            json = jsonMap;
          } else {
            // Convert Map<dynamic, dynamic> to Map<String, dynamic>
            json = Map<String, dynamic>.from(jsonMap);
          }
          WellnessEntry.fromJson(json);
          validEntries++;
        } catch (error) {
          corruptedEntries++;
          _logger.w('Found corrupted entry during integrity check: $error');
        }
      }
      
      final result = {
        'totalEntries': totalEntries,
        'validEntries': validEntries,
        'corruptedEntries': corruptedEntries,
        'integrityPercentage': totalEntries > 0 ? (validEntries / totalEntries * 100) : 100.0,
      };
      
      _logger.d('Integrity check completed: $result');
      return result;
    } catch (error) {
      _logger.e('Integrity check failed: $error');
      return {
        'error': error.toString(),
        'totalEntries': totalEntries,
        'validEntries': validEntries,
        'corruptedEntries': corruptedEntries,
      };
    }
  }
}
