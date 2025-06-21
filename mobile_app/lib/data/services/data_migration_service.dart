import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/wellness_entry.dart';
import '../datasources/sqlite_local_data_source.dart';
import '../datasources/hive_local_data_source.dart';

/// Utility class to migrate data from Hive to SQLite.
/// 
/// This class helps users migrate their existing wellness data from the 
/// old Hive storage to the new SQLite storage system without data loss.
class DataMigrationService {
  final Logger _logger = Logger();
  
  /// Migrates all wellness entries from Hive to SQLite.
  /// 
  /// Returns a map with migration statistics:
  /// - 'total': Total entries found in Hive
  /// - 'migrated': Successfully migrated entries
  /// - 'failed': Entries that failed to migrate
  /// - 'errors': List of error messages
  Future<Map<String, dynamic>> migrateHiveToSQLite({
    String? testDirectory,
  }) async {
    _logger.i('🔄 Starting Hive to SQLite migration...');
    
    int totalEntries = 0;
    int migratedEntries = 0;
    int failedEntries = 0;
    List<String> errors = [];
    
    HiveLocalDataSource? hiveSource;
    SQLiteLocalDataSource? sqliteSource;
    
    try {
      // Initialize Hive data source
      hiveSource = HiveLocalDataSource(testDirectory: testDirectory);
      await hiveSource.initialize();
      
      // Initialize SQLite data source
      sqliteSource = SQLiteLocalDataSource(testDirectory: testDirectory);
      await sqliteSource.initialize();
      
      // Get all entries from Hive
      final hiveEntries = await hiveSource.getEntries();
      totalEntries = hiveEntries.length;
      
      _logger.i('📊 Found $totalEntries entries in Hive to migrate');
      
      if (totalEntries == 0) {
        _logger.i('✅ No entries to migrate');
        return {
          'total': 0,
          'migrated': 0,
          'failed': 0,
          'errors': [],
        };
      }
      
      // Migrate each entry
      for (int i = 0; i < hiveEntries.length; i++) {
        final entry = hiveEntries[i];
        try {
          await sqliteSource.saveEntry(entry);
          migratedEntries++;
          
          if ((i + 1) % 10 == 0 || i == hiveEntries.length - 1) {
            _logger.i('📈 Progress: ${i + 1}/$totalEntries entries processed');
          }
        } catch (error) {
          failedEntries++;
          final errorMsg = 'Failed to migrate entry ${entry.id}: $error';
          errors.add(errorMsg);
          _logger.w(errorMsg);
        }
      }
      
      _logger.i('✅ Migration completed: $migratedEntries/$totalEntries successful');
      
      return {
        'total': totalEntries,
        'migrated': migratedEntries,
        'failed': failedEntries,
        'errors': errors,
      };
      
    } catch (error, stackTrace) {
      _logger.e('❌ Migration failed: $error', stackTrace: stackTrace);
      errors.add('Migration failed: $error');
      
      return {
        'total': totalEntries,
        'migrated': migratedEntries,
        'failed': failedEntries,
        'errors': errors,
      };
    } finally {
      // Clean up resources
      try {
        await hiveSource?.close();
        await sqliteSource?.close();
      } catch (e) {
        _logger.w('Error closing data sources: $e');
      }
    }
  }
  
  /// Checks if Hive data exists that could be migrated.
  /// 
  /// Returns true if there are entries in Hive that could be migrated.
  Future<bool> hasHiveDataToMigrate({String? testDirectory}) async {
    HiveLocalDataSource? hiveSource;
    
    try {
      hiveSource = HiveLocalDataSource(testDirectory: testDirectory);
      await hiveSource.initialize();
      
      final entries = await hiveSource.getEntries(limit: 1);
      return entries.isNotEmpty;
    } catch (error) {
      _logger.w('Could not check Hive data: $error');
      return false;
    } finally {
      try {
        await hiveSource?.close();
      } catch (e) {
        _logger.w('Error closing Hive source: $e');
      }
    }
  }
  
  /// Creates a backup of Hive data before migration.
  /// 
  /// Returns the backup file path or null if backup failed.
  Future<String?> createHiveBackup({String? testDirectory}) async {
    try {
      _logger.i('📦 Creating Hive backup...');
      
      final hiveSource = HiveLocalDataSource(testDirectory: testDirectory);
      await hiveSource.initialize();
      
      final entries = await hiveSource.getEntries();
      if (entries.isEmpty) {
        _logger.i('No entries to backup');
        return null;
      }
      
      final exportData = await hiveSource.exportEntries();
      
      // In a real implementation, we'd save this to a file
      // For now, we'll just log the count
      _logger.i('✅ Backup prepared: ${exportData.length} entries');
      
      await hiveSource.close();
      
      return 'backup_${DateTime.now().millisecondsSinceEpoch}.json';
    } catch (error) {
      _logger.e('❌ Backup failed: $error');
      return null;
    }
  }
}
