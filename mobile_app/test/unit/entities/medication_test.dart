import 'package:flutter_test/flutter_test.dart';
import 'package:wellness_logger_mobile/domain/entities/medication.dart';
import 'package:wellness_logger_mobile/core/constants/app_constants.dart';

void main() {
  group('Medication', () {
    group('Construction', () {
      test('should create with required fields', () {
        final timestamp = DateTime.now();
        final medication = Medication(
          id: 'med-123',
          timestamp: timestamp,
        );

        expect(medication.id, equals('med-123'));
        expect(medication.type, equals(AppConstants.entryTypeMedication));
        expect(medication.timestamp, equals(timestamp));
        expect(medication.dosage, isNull);
        expect(medication.comments, isNull);
      });

      test('should create with all fields', () {
        final timestamp = DateTime.now();
        final medication = Medication(
          id: 'med-123',
          timestamp: timestamp,
          dosage: '1/2 tablet',
          comments: 'Tambocor after episode',
        );

        expect(medication.id, equals('med-123'));
        expect(medication.type, equals(AppConstants.entryTypeMedication));
        expect(medication.timestamp, equals(timestamp));
        expect(medication.dosage, equals('1/2 tablet'));
        expect(medication.comments, equals('Tambocor after episode'));
      });
    });

    group('Validation', () {
      test('should be valid with no dosage', () {
        final medication = Medication(
          id: 'valid-123',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(medication.isValid(), isTrue);
      });

      test('should be valid with any non-empty dosage text', () {
        final testCases = [
          '1/2 tablet',
          '100mg',
          '2 pills',
          '5ml',
          '1 capsule',
          'one tablet',
          '25mg twice daily',
          'as needed',
        ];

        for (final dosage in testCases) {
          final medication = Medication(
            id: 'test-$dosage',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            dosage: dosage,
          );

          expect(medication.isValid(), isTrue, reason: 'Dosage "$dosage" should be valid');
        }
      });

      test('should be invalid with empty dosage string', () {
        final medication = Medication(
          id: 'empty-dosage-123',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          dosage: '',
        );

        expect(medication.isValid(), isTrue); // Empty string is valid (treated as null)
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final timestamp = DateTime(2025, 6, 10, 19, 15);
        final medication = Medication(
          id: 'med-123',
          timestamp: timestamp,
          dosage: '1/2 tablet',
          comments: 'Tambocor after episode',
        );

        final json = medication.toJson();

        expect(json['id'], equals('med-123'));
        expect(json['type'], equals('Medication'));
        expect(json['timestamp'], equals('2025-06-10T19:15:00.000'));
        expect(json['details']['dosage'], equals('1/2 tablet'));
        expect(json['details']['comments'], equals('Tambocor after episode'));
      });

      test('should serialize without optional fields', () {
        final timestamp = DateTime(2025, 6, 10, 19, 15);
        final medication = Medication(
          id: 'med-123',
          timestamp: timestamp,
        );

        final json = medication.toJson();

        expect(json['id'], equals('med-123'));
        expect(json['type'], equals('Medication'));
        expect(json['timestamp'], equals('2025-06-10T19:15:00.000'));
        expect(json['details'], isEmpty);
      });

      test('should not include empty dosage or comments', () {
        final timestamp = DateTime(2025, 6, 10, 19, 15);
        final medication = Medication(
          id: 'med-123',
          timestamp: timestamp,
          dosage: '',
          comments: '',
        );

        final json = medication.toJson();

        expect(json['details'], isEmpty);
      });
    });

    group('JSON deserialization', () {
      test('should deserialize from JSON with details', () {
        final json = {
          'id': 'med-123',
          'type': 'Medication',
          'timestamp': '2025-06-10T19:15:00.000Z',
          'details': {
            'dosage': '1/2 tablet',
            'comments': 'Tambocor after episode'
          }
        };

        final medication = Medication.fromJson(json);

        expect(medication.id, equals('med-123'));
        expect(medication.type, equals('Medication'));
        expect(medication.dosage, equals('1/2 tablet'));
        expect(medication.comments, equals('Tambocor after episode'));
      });

      test('should deserialize from JSON without details', () {
        final json = {
          'id': 'med-123',
          'type': 'Medication',
          'timestamp': '2025-06-10T19:15:00.000Z',
        };

        final medication = Medication.fromJson(json);

        expect(medication.id, equals('med-123'));
        expect(medication.type, equals('Medication'));
        expect(medication.dosage, isNull);
        expect(medication.comments, isNull);
      });

      test('should handle legacy CSV-style JSON format', () {
        final json = {
          'id': 'med-123',
          'type': 'Medication',
          'timestamp': '2025-06-10T19:15:00.000Z',
          'dosage': '1/2 tablet',
          'comments': 'Legacy format'
        };

        final medication = Medication.fromJson(json);

        expect(medication.id, equals('med-123'));
        expect(medication.dosage, equals('1/2 tablet'));
        expect(medication.comments, equals('Legacy format'));
      });
    });

    group('CSV factory method', () {
      test('should create from CSV data', () {
        final timestamp = DateTime(2025, 6, 10, 19, 15);
        final medication = Medication.fromCsv(
          id: 'csv-123',
          timestamp: timestamp,
          dosage: '1/2 tablet',
          comments: 'From CSV import',
        );

        expect(medication.id, equals('csv-123'));
        expect(medication.type, equals('Medication'));
        expect(medication.timestamp, equals(timestamp));
        expect(medication.dosage, equals('1/2 tablet'));
        expect(medication.comments, equals('From CSV import'));
      });

      test('should create from CSV with minimal data', () {
        final timestamp = DateTime(2025, 6, 10, 19, 15);
        final medication = Medication.fromCsv(
          id: 'csv-minimal-123',
          timestamp: timestamp,
        );

        expect(medication.id, equals('csv-minimal-123'));
        expect(medication.type, equals('Medication'));
        expect(medication.timestamp, equals(timestamp));
        expect(medication.dosage, isNull);
        expect(medication.comments, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = Medication(
          id: 'original-123',
          timestamp: DateTime(2025, 6, 10, 19, 15),
          dosage: '1/2 tablet',
          comments: 'Original',
        );

        final updated = original.copyWith(
          dosage: '1 tablet',
          comments: 'Updated',
        );

        expect(updated.id, equals('original-123')); // unchanged
        expect(updated.timestamp, equals(DateTime(2025, 6, 10, 19, 15))); // unchanged
        expect(updated.dosage, equals('1 tablet')); // changed
        expect(updated.comments, equals('Updated')); // changed
        expect(updated.type, equals('Medication')); // always Medication
      });

      test('should ignore type parameter', () {
        final original = Medication(
          id: 'test-123',
          timestamp: DateTime.now(),
        );

        final updated = original.copyWith(type: 'Different Type');

        expect(updated.type, equals('Medication'));
      });
    });

    group('Equality', () {
      test('should be equal when all fields match', () {
        final timestamp = DateTime(2025, 6, 10, 19, 15);
        final med1 = Medication(
          id: 'same-123',
          timestamp: timestamp,
          dosage: '1/2 tablet',
          comments: 'Same',
        );
        final med2 = Medication(
          id: 'same-123',
          timestamp: timestamp,
          dosage: '1/2 tablet',
          comments: 'Same',
        );

        expect(med1, equals(med2));
        expect(med1.hashCode, equals(med2.hashCode));
      });

      test('should not be equal when dosage differs', () {
        final timestamp = DateTime(2025, 6, 10, 19, 15);
        final med1 = Medication(
          id: 'test-123',
          timestamp: timestamp,
          dosage: '1/2 tablet',
        );
        final med2 = Medication(
          id: 'test-123',
          timestamp: timestamp,
          dosage: '1 tablet',
        );

        expect(med1, isNot(equals(med2)));
      });
    });

    group('String representation', () {
      test('should provide meaningful toString', () {
        final timestamp = DateTime(2025, 6, 10, 19, 15);
        final medication = Medication(
          id: 'test-123',
          timestamp: timestamp,
          dosage: '1/2 tablet',
          comments: 'Tambocor after episode',
        );

        final string = medication.toString();
        expect(string, contains('Medication'));
        expect(string, contains('test-123'));
        expect(string, contains('2025-06-10 19:15:00.000'));
        expect(string, contains('1/2 tablet'));
        expect(string, contains('Tambocor after episode'));
      });
    });
  });
}
