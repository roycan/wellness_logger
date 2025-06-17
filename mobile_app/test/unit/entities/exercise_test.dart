import 'package:flutter_test/flutter_test.dart';
import 'package:wellness_logger_mobile/domain/entities/exercise.dart';
import 'package:wellness_logger_mobile/core/constants/app_constants.dart';

void main() {
  group('Exercise', () {
    group('Construction', () {
      test('should create with required fields', () {
        final timestamp = DateTime.now();
        final exercise = Exercise(
          id: 'exercise-123',
          timestamp: timestamp,
        );

        expect(exercise.id, equals('exercise-123'));
        expect(exercise.type, equals(AppConstants.entryTypeExercise));
        expect(exercise.timestamp, equals(timestamp));
        expect(exercise.duration, isNull);
        expect(exercise.comments, isNull);
      });

      test('should create with all fields', () {
        final timestamp = DateTime.now();
        final exercise = Exercise(
          id: 'exercise-123',
          timestamp: timestamp,
          duration: '30 minutes',
          comments: 'Morning run',
        );

        expect(exercise.id, equals('exercise-123'));
        expect(exercise.type, equals(AppConstants.entryTypeExercise));
        expect(exercise.timestamp, equals(timestamp));
        expect(exercise.duration, equals('30 minutes'));
        expect(exercise.comments, equals('Morning run'));
      });
    });

    group('Validation', () {
      test('should be valid with no duration', () {
        final exercise = Exercise(
          id: 'valid-123',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(exercise.isValid(), isTrue);
      });

      test('should be valid with proper duration format', () {
        final exercise = Exercise(
          id: 'valid-123',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          duration: '30 minutes',
        );

        expect(exercise.isValid(), isTrue);
      });

      test('should be valid with various duration formats', () {
        final testCases = [
          '15 minutes',
          '1 hour',
          '1 hour 30 minutes',
          '45 minutes',
          '2 hours',
        ];

        for (final duration in testCases) {
          final exercise = Exercise(
            id: 'test-$duration',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            duration: duration,
          );

          expect(exercise.isValid(), isTrue, reason: 'Duration "$duration" should be valid');
        }
      });

      test('should be invalid with malformed duration', () {
        final exercise = Exercise(
          id: 'invalid-123',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          duration: 'invalid duration format',
        );

        expect(exercise.isValid(), isFalse);
      });

      test('should be valid with empty duration string', () {
        final exercise = Exercise(
          id: 'empty-duration-123',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          duration: '',
        );

        expect(exercise.isValid(), isTrue);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final timestamp = DateTime(2025, 6, 10, 8, 30);
        final exercise = Exercise(
          id: 'exercise-123',
          timestamp: timestamp,
          duration: '30 minutes',
          comments: 'Morning run',
        );

        final json = exercise.toJson();

        expect(json['id'], equals('exercise-123'));
        expect(json['type'], equals('Exercise'));
        expect(json['timestamp'], equals('2025-06-10T08:30:00.000'));
        expect(json['details']['duration'], equals('30 minutes'));
        expect(json['details']['comments'], equals('Morning run'));
      });

      test('should serialize without optional fields', () {
        final timestamp = DateTime(2025, 6, 10, 8, 30);
        final exercise = Exercise(
          id: 'exercise-123',
          timestamp: timestamp,
        );

        final json = exercise.toJson();

        expect(json['id'], equals('exercise-123'));
        expect(json['type'], equals('Exercise'));
        expect(json['timestamp'], equals('2025-06-10T08:30:00.000'));
        expect(json['details'], isEmpty);
      });
    });

    group('JSON deserialization', () {
      test('should deserialize from JSON with details', () {
        final json = {
          'id': 'exercise-123',
          'type': 'Exercise',
          'timestamp': '2025-06-10T08:30:00.000Z',
          'details': {
            'duration': '30 minutes',
            'comments': 'Morning run'
          }
        };

        final exercise = Exercise.fromJson(json);

        expect(exercise.id, equals('exercise-123'));
        expect(exercise.type, equals('Exercise'));
        expect(exercise.duration, equals('30 minutes'));
        expect(exercise.comments, equals('Morning run'));
      });

      test('should handle legacy CSV-style JSON format', () {
        final json = {
          'id': 'exercise-123',
          'type': 'Exercise',
          'timestamp': '2025-06-10T08:30:00.000Z',
          'duration': '30 minutes',
          'comments': 'Legacy format'
        };

        final exercise = Exercise.fromJson(json);

        expect(exercise.id, equals('exercise-123'));
        expect(exercise.duration, equals('30 minutes'));
        expect(exercise.comments, equals('Legacy format'));
      });
    });

    group('CSV factory method', () {
      test('should create from CSV data', () {
        final timestamp = DateTime(2025, 6, 10, 8, 30);
        final exercise = Exercise.fromCsv(
          id: 'csv-123',
          timestamp: timestamp,
          duration: '30 minutes',
          comments: 'From CSV import',
        );

        expect(exercise.id, equals('csv-123'));
        expect(exercise.type, equals('Exercise'));
        expect(exercise.timestamp, equals(timestamp));
        expect(exercise.duration, equals('30 minutes'));
        expect(exercise.comments, equals('From CSV import'));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = Exercise(
          id: 'original-123',
          timestamp: DateTime(2025, 6, 10, 8, 30),
          duration: '30 minutes',
          comments: 'Original',
        );

        final updated = original.copyWith(
          duration: '45 minutes',
          comments: 'Updated',
        );

        expect(updated.id, equals('original-123')); // unchanged
        expect(updated.timestamp, equals(DateTime(2025, 6, 10, 8, 30))); // unchanged
        expect(updated.duration, equals('45 minutes')); // changed
        expect(updated.comments, equals('Updated')); // changed
        expect(updated.type, equals('Exercise')); // always Exercise
      });

      test('should ignore type parameter', () {
        final original = Exercise(
          id: 'test-123',
          timestamp: DateTime.now(),
        );

        final updated = original.copyWith(type: 'Different Type');

        expect(updated.type, equals('Exercise'));
      });
    });

    group('Equality', () {
      test('should be equal when all fields match', () {
        final timestamp = DateTime(2025, 6, 10, 8, 30);
        final exercise1 = Exercise(
          id: 'same-123',
          timestamp: timestamp,
          duration: '30 minutes',
          comments: 'Same',
        );
        final exercise2 = Exercise(
          id: 'same-123',
          timestamp: timestamp,
          duration: '30 minutes',
          comments: 'Same',
        );

        expect(exercise1, equals(exercise2));
        expect(exercise1.hashCode, equals(exercise2.hashCode));
      });

      test('should not be equal when duration differs', () {
        final timestamp = DateTime(2025, 6, 10, 8, 30);
        final exercise1 = Exercise(
          id: 'test-123',
          timestamp: timestamp,
          duration: '30 minutes',
        );
        final exercise2 = Exercise(
          id: 'test-123',
          timestamp: timestamp,
          duration: '45 minutes',
        );

        expect(exercise1, isNot(equals(exercise2)));
      });
    });

    group('String representation', () {
      test('should provide meaningful toString', () {
        final timestamp = DateTime(2025, 6, 10, 8, 30);
        final exercise = Exercise(
          id: 'test-123',
          timestamp: timestamp,
          duration: '30 minutes',
          comments: 'Morning run',
        );

        final string = exercise.toString();
        expect(string, contains('Exercise'));
        expect(string, contains('test-123'));
        expect(string, contains('2025-06-10 08:30:00.000'));
        expect(string, contains('30 minutes'));
        expect(string, contains('Morning run'));
      });
    });
  });
}
