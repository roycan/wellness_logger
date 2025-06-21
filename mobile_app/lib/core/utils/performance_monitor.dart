import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Performance monitoring and metrics utility for production optimization.
/// 
/// Provides lightweight performance tracking and memory monitoring
/// for identifying bottlenecks and optimization opportunities.
class PerformanceMonitor {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      printEmojis: true,
    ),
  );

  static final Map<String, DateTime> _timers = {};
  static final Map<String, int> _counters = {};

  /// Start timing an operation
  static void startTimer(String operationName) {
    _timers[operationName] = DateTime.now();
    if (kDebugMode) {
      developer.Timeline.startSync(operationName);
    }
  }

  /// End timing an operation and log the duration
  static void endTimer(String operationName) {
    if (_timers.containsKey(operationName)) {
      final duration = DateTime.now().difference(_timers[operationName]!);
      _timers.remove(operationName);
      
      if (kDebugMode) {
        developer.Timeline.finishSync();
        _logger.i('⏱️ $operationName completed in ${duration.inMilliseconds}ms');
      }
      
      // Log slow operations in production (>1 second)
      if (duration.inMilliseconds > 1000) {
        _logger.w('🐌 Slow operation: $operationName took ${duration.inMilliseconds}ms');
      }
    }
  }

  /// Time a specific operation
  static Future<T> timeOperation<T>(
    String operationName, 
    Future<T> Function() operation,
  ) async {
    startTimer(operationName);
    try {
      final result = await operation();
      endTimer(operationName);
      return result;
    } catch (e) {
      endTimer(operationName);
      _logger.e('❌ Operation failed: $operationName', error: e);
      rethrow;
    }
  }

  /// Increment a counter for tracking frequency of operations
  static void incrementCounter(String counterName) {
    _counters[counterName] = (_counters[counterName] ?? 0) + 1;
    
    // Log every 10th occurrence for debugging
    if (kDebugMode && _counters[counterName]! % 10 == 0) {
      _logger.d('📊 $counterName: ${_counters[counterName]} occurrences');
    }
  }

  /// Get current counter value
  static int getCounter(String counterName) {
    return _counters[counterName] ?? 0;
  }

  /// Log memory usage (debug builds only)
  static void logMemoryUsage(String context) {
    if (kDebugMode) {
      developer.Timeline.instantSync('Memory Check', arguments: {
        'context': context,
      });
      _logger.d('🧠 Memory check at: $context');
    }
  }

  /// Reset all counters and timers
  static void reset() {
    _timers.clear();
    _counters.clear();
    if (kDebugMode) {
      _logger.i('🔄 Performance monitoring reset');
    }
  }

  /// Get performance summary
  static Map<String, dynamic> getSummary() {
    return {
      'active_timers': _timers.keys.toList(),
      'counters': Map<String, int>.from(_counters),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Start tracking overall app performance
  static void startAppPerformanceTracking() {
    if (kDebugMode) {
      _logger.i('🚀 Performance monitoring started');
    }
    startTimer('app_session');
  }
}
