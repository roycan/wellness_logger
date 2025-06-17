import 'package:flutter_test/flutter_test.dart';
import 'package:wellness_logger_mobile/domain/entities/wellness_entry.dart';
import 'package:wellness_logger_mobile/domain/entities/svt_episode.dart';
import 'package:wellness_logger_mobile/domain/entities/exercise.dart';
import 'package:wellness_logger_mobile/domain/entities/medication.dart';

void main() {
  group('WellnessEntry', () {
    group('Factory method fromJson', () {
      test('should create SvtEpisode from JSON with SVT Episode type', () {
        final json = {
          'id': 'test-svt-123',
          'type': 'SVT Episode',
          'timestamp': '2025-06-10T18:45:00.000Z',
          'details': {
            'duration': '3 minutes',
            'comments': 'Test SVT episode'
          }
        };

        final entry = WellnessEntry.fromJson(json);

        expect(entry, isA<SvtEpisode>());
        expect(entry.id, equals('test-svt-123'));
        expect(entry.type, equals('SVT Episode'));
        expect((entry as SvtEpisode).duration, equals('3 minutes'));
        expect(entry.comments, equals('Test SVT episode'));
      });

      test('should create Exercise from JSON with Exercise type', () {
        final json = {
          'id': 'test-exercise-123',
          'type': 'Exercise',
          'timestamp': '2025-06-10T08:30:00.000Z',
          'details': {
            'duration': '30 minutes',
            'comments': 'Morning run'
          }
        };

        final entry = WellnessEntry.fromJson(json);

        expect(entry, isA<Exercise>());
        expect(entry.id, equals('test-exercise-123'));
        expect(entry.type, equals('Exercise'));
        expect((entry as Exercise).duration, equals('30 minutes'));
        expect(entry.comments, equals('Morning run'));
      });

      test('should create Medication from JSON with Medication type', () {
        final json = {
          'id': 'test-med-123',
          'type': 'Medication',
          'timestamp': '2025-06-10T19:15:00.000Z',
          'details': {
            'dosage': '1/2 tablet',
            'comments': 'Tambocor after episode'
          }
        };

        final entry = WellnessEntry.fromJson(json);

        expect(entry, isA<Medication>());
        expect(entry.id, equals('test-med-123'));
        expect(entry.type, equals('Medication'));
        expect((entry as Medication).dosage, equals('1/2 tablet'));
        expect(entry.comments, equals('Tambocor after episode'));
      });

      test('should throw ArgumentError for unknown type', () {
        final json = {
          'id': 'test-unknown-123',
          'type': 'Unknown Type',
          'timestamp': '2025-06-10T12:00:00.000Z',
        };

        expect(
          () => WellnessEntry.fromJson(json),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should handle missing type field', () {
        final json = {
          'id': 'test-missing-123',
          'timestamp': '2025-06-10T12:00:00.000Z',
        };

        expect(
          () => WellnessEntry.fromJson(json),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Base validation', () {
      test('should validate proper entries', () {
        final svt = SvtEpisode(
          id: 'valid-123',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          duration: '5 minutes',
          comments: 'Test episode',
        );

        expect(svt.isValid(), isTrue);
      });

      test('should reject empty ID', () {
        final svt = SvtEpisode(
          id: '',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(svt.isValid(), isFalse);
      });

      test('should reject future timestamps beyond 1 hour', () {
        final svt = SvtEpisode(
          id: 'future-123',
          timestamp: DateTime.now().add(const Duration(hours: 2)),
        );

        expect(svt.isValid(), isFalse);
      });

      test('should allow timestamps up to 1 hour in future', () {
        final svt = SvtEpisode(
          id: 'near-future-123',
          timestamp: DateTime.now().add(const Duration(minutes: 30)),
        );

        expect(svt.isValid(), isTrue);
      });
    });

    group('Equality and hashCode', () {
      test('should be equal when all fields match', () {
        final timestamp = DateTime.now();
        final svt1 = SvtEpisode(
          id: 'same-123',
          timestamp: timestamp,
          duration: '3 minutes',
          comments: 'Same episode',
        );
        final svt2 = SvtEpisode(
          id: 'same-123',
          timestamp: timestamp,
          duration: '3 minutes',
          comments: 'Same episode',
        );

        expect(svt1, equals(svt2));
        expect(svt1.hashCode, equals(svt2.hashCode));
      });

      test('should not be equal when IDs differ', () {
        final timestamp = DateTime.now();
        final svt1 = SvtEpisode(
          id: 'different-123',
          timestamp: timestamp,
        );
        final svt2 = SvtEpisode(
          id: 'different-456',
          timestamp: timestamp,
        );

        expect(svt1, isNot(equals(svt2)));
      });

      test('should not be equal to different entry types', () {
        final timestamp = DateTime.now();
        final svt = SvtEpisode(
          id: 'test-123',
          timestamp: timestamp,
        );
        final exercise = Exercise(
          id: 'test-123',
          timestamp: timestamp,
        );

        expect(svt, isNot(equals(exercise)));
      });
    });

    group('String representation', () {
      test('should provide meaningful toString', () {
        final timestamp = DateTime(2025, 6, 10, 18, 45);
        final svt = SvtEpisode(
          id: 'test-123',
          timestamp: timestamp,
          duration: '3 minutes',
          comments: 'Test episode',
        );

        final string = svt.toString();
        expect(string, contains('SvtEpisode'));
        expect(string, contains('test-123'));
        expect(string, contains('3 minutes'));
        expect(string, contains('Test episode'));
      });
    });
  });
}
