import 'package:flutter_test/flutter_test.dart';
import 'package:wellness_logger_mobile/domain/entities/svt_episode.dart';
import 'package:wellness_logger_mobile/core/constants/app_constants.dart';

void main() {
  group('SvtEpisode', () {
    group('Construction', () {
      test('should create with required fields', () {
        final timestamp = DateTime.now();
        final episode = SvtEpisode(
          id: 'svt-123',
          timestamp: timestamp,
        );

        expect(episode.id, equals('svt-123'));
        expect(episode.type, equals(AppConstants.entryTypeSVT));
        expect(episode.timestamp, equals(timestamp));
        expect(episode.duration, isNull);
        expect(episode.comments, isNull);
      });

      test('should create with all fields', () {
        final timestamp = DateTime.now();
        final episode = SvtEpisode(
          id: 'svt-123',
          timestamp: timestamp,
          duration: '5 minutes',
          comments: 'Started during stress',
        );

        expect(episode.id, equals('svt-123'));
        expect(episode.type, equals(AppConstants.entryTypeSVT));
        expect(episode.timestamp, equals(timestamp));
        expect(episode.duration, equals('5 minutes'));
        expect(episode.comments, equals('Started during stress'));
      });
    });

    group('Validation', () {
      test('should be valid with no duration', () {
        final episode = SvtEpisode(
          id: 'valid-123',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(episode.isValid(), isTrue);
      });

      test('should be valid with proper duration format', () {
        final episode = SvtEpisode(
          id: 'valid-123',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          duration: '5 minutes',
        );

        expect(episode.isValid(), isTrue);
      });

      test('should be valid with various duration formats', () {
        final testCases = [
          '30 seconds',
          '2 minutes',
          '1 hour',
          '1 hour 30 minutes',
          '45 minutes',
        ];

        for (final duration in testCases) {
          final episode = SvtEpisode(
            id: 'test-$duration',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            duration: duration,
          );

          expect(episode.isValid(), isTrue, reason: 'Duration "$duration" should be valid');
        }
      });

      test('should be invalid with malformed duration', () {
        final episode = SvtEpisode(
          id: 'invalid-123',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          duration: 'invalid duration format',
        );

        expect(episode.isValid(), isFalse);
      });

      test('should be valid with empty duration string', () {
        final episode = SvtEpisode(
          id: 'empty-duration-123',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          duration: '',
        );

        expect(episode.isValid(), isTrue);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final timestamp = DateTime(2025, 6, 10, 18, 45);
        final episode = SvtEpisode(
          id: 'svt-123',
          timestamp: timestamp,
          duration: '3 minutes',
          comments: 'Test episode',
        );

        final json = episode.toJson();

        expect(json['id'], equals('svt-123'));
        expect(json['type'], equals('SVT Episode'));
        expect(json['timestamp'], equals('2025-06-10T18:45:00.000'));
        expect(json['details']['duration'], equals('3 minutes'));
        expect(json['details']['comments'], equals('Test episode'));
      });

      test('should serialize without optional fields', () {
        final timestamp = DateTime(2025, 6, 10, 18, 45);
        final episode = SvtEpisode(
          id: 'svt-123',
          timestamp: timestamp,
        );

        final json = episode.toJson();

        expect(json['id'], equals('svt-123'));
        expect(json['type'], equals('SVT Episode'));
        expect(json['timestamp'], equals('2025-06-10T18:45:00.000'));
        expect(json['details'], isEmpty);
      });

      test('should not include empty duration or comments', () {
        final timestamp = DateTime(2025, 6, 10, 18, 45);
        final episode = SvtEpisode(
          id: 'svt-123',
          timestamp: timestamp,
          duration: '',
          comments: '',
        );

        final json = episode.toJson();

        expect(json['details'], isEmpty);
      });
    });

    group('JSON deserialization', () {
      test('should deserialize from JSON with details', () {
        final json = {
          'id': 'svt-123',
          'type': 'SVT Episode',
          'timestamp': '2025-06-10T18:45:00.000Z',
          'details': {
            'duration': '3 minutes',
            'comments': 'Test episode'
          }
        };

        final episode = SvtEpisode.fromJson(json);

        expect(episode.id, equals('svt-123'));
        expect(episode.type, equals('SVT Episode'));
        expect(episode.duration, equals('3 minutes'));
        expect(episode.comments, equals('Test episode'));
      });

      test('should deserialize from JSON without details', () {
        final json = {
          'id': 'svt-123',
          'type': 'SVT Episode',
          'timestamp': '2025-06-10T18:45:00.000Z',
        };

        final episode = SvtEpisode.fromJson(json);

        expect(episode.id, equals('svt-123'));
        expect(episode.type, equals('SVT Episode'));
        expect(episode.duration, isNull);
        expect(episode.comments, isNull);
      });

      test('should handle legacy CSV-style JSON format', () {
        final json = {
          'id': 'svt-123',
          'type': 'SVT Episode',
          'timestamp': '2025-06-10T18:45:00.000Z',
          'duration': '3 minutes',
          'comments': 'Legacy format'
        };

        final episode = SvtEpisode.fromJson(json);

        expect(episode.id, equals('svt-123'));
        expect(episode.duration, equals('3 minutes'));
        expect(episode.comments, equals('Legacy format'));
      });
    });

    group('CSV factory method', () {
      test('should create from CSV data', () {
        final timestamp = DateTime(2025, 6, 10, 18, 45);
        final episode = SvtEpisode.fromCsv(
          id: 'csv-123',
          timestamp: timestamp,
          duration: '3 minutes',
          comments: 'From CSV import',
        );

        expect(episode.id, equals('csv-123'));
        expect(episode.type, equals('SVT Episode'));
        expect(episode.timestamp, equals(timestamp));
        expect(episode.duration, equals('3 minutes'));
        expect(episode.comments, equals('From CSV import'));
      });

      test('should create from CSV with minimal data', () {
        final timestamp = DateTime(2025, 6, 10, 18, 45);
        final episode = SvtEpisode.fromCsv(
          id: 'csv-minimal-123',
          timestamp: timestamp,
        );

        expect(episode.id, equals('csv-minimal-123'));
        expect(episode.type, equals('SVT Episode'));
        expect(episode.timestamp, equals(timestamp));
        expect(episode.duration, isNull);
        expect(episode.comments, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = SvtEpisode(
          id: 'original-123',
          timestamp: DateTime(2025, 6, 10, 18, 45),
          duration: '3 minutes',
          comments: 'Original',
        );

        final updated = original.copyWith(
          duration: '5 minutes',
          comments: 'Updated',
        );

        expect(updated.id, equals('original-123')); // unchanged
        expect(updated.timestamp, equals(DateTime(2025, 6, 10, 18, 45))); // unchanged
        expect(updated.duration, equals('5 minutes')); // changed
        expect(updated.comments, equals('Updated')); // changed
        expect(updated.type, equals('SVT Episode')); // always SVT Episode
      });

      test('should ignore type parameter', () {
        final original = SvtEpisode(
          id: 'test-123',
          timestamp: DateTime.now(),
        );

        final updated = original.copyWith(type: 'Different Type');

        expect(updated.type, equals('SVT Episode'));
      });
    });

    group('Equality', () {
      test('should be equal when all fields match', () {
        final timestamp = DateTime(2025, 6, 10, 18, 45);
        final episode1 = SvtEpisode(
          id: 'same-123',
          timestamp: timestamp,
          duration: '3 minutes',
          comments: 'Same',
        );
        final episode2 = SvtEpisode(
          id: 'same-123',
          timestamp: timestamp,
          duration: '3 minutes',
          comments: 'Same',
        );

        expect(episode1, equals(episode2));
        expect(episode1.hashCode, equals(episode2.hashCode));
      });

      test('should not be equal when duration differs', () {
        final timestamp = DateTime(2025, 6, 10, 18, 45);
        final episode1 = SvtEpisode(
          id: 'test-123',
          timestamp: timestamp,
          duration: '3 minutes',
        );
        final episode2 = SvtEpisode(
          id: 'test-123',
          timestamp: timestamp,
          duration: '5 minutes',
        );

        expect(episode1, isNot(equals(episode2)));
      });
    });

    group('String representation', () {
      test('should provide meaningful toString', () {
        final timestamp = DateTime(2025, 6, 10, 18, 45);
        final episode = SvtEpisode(
          id: 'test-123',
          timestamp: timestamp,
          duration: '3 minutes',
          comments: 'Test episode',
        );

        final string = episode.toString();
        expect(string, contains('SvtEpisode'));
        expect(string, contains('test-123'));
        expect(string, contains('2025-06-10 18:45:00.000'));
        expect(string, contains('3 minutes'));
        expect(string, contains('Test episode'));
      });
    });
  });
}
