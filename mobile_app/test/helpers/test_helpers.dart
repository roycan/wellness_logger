import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellness_logger_mobile/core/theme/app_theme.dart';

/// Test helper utilities for the Wellness Logger app.
/// 
/// This class provides common testing utilities that can be reused across
/// different test files to maintain consistency and reduce code duplication.
class TestHelpers {
  TestHelpers._();
  
  /// Creates a testable widget with proper theme and material app wrapper.
  /// 
  /// This is essential for widget tests as many Flutter widgets require
  /// MaterialApp context to function properly.
  /// 
  /// Usage:
  /// ```dart
  /// await tester.pumpWidget(TestHelpers.createTestWidget(MyWidget()));
  /// ```
  static Widget createTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }
  
  /// Creates a testable widget with custom theme.
  static Widget createTestWidgetWithTheme(Widget child, ThemeData theme) {
    return MaterialApp(
      theme: theme,
      home: Scaffold(body: child),
    );
  }
  
  /// Pumps a widget and settles all animations.
  /// 
  /// This is useful for testing widgets with animations or async operations.
  static Future<void> pumpAndSettleWidget(
    WidgetTester tester,
    Widget widget, {
    Duration? duration,
  }) async {
    await tester.pumpWidget(createTestWidget(widget));
    await tester.pumpAndSettle(duration ?? const Duration(milliseconds: 100));
  }
  
  /// Creates a sample DateTime for testing.
  static DateTime createTestDateTime([int? year, int? month, int? day]) {
    return DateTime(
      year ?? 2024,
      month ?? 1,
      day ?? 15,
      10, // hour
      30, // minute
    );
  }
  
  /// Creates a list of test DateTimes spanning multiple days.
  static List<DateTime> createTestDateTimeRange(int count) {
    final now = DateTime.now();
    return List.generate(
      count,
      (index) => now.subtract(Duration(days: index)),
    );
  }
  
  /// Waits for a specific duration in tests.
  static Future<void> wait([Duration? duration]) async {
    await Future.delayed(duration ?? const Duration(milliseconds: 100));
  }
  
  /// Finds a widget by its key.
  static Finder findByKey(String key) {
    return find.byKey(Key(key));
  }
  
  /// Finds a widget by its text content.
  static Finder findByText(String text) {
    return find.text(text);
  }
  
  /// Finds a widget by its type.
  static Finder findByType<T extends Widget>() {
    return find.byType(T);
  }
  
  /// Verifies that a widget exists and is visible.
  static void expectWidgetExists(Finder finder) {
    expect(finder, findsOneWidget);
  }
  
  /// Verifies that a widget does not exist.
  static void expectWidgetNotExists(Finder finder) {
    expect(finder, findsNothing);
  }
  
  /// Verifies that multiple widgets exist.
  static void expectMultipleWidgets(Finder finder, int count) {
    expect(finder, findsNWidgets(count));
  }
  
  /// Taps a widget and waits for animations to settle.
  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder, {
    Duration? settleDuration,
  }) async {
    await tester.tap(finder);
    await tester.pumpAndSettle(settleDuration ?? const Duration(milliseconds: 100));
  }
  
  /// Enters text into a text field and waits for changes.
  static Future<void> enterTextAndSettle(
    WidgetTester tester,
    Finder finder,
    String text, {
    Duration? settleDuration,
  }) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle(settleDuration ?? const Duration(milliseconds: 100));
  }
  
  /// Scrolls a widget and waits for animations.
  static Future<void> scrollAndSettle(
    WidgetTester tester,
    Finder finder,
    Offset offset, {
    Duration? settleDuration,
  }) async {
    await tester.drag(finder, offset);
    await tester.pumpAndSettle(settleDuration ?? const Duration(milliseconds: 100));
  }
}

/// Mock data factory for creating test data.
/// 
/// Provides consistent test data across different test files.
class TestDataFactory {
  TestDataFactory._();
  
  /// Creates a test wellness entry data map.
  static Map<String, dynamic> createTestEntryData({
    String? id,
    String? type,
    DateTime? timestamp,
    String? duration,
    String? dosage,
    String? comments,
  }) {
    return {
      'id': id ?? 'test-id-123',
      'type': type ?? 'SVT Episode',
      'timestamp': (timestamp ?? TestHelpers.createTestDateTime()).toIso8601String(),
      'details': {
        if (duration != null) 'duration': duration,
        if (dosage != null) 'dosage': dosage,
        'comments': comments ?? 'Test comments',
      },
    };
  }
  
  /// Creates multiple test entries.
  static List<Map<String, dynamic>> createTestEntries(int count) {
    return List.generate(count, (index) {
      final types = ['SVT Episode', 'Exercise', 'Medication'];
      return createTestEntryData(
        id: 'test-id-$index',
        type: types[index % types.length],
        timestamp: DateTime.now().subtract(Duration(days: index)),
        comments: 'Test entry #${index + 1}',
      );
    });
  }
  
  /// Creates test analytics data.
  static Map<String, dynamic> createTestAnalyticsData() {
    return {
      'currentExerciseStreak': 5,
      'svtEpisodesThisMonth': 3,
      'medicationsTakenThisMonth': 15,
      'totalEntries': 50,
      'averageSVTEpisodesPerMonth': 2.5,
      'mostActiveDay': 'Monday',
      'mostCommonSVTTime': '14:30',
      'exerciseFrequency': 0.8,
      'daysSinceLastSVT': 5,
      'averageEpisodeDuration': '2 minutes',
      'weeklyExerciseAverage': 4.2,
      'medicationAdherence': 0.95,
    };
  }
}

/// Assertion helpers for common test scenarios.
class TestAssertions {
  TestAssertions._();
  
  /// Asserts that a DateTime is approximately equal to another (within tolerance).
  static void expectDateTimeApprox(
    DateTime actual,
    DateTime expected, {
    Duration tolerance = const Duration(seconds: 1),
  }) {
    final difference = actual.difference(expected).abs();
    expect(
      difference,
      lessThanOrEqualTo(tolerance),
      reason: 'Expected $actual to be within $tolerance of $expected',
    );
  }
  
  /// Asserts that a list contains items in the expected order.
  static void expectListOrder<T>(
    List<T> actual,
    List<T> expectedOrder,
  ) {
    expect(actual.length, equals(expectedOrder.length));
    for (int i = 0; i < actual.length; i++) {
      expect(actual[i], equals(expectedOrder[i]),
          reason: 'Item at index $i does not match expected order');
    }
  }
  
  /// Asserts that a string matches a date format pattern.
  static void expectDateFormat(String dateString, String pattern) {
    // Simple validation - in a real app you might use intl package
    expect(dateString, isNotEmpty);
    expect(dateString, matches(RegExp(r'\d{4}-\d{2}-\d{2}')),
        reason: 'Date string "$dateString" does not match expected format');
  }
  
  /// Asserts that an error is of the expected type with expected message.
  static void expectWellnessError(
    dynamic error,
    String expectedType,
    String expectedMessageContains,
  ) {
    expect(error.toString(), contains(expectedType));
    expect(error.toString(), contains(expectedMessageContains));
  }
}
