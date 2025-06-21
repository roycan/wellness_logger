import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/wellness_entry.dart';
import '../../domain/entities/analytics_data.dart';
import '../../core/constants/app_constants.dart';
import 'local_data_source.dart';
import 'storage_exception.dart';

/// SQLite implementation of local data storage.
/// 
/// This implementation uses SQLite for local data persistence, providing
/// reliable SQL-based storage with strong consistency and type safety.
/// 
/// **Benefits over Hive:**
/// - Strong type safety with SQL schema
/// - Better debugging with SQL queries
/// - More predictable data serialization
/// - Industry standard with excellent Flutter support
class SQLiteLocalDataSource implements LocalDataSource {
  static const String _databaseName = 'wellness_logger.db';
  static const int _databaseVersion = 1;
  
  // Table names
  static const String _entriesTable = 'wellness_entries';
  static const String _analyticsTable = 'analytics_cache';
  static const String _metadataTable = 'metadata';
  
  final Logger _logger = Logger();
  final String? _testDirectory;
  
  Database? _database;
  bool _isInitialized = false;
  
  /// Creates a new SQLiteLocalDataSource.
  /// 
  /// [testDirectory] - Optional directory path for testing.
  /// If provided, SQLite will be initialized in this directory.
  SQLiteLocalDataSource({String? testDirectory}) : _testDirectory = testDirectory;
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  Future<bool> initialize() async {
    try {
      _logger.i('🔄 Initializing SQLite local data source...');
      
      // Get database path
      final String path;
      if (_testDirectory != null) {
        path = join(_testDirectory!, _databaseName);
      } else {
        final databasesPath = await getDatabasesPath();
        path = join(databasesPath, _databaseName);
      }
      
      _logger.i('📂 Database path: $path');
      
      // Open database
      _database = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createTables,
        onUpgrade: _upgradeDatabase,
      );
      
      _isInitialized = true;
      
      // Log initial stats
      final entryCount = await _getTableCount(_entriesTable);
      _logger.i('📦 SQLite initialized successfully. Entries: $entryCount');
      
      return true;
    } catch (error, stackTrace) {
      _logger.e('Failed to initialize SQLite: $error', stackTrace: stackTrace);
      _isInitialized = false;
      throw StorageException.initializationFailed(error.toString());
    }
  }
  
  Future<void> _createTables(Database db, int version) async {
    _logger.i('📋 Creating database tables...');
    
    // Wellness entries table
    await db.execute('''
      CREATE TABLE $_entriesTable (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Create indices for better query performance
    await db.execute('''
      CREATE INDEX idx_entries_type ON $_entriesTable(type)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_entries_timestamp ON $_entriesTable(timestamp)
    ''');
    
    // Analytics cache table
    await db.execute('''
      CREATE TABLE $_analyticsTable (
        key TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Metadata table for storing counters and settings
    await db.execute('''
      CREATE TABLE $_metadataTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    _logger.i('✅ Database tables created successfully');
  }
  
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    _logger.i('🔄 Upgrading database from v$oldVersion to v$newVersion');
    // Future database migrations will go here
  }
  
  @override
  Future<void> close() async {
    try {
      await _database?.close();
      _database = null;
      _isInitialized = false;
      _logger.i('SQLite local data source closed');
    } catch (error) {
      _logger.w('Error closing SQLite: $error');
    }
  }
  
  void _ensureInitialized() {
    if (!_isInitialized || _database == null) {
      throw StorageException.initializationFailed('Data source not initialized');
    }
  }
  
  @override
  Future<WellnessEntry> saveEntry(WellnessEntry entry) async {
    _ensureInitialized();
    
    try {
      final now = DateTime.now().toIso8601String();
      
      await _database!.insert(
        _entriesTable,
        {
          'id': entry.id,
          'type': entry.type,
          'timestamp': entry.timestamp.toIso8601String(),
          'data': jsonEncode(entry.toJson()),
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      _logger.i('✅ SAVED entry: ${entry.id} (${entry.type})');
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
      final List<Map<String, Object?>> results = await _database!.query(
        _entriesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (results.isEmpty) {
        return null;
      }
      
      final row = results.first;
      final dataJson = jsonDecode(row['data'] as String) as Map<String, dynamic>;
      
      return WellnessEntry.fromJson(dataJson);
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
    
    try {
      String whereClause = '';
      List<Object> whereArgs = [];
      
      // Build WHERE clause
      List<String> conditions = [];
      
      if (type != null) {
        conditions.add('type = ?');
        whereArgs.add(type);
      }
      
      if (startDate != null) {
        conditions.add('timestamp >= ?');
        whereArgs.add(startDate.toIso8601String());
      }
      
      if (endDate != null) {
        conditions.add('timestamp <= ?');
        whereArgs.add(endDate.toIso8601String());
      }
      
      if (conditions.isNotEmpty) {
        whereClause = 'WHERE ${conditions.join(' AND ')}';
      }
      
      final sql = '''
        SELECT * FROM $_entriesTable 
        $whereClause
        ORDER BY timestamp DESC
        ${limit != null ? 'LIMIT $limit' : ''}
        ${offset > 0 ? 'OFFSET $offset' : ''}
      ''';
      
      final List<Map<String, Object?>> results = await _database!.rawQuery(sql, whereArgs);
      
      final entries = <WellnessEntry>[];
      for (final row in results) {
        try {
          final dataJson = jsonDecode(row['data'] as String) as Map<String, dynamic>;
          final entry = WellnessEntry.fromJson(dataJson);
          entries.add(entry);
        } catch (error) {
          _logger.w('Skipping corrupted entry: ${row['id']}: $error');
        }
      }
      
      _logger.i('🔍 LOADED ${entries.length} entries from SQLite');
      return entries;
    } catch (error) {
      _logger.e('Failed to get entries: $error');
      throw StorageException.readFailed('entries_query', error);
    }
  }
  
  // Helper method to get table count
  Future<int> _getTableCount(String tableName) async {
    final result = await _database!.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  // TODO: Implement remaining methods (updateEntry, deleteEntry, etc.)
  // For now, we'll implement the core CRUD operations to test the concept
  
  @override
  Future<WellnessEntry> updateEntry(WellnessEntry entry) async {
    _ensureInitialized();
    
    try {
      final count = await _database!.update(
        _entriesTable,
        {
          'type': entry.type,
          'timestamp': entry.timestamp.toIso8601String(),
          'data': jsonEncode(entry.toJson()),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [entry.id],
      );
      
      if (count == 0) {
        throw StorageException.entryNotFound(entry.id);
      }
      
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
      final count = await _database!.delete(
        _entriesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (count > 0) {
        _logger.d('Deleted entry: $id');
        return true;
      }
      
      return false;
    } catch (error) {
      _logger.e('Failed to delete entry $id: $error');
      throw StorageException.deleteFailed(id, error);
    }
  }
  
  // Placeholder implementations for remaining methods
  // These will be implemented as needed
  
  @override
  Future<int> deleteEntries(List<String> ids) async {
    // TODO: Implement batch delete
    throw UnimplementedError('deleteEntries not yet implemented');
  }
  
  @override
  Future<int> getEntryCount({String? type, DateTime? startDate, DateTime? endDate}) async {
    // TODO: Implement count query
    throw UnimplementedError('getEntryCount not yet implemented');
  }
  
  @override
  Future<List<WellnessEntry>> saveEntries(List<WellnessEntry> entries) async {
    // TODO: Implement batch save
    throw UnimplementedError('saveEntries not yet implemented');
  }
  
  @override
  Future<Map<String, int>> importEntries(List<WellnessEntry> entries, {bool overwriteExisting = false}) async {
    // TODO: Implement import
    throw UnimplementedError('importEntries not yet implemented');
  }
  
  @override
  Future<List<Map<String, dynamic>>> exportEntries({DateTime? startDate, DateTime? endDate}) async {
    // TODO: Implement export
    throw UnimplementedError('exportEntries not yet implemented');
  }
  
  @override
  Future<void> saveAnalytics(AnalyticsData analytics) async {
    // TODO: Implement analytics save
    throw UnimplementedError('saveAnalytics not yet implemented');
  }
  
  @override
  Future<AnalyticsData?> getAnalytics(String key) async {
    // TODO: Implement analytics get
    throw UnimplementedError('getAnalytics not yet implemented');
  }
  
  @override
  Future<void> clearAnalyticsCache({DateTime? olderThan}) async {
    // TODO: Implement analytics clear
    throw UnimplementedError('clearAnalyticsCache not yet implemented');
  }
  
  @override
  Future<void> clearAllEntries() async {
    _ensureInitialized();
    
    try {
      await _database!.delete(_entriesTable);
      _logger.i('Cleared all entries');
    } catch (error) {
      _logger.e('Failed to clear entries: $error');
      throw StorageException.operationFailed('clear entries', originalError: error);
    }
  }
  
  @override
  Future<Map<String, dynamic>> performMaintenance() async {
    // TODO: Implement maintenance operations
    throw UnimplementedError('performMaintenance not yet implemented');
  }
  
  @override
  Future<Map<String, dynamic>> getStorageStats() async {
    _ensureInitialized();
    
    try {
      final entryCount = await _getTableCount(_entriesTable);
      final analyticsCount = await _getTableCount(_analyticsTable);
      
      return {
        'totalEntries': entryCount,
        'analyticsCount': analyticsCount,
        'databasePath': _database!.path,
      };
    } catch (error) {
      _logger.e('Failed to get storage stats: $error');
      throw StorageException.readFailed('storage_stats', error);
    }
  }
}
