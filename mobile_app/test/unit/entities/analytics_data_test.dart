import 'package:flutter_test/flutter_test.dart';
import 'package:wellness_logger_mobile/domain/entities/analytics_data.dart';

void main() {
  group('AnalyticsData', () {
    group('Construction', () {
      test('should create with all fields', () {
        final startDate = DateTime(2025, 6, 1);
        final endDate = DateTime(2025, 6, 30);
        final lastUpdated = DateTime.now();
        
        final analyticsData = AnalyticsData(
          startDate: startDate,
          endDate: endDate,
          totalSvtEpisodes: 5,
          averageEpisodeDuration: 3.5,
          episodesThisWeek: 2,
          episodesThisMonth: 5,
          totalExerciseSessions: 10,
          averageExerciseDuration: 45.0,
          exerciseSessionsThisWeek: 3,
          exerciseSessionsThisMonth: 10,
          totalMedicationTaken: 8,
          medicationTakenThisWeek: 2,
          medicationTakenThisMonth: 8,
          adherenceRate: 0.85,
          svtTriggerPatterns: {'after_exercise': 3, 'during_stress': 2},
          exerciseTypeFrequency: {'running': 5, 'cycling': 3, 'swimming': 2},
          insights: ['SVT episodes often occur after exercise', 'Exercise frequency is consistent'],
          totalEntries: 23,
          dataCompleteness: 0.95,
          lastUpdated: lastUpdated,
        );

        expect(analyticsData.startDate, equals(startDate));
        expect(analyticsData.endDate, equals(endDate));
        expect(analyticsData.totalSvtEpisodes, equals(5));
        expect(analyticsData.averageEpisodeDuration, equals(3.5));
        expect(analyticsData.episodesThisWeek, equals(2));
        expect(analyticsData.episodesThisMonth, equals(5));
        expect(analyticsData.totalExerciseSessions, equals(10));
        expect(analyticsData.averageExerciseDuration, equals(45.0));
        expect(analyticsData.exerciseSessionsThisWeek, equals(3));
        expect(analyticsData.exerciseSessionsThisMonth, equals(10));
        expect(analyticsData.totalMedicationTaken, equals(8));
        expect(analyticsData.medicationTakenThisWeek, equals(2));
        expect(analyticsData.medicationTakenThisMonth, equals(8));
        expect(analyticsData.adherenceRate, equals(0.85));
        expect(analyticsData.svtTriggerPatterns, equals({'after_exercise': 3, 'during_stress': 2}));
        expect(analyticsData.exerciseTypeFrequency, equals({'running': 5, 'cycling': 3, 'swimming': 2}));
        expect(analyticsData.insights, equals(['SVT episodes often occur after exercise', 'Exercise frequency is consistent']));
        expect(analyticsData.totalEntries, equals(23));
        expect(analyticsData.dataCompleteness, equals(0.95));
        expect(analyticsData.lastUpdated, equals(lastUpdated));
      });
    });

    group('Factory constructor', () {
      test('should create empty analytics data', () {
        final empty = AnalyticsData.empty();

        expect(empty.totalSvtEpisodes, equals(0));
        expect(empty.averageEpisodeDuration, equals(0.0));
        expect(empty.episodesThisWeek, equals(0));
        expect(empty.episodesThisMonth, equals(0));
        expect(empty.totalExerciseSessions, equals(0));
        expect(empty.averageExerciseDuration, equals(0.0));
        expect(empty.exerciseSessionsThisWeek, equals(0));
        expect(empty.exerciseSessionsThisMonth, equals(0));
        expect(empty.totalMedicationTaken, equals(0));
        expect(empty.medicationTakenThisWeek, equals(0));
        expect(empty.medicationTakenThisMonth, equals(0));
        expect(empty.adherenceRate, equals(0.0));
        expect(empty.svtTriggerPatterns, isEmpty);
        expect(empty.exerciseTypeFrequency, isEmpty);
        expect(empty.insights, isEmpty);
        expect(empty.totalEntries, equals(0));
        expect(empty.dataCompleteness, equals(0.0));
        expect(empty.startDate, equals(empty.endDate));
        expect(empty.lastUpdated, isA<DateTime>());
      });
    });

    group('Validation', () {
      test('should be valid with proper data', () {
        final validData = AnalyticsData(
          startDate: DateTime(2025, 6, 1),
          endDate: DateTime(2025, 6, 30),
          totalSvtEpisodes: 5,
          averageEpisodeDuration: 3.5,
          episodesThisWeek: 2,
          episodesThisMonth: 5,
          totalExerciseSessions: 10,
          averageExerciseDuration: 45.0,
          exerciseSessionsThisWeek: 3,
          exerciseSessionsThisMonth: 10,
          totalMedicationTaken: 8,
          medicationTakenThisWeek: 2,
          medicationTakenThisMonth: 8,
          adherenceRate: 0.85,
          svtTriggerPatterns: {},
          exerciseTypeFrequency: {},
          insights: [],
          totalEntries: 23,
          dataCompleteness: 0.95,
          lastUpdated: DateTime.now(),
        );

        expect(validData.isValid(), isTrue);
      });

      test('should be invalid when start date is after end date', () {
        final invalidData = AnalyticsData(
          startDate: DateTime(2025, 6, 30),
          endDate: DateTime(2025, 6, 1), // end before start
          totalSvtEpisodes: 0,
          averageEpisodeDuration: 0.0,
          episodesThisWeek: 0,
          episodesThisMonth: 0,
          totalExerciseSessions: 0,
          averageExerciseDuration: 0.0,
          exerciseSessionsThisWeek: 0,
          exerciseSessionsThisMonth: 0,
          totalMedicationTaken: 0,
          medicationTakenThisWeek: 0,
          medicationTakenThisMonth: 0,
          adherenceRate: 0.0,
          svtTriggerPatterns: {},
          exerciseTypeFrequency: {},
          insights: [],
          totalEntries: 0,
          dataCompleteness: 0.0,
          lastUpdated: DateTime.now(),
        );

        expect(invalidData.isValid(), isFalse);
      });

      test('should be invalid with negative values', () {
        final invalidData = AnalyticsData(
          startDate: DateTime(2025, 6, 1),
          endDate: DateTime(2025, 6, 30),
          totalSvtEpisodes: -1, // negative
          averageEpisodeDuration: 0.0,
          episodesThisWeek: 0,
          episodesThisMonth: 0,
          totalExerciseSessions: 0,
          averageExerciseDuration: 0.0,
          exerciseSessionsThisWeek: 0,
          exerciseSessionsThisMonth: 0,
          totalMedicationTaken: 0,
          medicationTakenThisWeek: 0,
          medicationTakenThisMonth: 0,
          adherenceRate: 0.0,
          svtTriggerPatterns: {},
          exerciseTypeFrequency: {},
          insights: [],
          totalEntries: 0,
          dataCompleteness: 0.0,
          lastUpdated: DateTime.now(),
        );

        expect(invalidData.isValid(), isFalse);
      });

      test('should be invalid with adherence rate out of range', () {
        final invalidData = AnalyticsData(
          startDate: DateTime(2025, 6, 1),
          endDate: DateTime(2025, 6, 30),
          totalSvtEpisodes: 0,
          averageEpisodeDuration: 0.0,
          episodesThisWeek: 0,
          episodesThisMonth: 0,
          totalExerciseSessions: 0,
          averageExerciseDuration: 0.0,
          exerciseSessionsThisWeek: 0,
          exerciseSessionsThisMonth: 0,
          totalMedicationTaken: 0,
          medicationTakenThisWeek: 0,
          medicationTakenThisMonth: 0,
          adherenceRate: 1.5, // > 1.0
          svtTriggerPatterns: {},
          exerciseTypeFrequency: {},
          insights: [],
          totalEntries: 0,
          dataCompleteness: 0.0,
          lastUpdated: DateTime.now(),
        );

        expect(invalidData.isValid(), isFalse);
      });

      test('should be invalid with data completeness out of range', () {
        final invalidData = AnalyticsData(
          startDate: DateTime(2025, 6, 1),
          endDate: DateTime(2025, 6, 30),
          totalSvtEpisodes: 0,
          averageEpisodeDuration: 0.0,
          episodesThisWeek: 0,
          episodesThisMonth: 0,
          totalExerciseSessions: 0,
          averageExerciseDuration: 0.0,
          exerciseSessionsThisWeek: 0,
          exerciseSessionsThisMonth: 0,
          totalMedicationTaken: 0,
          medicationTakenThisWeek: 0,
          medicationTakenThisMonth: 0,
          adherenceRate: 0.0,
          svtTriggerPatterns: {},
          exerciseTypeFrequency: {},
          insights: [],
          totalEntries: 0,
          dataCompleteness: -0.1, // < 0.0
          lastUpdated: DateTime.now(),
        );

        expect(invalidData.isValid(), isFalse);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final startDate = DateTime(2025, 6, 1);
        final endDate = DateTime(2025, 6, 30);
        final lastUpdated = DateTime(2025, 6, 30, 12, 0);
        
        final analyticsData = AnalyticsData(
          startDate: startDate,
          endDate: endDate,
          totalSvtEpisodes: 5,
          averageEpisodeDuration: 3.5,
          episodesThisWeek: 2,
          episodesThisMonth: 5,
          totalExerciseSessions: 10,
          averageExerciseDuration: 45.0,
          exerciseSessionsThisWeek: 3,
          exerciseSessionsThisMonth: 10,
          totalMedicationTaken: 8,
          medicationTakenThisWeek: 2,
          medicationTakenThisMonth: 8,
          adherenceRate: 0.85,
          svtTriggerPatterns: {'after_exercise': 3},
          exerciseTypeFrequency: {'running': 5},
          insights: ['Test insight'],
          totalEntries: 23,
          dataCompleteness: 0.95,
          lastUpdated: lastUpdated,
        );

        final json = analyticsData.toJson();

        expect(json['startDate'], equals('2025-06-01T00:00:00.000'));
        expect(json['endDate'], equals('2025-06-30T00:00:00.000'));
        expect(json['totalSvtEpisodes'], equals(5));
        expect(json['averageEpisodeDuration'], equals(3.5));
        expect(json['episodesThisWeek'], equals(2));
        expect(json['episodesThisMonth'], equals(5));
        expect(json['totalExerciseSessions'], equals(10));
        expect(json['averageExerciseDuration'], equals(45.0));
        expect(json['exerciseSessionsThisWeek'], equals(3));
        expect(json['exerciseSessionsThisMonth'], equals(10));
        expect(json['totalMedicationTaken'], equals(8));
        expect(json['medicationTakenThisWeek'], equals(2));
        expect(json['medicationTakenThisMonth'], equals(8));
        expect(json['adherenceRate'], equals(0.85));
        expect(json['svtTriggerPatterns'], equals({'after_exercise': 3}));
        expect(json['exerciseTypeFrequency'], equals({'running': 5}));
        expect(json['insights'], equals(['Test insight']));
        expect(json['totalEntries'], equals(23));
        expect(json['dataCompleteness'], equals(0.95));
        expect(json['lastUpdated'], equals('2025-06-30T12:00:00.000'));
      });
    });

    group('JSON deserialization', () {
      test('should deserialize from JSON correctly', () {
        final json = {
          'startDate': '2025-06-01T00:00:00.000Z',
          'endDate': '2025-06-30T00:00:00.000Z',
          'totalSvtEpisodes': 5,
          'averageEpisodeDuration': 3.5,
          'episodesThisWeek': 2,
          'episodesThisMonth': 5,
          'totalExerciseSessions': 10,
          'averageExerciseDuration': 45.0,
          'exerciseSessionsThisWeek': 3,
          'exerciseSessionsThisMonth': 10,
          'totalMedicationTaken': 8,
          'medicationTakenThisWeek': 2,
          'medicationTakenThisMonth': 8,
          'adherenceRate': 0.85,
          'svtTriggerPatterns': {'after_exercise': 3},
          'exerciseTypeFrequency': {'running': 5},
          'insights': ['Test insight'],
          'totalEntries': 23,
          'dataCompleteness': 0.95,
          'lastUpdated': '2025-06-30T12:00:00.000Z',
        };

        final analyticsData = AnalyticsData.fromJson(json);

        expect(analyticsData.startDate, equals(DateTime.parse('2025-06-01T00:00:00.000Z')));
        expect(analyticsData.endDate, equals(DateTime.parse('2025-06-30T00:00:00.000Z')));
        expect(analyticsData.totalSvtEpisodes, equals(5));
        expect(analyticsData.averageEpisodeDuration, equals(3.5));
        expect(analyticsData.episodesThisWeek, equals(2));
        expect(analyticsData.episodesThisMonth, equals(5));
        expect(analyticsData.totalExerciseSessions, equals(10));
        expect(analyticsData.averageExerciseDuration, equals(45.0));
        expect(analyticsData.exerciseSessionsThisWeek, equals(3));
        expect(analyticsData.exerciseSessionsThisMonth, equals(10));
        expect(analyticsData.totalMedicationTaken, equals(8));
        expect(analyticsData.medicationTakenThisWeek, equals(2));
        expect(analyticsData.medicationTakenThisMonth, equals(8));
        expect(analyticsData.adherenceRate, equals(0.85));
        expect(analyticsData.svtTriggerPatterns, equals({'after_exercise': 3}));
        expect(analyticsData.exerciseTypeFrequency, equals({'running': 5}));
        expect(analyticsData.insights, equals(['Test insight']));
        expect(analyticsData.totalEntries, equals(23));
        expect(analyticsData.dataCompleteness, equals(0.95));
        expect(analyticsData.lastUpdated, equals(DateTime.parse('2025-06-30T12:00:00.000Z')));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = AnalyticsData.empty();
        
        final updated = original.copyWith(
          totalSvtEpisodes: 10,
          averageEpisodeDuration: 5.0,
          insights: ['New insight'],
        );

        expect(updated.totalSvtEpisodes, equals(10));
        expect(updated.averageEpisodeDuration, equals(5.0));
        expect(updated.insights, equals(['New insight']));
        // Unchanged fields should remain the same
        expect(updated.startDate, equals(original.startDate));
        expect(updated.endDate, equals(original.endDate));
        expect(updated.totalExerciseSessions, equals(original.totalExerciseSessions));
      });
    });

    group('Equality', () {
      test('should be equal when key fields match', () {
        final date1 = DateTime(2025, 6, 1);
        final date2 = DateTime(2025, 6, 30);
        final lastUpdated = DateTime(2025, 6, 30, 12, 0);
        
        final analytics1 = AnalyticsData(
          startDate: date1,
          endDate: date2,
          totalSvtEpisodes: 5,
          averageEpisodeDuration: 3.5,
          episodesThisWeek: 2,
          episodesThisMonth: 5,
          totalExerciseSessions: 10,
          averageExerciseDuration: 45.0,
          exerciseSessionsThisWeek: 3,
          exerciseSessionsThisMonth: 10,
          totalMedicationTaken: 8,
          medicationTakenThisWeek: 2,
          medicationTakenThisMonth: 8,
          adherenceRate: 0.85,
          svtTriggerPatterns: {},
          exerciseTypeFrequency: {},
          insights: [],
          totalEntries: 23,
          dataCompleteness: 0.95,
          lastUpdated: lastUpdated,
        );
        
        final analytics2 = AnalyticsData(
          startDate: date1,
          endDate: date2,
          totalSvtEpisodes: 5,
          averageEpisodeDuration: 3.5,
          episodesThisWeek: 999, // Different value, but not checked in equality
          episodesThisMonth: 999, // Different value, but not checked in equality
          totalExerciseSessions: 10,
          averageExerciseDuration: 45.0,
          exerciseSessionsThisWeek: 3,
          exerciseSessionsThisMonth: 10,
          totalMedicationTaken: 8,
          medicationTakenThisWeek: 2,
          medicationTakenThisMonth: 8,
          adherenceRate: 0.85,
          svtTriggerPatterns: {},
          exerciseTypeFrequency: {},
          insights: [],
          totalEntries: 23,
          dataCompleteness: 0.95,
          lastUpdated: lastUpdated,
        );

        expect(analytics1, equals(analytics2));
        expect(analytics1.hashCode, equals(analytics2.hashCode));
      });

      test('should not be equal when key fields differ', () {
        final analytics1 = AnalyticsData.empty();
        final analytics2 = analytics1.copyWith(totalSvtEpisodes: 10);

        expect(analytics1, isNot(equals(analytics2)));
      });
    });

    group('String representation', () {
      test('should provide meaningful toString', () {
        final analytics = AnalyticsData(
          startDate: DateTime(2025, 6, 1),
          endDate: DateTime(2025, 6, 30),
          totalSvtEpisodes: 5,
          averageEpisodeDuration: 3.5,
          episodesThisWeek: 2,
          episodesThisMonth: 5,
          totalExerciseSessions: 10,
          averageExerciseDuration: 45.0,
          exerciseSessionsThisWeek: 3,
          exerciseSessionsThisMonth: 10,
          totalMedicationTaken: 8,
          medicationTakenThisWeek: 2,
          medicationTakenThisMonth: 8,
          adherenceRate: 0.85,
          svtTriggerPatterns: {},
          exerciseTypeFrequency: {},
          insights: [],
          totalEntries: 23,
          dataCompleteness: 0.95,
          lastUpdated: DateTime(2025, 6, 30, 12, 0),
        );

        final string = analytics.toString();
        expect(string, contains('AnalyticsData'));
        expect(string, contains('2025-06-01'));
        expect(string, contains('2025-06-30'));
        expect(string, contains('entries: 23'));
        expect(string, contains('svt: 5'));
        expect(string, contains('exercise: 10'));
        expect(string, contains('medication: 8'));
      });
    });
  });
}
