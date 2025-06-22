import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Simple logger for the settings service
class _Logger {
  void i(String message) => print('[INFO] $message');
  void d(String message) => print('[DEBUG] $message');
  void w(String message) => print('[WARNING] $message');
  void e(String message, {StackTrace? stackTrace}) {
    print('[ERROR] $message');
    if (stackTrace != null) print(stackTrace);
  }
}

/// SQLite-based settings service for storing user preferences.
/// 
/// This service provides persistent storage for app settings like
/// notifications, reminders, display preferences, and default values.
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  Database? _database;
  final _Logger _logger = _Logger();
  bool _isInitialized = false;

  /// Initialize the settings database
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _logger.i('🔧 Initializing Settings Service...');
      
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, 'wellness_settings.db');

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _createTables,
      );

      _isInitialized = true;
      _logger.i('✅ Settings Service initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize Settings Service: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Create the settings table
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    
    _logger.i('📊 Created settings table');
  }

  /// Get a boolean setting
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    await _ensureInitialized();
    
    try {
      final result = await _database!.query(
        'settings',
        where: 'key = ?',
        whereArgs: [key],
      );
      
      if (result.isEmpty) {
        return defaultValue;
      }
      
      return result.first['value'] == 'true';
    } catch (e) {
      _logger.w('Failed to get boolean setting $key: $e');
      return defaultValue;
    }
  }

  /// Get a string setting
  Future<String> getString(String key, {String defaultValue = ''}) async {
    await _ensureInitialized();
    
    try {
      final result = await _database!.query(
        'settings',
        where: 'key = ?',
        whereArgs: [key],
      );
      
      if (result.isEmpty) {
        return defaultValue;
      }
      
      return result.first['value'] as String;
    } catch (e) {
      _logger.w('Failed to get string setting $key: $e');
      return defaultValue;
    }
  }

  /// Set a boolean setting
  Future<void> setBool(String key, bool value) async {
    await _ensureInitialized();
    
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      
      await _database!.execute('''
        INSERT OR REPLACE INTO settings (key, value, type, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?)
      ''', [key, value.toString(), 'bool', now, now]);
      
      _logger.d('✅ Saved boolean setting: $key = $value');
    } catch (e) {
      _logger.e('Failed to set boolean setting $key: $e');
      rethrow;
    }
  }

  /// Set a string setting
  Future<void> setString(String key, String value) async {
    await _ensureInitialized();
    
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      
      await _database!.execute('''
        INSERT OR REPLACE INTO settings (key, value, type, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?)
      ''', [key, value, 'string', now, now]);
      
      _logger.d('✅ Saved string setting: $key = $value');
    } catch (e) {
      _logger.e('Failed to set string setting $key: $e');
      rethrow;
    }
  }

  /// Get all settings as a map
  Future<Map<String, dynamic>> getAllSettings() async {
    await _ensureInitialized();
    
    try {
      final result = await _database!.query('settings');
      final settings = <String, dynamic>{};
      
      for (final row in result) {
        final key = row['key'] as String;
        final value = row['value'] as String;
        final type = row['type'] as String;
        
        switch (type) {
          case 'bool':
            settings[key] = value == 'true';
            break;
          case 'string':
            settings[key] = value;
            break;
          default:
            settings[key] = value;
        }
      }
      
      return settings;
    } catch (e) {
      _logger.e('Failed to get all settings: $e');
      return {};
    }
  }

  /// Clear all settings
  Future<void> clearAll() async {
    await _ensureInitialized();
    
    try {
      await _database!.delete('settings');
      _logger.i('🗑️ Cleared all settings');
    } catch (e) {
      _logger.e('Failed to clear settings: $e');
      rethrow;
    }
  }

  /// Get database info for debugging
  Future<Map<String, dynamic>> getDebugInfo() async {
    await _ensureInitialized();
    
    try {
      final settingsCount = await _database!.rawQuery('SELECT COUNT(*) as count FROM settings');
      final dbPath = _database!.path;
      
      return {
        'database_path': dbPath,
        'settings_count': settingsCount.first['count'],
        'is_initialized': _isInitialized,
        'database_version': await _database!.getVersion(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'is_initialized': _isInitialized,
      };
    }
  }

  /// Ensure the service is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Close the database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _isInitialized = false;
      _logger.i('🔒 Settings Service closed');
    }
  }
}
