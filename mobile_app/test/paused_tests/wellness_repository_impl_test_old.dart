import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../lib/data/datasources/local_data_source.dart';
import '../../../lib/data/datasources/storage_exception.dart';
import '../../../lib/data/repositories/wellness_repository_impl.dart';
import '../../../lib/domain/entities/analytics_data.dart';
import '../../../lib/domain/entities/svt_episode.dart';
import '../../../lib/domain/entities/wellness_entry.dart';
import '../../../lib/domain/repositories/wellness_repository_simple.dart';
import '../../helpers/test_helpers.dart';

class MockLocalDataSource extends Mock implements LocalDataSource {}

void main() {
  group('WellnessRepositoryImpl', () {
    late WellnessRepository repository;
    late MockLocalDataSource mockLocalDataSource;
    late SvtEpisode testEntry;

    setUpAll(() {
      registerFallbackValue(DateTime.now());
      registerFallbackValue({});
      registerFallbackValue('');
    });

    setUp(() {
      mockLocalDataSource = MockLocalDataSource();
      repository = WellnessRepositoryImpl(
        localDataSource: mockLocalDataSource,
      );
      testEntry = TestHelpers.createSampleSvtEpisode();
    });

    group('createEntry', () {
      test('should create entry successfully when data is valid', () async {
        // Arrange
        when(() => mockLocalDataSource.createEntry(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.createEntry(testEntry);

        // Assert
        verify(() => mockLocalDataSource.createEntry(testEntry)).called(1);
      });

      test('should throw StorageException when entry ID is empty', () async {
        // Arrange
        final invalidEntry = SvtEpisode(
          id: '', // Empty ID
          timestamp: DateTime.now(),
          duration: Duration(minutes: 5),
          severity: 3,
          triggers: ['stress'],
          notes: 'Test episode',
        );

        // Act & Assert
        expect(
          () => repository.createEntry(invalidEntry),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.invalidData)
              .having((e) => e.message, 'message', contains('Entry ID cannot be empty'))),
        );

        verifyNever(() => mockLocalDataSource.createEntry(any()));
      });

      test('should throw StorageException when timestamp is in future', () async {
        // Arrange
        final futureEntry = SvtEpisode(
          id: 'test-id',
          timestamp: DateTime.now().add(Duration(days: 1)), // Future timestamp
          duration: Duration(minutes: 5),
          severity: 3,
          triggers: ['stress'],
          notes: 'Test episode',
        );

        // Act & Assert
        expect(
          () => repository.createEntry(futureEntry),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.invalidData)
              .having((e) => e.message, 'message', contains('timestamp cannot be in the future'))),
        );

        verifyNever(() => mockLocalDataSource.createEntry(any()));
      });

      test('should re-throw StorageException from data source', () async {
        // Arrange
        final storageException = StorageException(
          'Database error',
          type: StorageExceptionType.databaseError,
        );
        when(() => mockLocalDataSource.createEntry(any()))
            .thenThrow(storageException);

        // Act & Assert
        expect(
          () => repository.createEntry(testEntry),
          throwsA(same(storageException)),
        );
      });

      test('should wrap unexpected exceptions in StorageException', () async {
        // Arrange
        when(() => mockLocalDataSource.createEntry(any()))
            .thenThrow(Exception('Unexpected error'));

        // Act & Assert
        expect(
          () => repository.createEntry(testEntry),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.operationFailed)
              .having((e) => e.message, 'message', contains('Failed to create entry'))),
        );
      });
    });

    group('getEntry', () {
      test('should return entry when found', () async {
        // Arrange
        when(() => mockLocalDataSource.getEntry(testEntry.id))
            .thenAnswer((_) async => testEntry);

        // Act
        final result = await repository.getEntry(testEntry.id);

        // Assert
        expect(result, equals(testEntry));
        verify(() => mockLocalDataSource.getEntry(testEntry.id)).called(1);
      });

      test('should return null when entry not found', () async {
        // Arrange
        when(() => mockLocalDataSource.getEntry(any()))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getEntry('nonexistent-id');

        // Assert
        expect(result, isNull);
      });

      test('should throw StorageException when ID is empty', () async {
        // Act & Assert
        expect(
          () => repository.getEntry(''),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.invalidData)
              .having((e) => e.message, 'message', contains('Entry ID cannot be empty'))),
        );

        verifyNever(() => mockLocalDataSource.getEntry(any()));
      });
    });

    group('getAllEntries', () {
      test('should return entries with valid parameters', () async {
        // Arrange
        final entries = [testEntry];
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        
        when(() => mockLocalDataSource.getAllEntries(
              startDate: startDate,
              endDate: endDate,
              entryType: 'svt_episode',
              limit: 10,
              offset: 0,
            )).thenAnswer((_) async => entries);

        // Act
        final result = await repository.getAllEntries(
          startDate: startDate,
          endDate: endDate,
          entryType: 'svt_episode',
          limit: 10,
          offset: 0,
        );

        // Assert
        expect(result, equals(entries));
      });

      test('should throw StorageException when start date is after end date', () async {
        // Arrange
        final startDate = DateTime(2024, 2, 1);
        final endDate = DateTime(2024, 1, 1); // Before start date

        // Act & Assert
        expect(
          () => repository.getAllEntries(
            startDate: startDate,
            endDate: endDate,
          ),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.invalidData)
              .having((e) => e.message, 'message', contains('Start date cannot be after end date'))),
        );
      });

      test('should throw StorageException when limit is invalid', () async {
        // Act & Assert
        expect(
          () => repository.getAllEntries(limit: 0),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.invalidData)
              .having((e) => e.message, 'message', contains('Limit must be greater than 0'))),
        );
      });

      test('should throw StorageException when offset is negative', () async {
        // Act & Assert
        expect(
          () => repository.getAllEntries(offset: -1),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.invalidData)
              .having((e) => e.message, 'message', contains('Offset cannot be negative'))),
        );
      });
    });

    group('updateEntry', () {
      test('should update entry successfully when it exists', () async {
        // Arrange
        when(() => mockLocalDataSource.getEntry(testEntry.id))
            .thenAnswer((_) async => testEntry);
        when(() => mockLocalDataSource.updateEntry(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.updateEntry(testEntry);

        // Assert
        verify(() => mockLocalDataSource.getEntry(testEntry.id)).called(1);
        verify(() => mockLocalDataSource.updateEntry(testEntry)).called(1);
      });

      test('should throw StorageException when entry not found', () async {
        // Arrange
        when(() => mockLocalDataSource.getEntry(testEntry.id))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => repository.updateEntry(testEntry),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.entryNotFound)
              .having((e) => e.message, 'message', contains('Entry with ID ${testEntry.id} not found'))),
        );

        verifyNever(() => mockLocalDataSource.updateEntry(any()));
      });
    });

    group('deleteEntry', () {
      test('should delete entry successfully when it exists', () async {
        // Arrange
        when(() => mockLocalDataSource.getEntry(testEntry.id))
            .thenAnswer((_) async => testEntry);
        when(() => mockLocalDataSource.deleteEntry(testEntry.id))
            .thenAnswer((_) async {});

        // Act
        await repository.deleteEntry(testEntry.id);

        // Assert
        verify(() => mockLocalDataSource.getEntry(testEntry.id)).called(1);
        verify(() => mockLocalDataSource.deleteEntry(testEntry.id)).called(1);
      });

      test('should throw StorageException when entry not found', () async {
        // Arrange
        when(() => mockLocalDataSource.getEntry(testEntry.id))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => repository.deleteEntry(testEntry.id),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.entryNotFound)
              .having((e) => e.message, 'message', contains('Entry with ID ${testEntry.id} not found'))),
        );

        verifyNever(() => mockLocalDataSource.deleteEntry(any()));
      });

      test('should throw StorageException when ID is empty', () async {
        // Act & Assert
        expect(
          () => repository.deleteEntry(''),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.invalidData)
              .having((e) => e.message, 'message', contains('Entry ID cannot be empty'))),
        );
      });
    });

    group('getAnalyticsData', () {
      test('should return analytics data with valid date range', () async {
        // Arrange
        final analyticsData = TestHelpers.createSampleAnalyticsData();
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        
        when(() => mockLocalDataSource.getAnalyticsData(
              startDate: startDate,
              endDate: endDate,
            )).thenAnswer((_) async => analyticsData);

        // Act
        final result = await repository.getAnalyticsData(
          startDate: startDate,
          endDate: endDate,
        );

        // Assert
        expect(result, equals(analyticsData));
      });

      test('should throw StorageException when start date is after end date', () async {
        // Arrange
        final startDate = DateTime(2024, 2, 1);
        final endDate = DateTime(2024, 1, 1);

        // Act & Assert
        expect(
          () => repository.getAnalyticsData(
            startDate: startDate,
            endDate: endDate,
          ),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.invalidData)),
        );
      });
    });

    group('importFromJson', () {
      test('should import valid JSON data successfully', () async {
        // Arrange
        final jsonData = {
          'entries': [
            TestHelpers.createSampleSvtEpisode().toJson(),
          ],
        };
        
        when(() => mockLocalDataSource.importFromJson(jsonData))
            .thenAnswer((_) async {});

        // Act
        await repository.importFromJson(jsonData);

        // Assert
        verify(() => mockLocalDataSource.importFromJson(jsonData)).called(1);
      });

      test('should throw StorageException when JSON data is empty', () async {
        // Act & Assert
        expect(
          () => repository.importFromJson({}),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.invalidData)
              .having((e) => e.message, 'message', contains('JSON data cannot be empty'))),
        );
      });

      test('should throw StorageException when entries field is missing', () async {
        // Arrange
        final invalidData = {'version': '1.0'};

        // Act & Assert
        expect(
          () => repository.importFromJson(invalidData),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.invalidData)
              .having((e) => e.message, 'message', contains('Import data must contain "entries" field'))),
        );
      });

      test('should throw StorageException when entries is not a list', () async {
        // Arrange
        final invalidData = {'entries': 'not a list'};

        // Act & Assert
        expect(
          () => repository.importFromJson(invalidData),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.invalidData)
              .having((e) => e.message, 'message', contains('Entries field must be a list'))),
        );
      });

      test('should throw StorageException when entry is missing required fields', () async {
        // Arrange
        final invalidData = {
          'entries': [
            {'id': 'test'}, // Missing timestamp and type
          ],
        };

        // Act & Assert
        expect(
          () => repository.importFromJson(invalidData),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.invalidData)
              .having((e) => e.message, 'message', contains('missing required field'))),
        );
      });
    });

    group('exportToJson', () {
      test('should export data with valid date range', () async {
        // Arrange
        final exportData = {
          'version': '1.0',
          'entries': [TestHelpers.createSampleSvtEpisode().toJson()],
        };
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        
        when(() => mockLocalDataSource.exportToJson(
              startDate: startDate,
              endDate: endDate,
              entryType: 'svt_episode',
            )).thenAnswer((_) async => exportData);

        // Act
        final result = await repository.exportToJson(
          startDate: startDate,
          endDate: endDate,
          entryType: 'svt_episode',
        );

        // Assert
        expect(result, equals(exportData));
      });

      test('should throw StorageException when start date is after end date', () async {
        // Arrange
        final startDate = DateTime(2024, 2, 1);
        final endDate = DateTime(2024, 1, 1);

        // Act & Assert
        expect(
          () => repository.exportToJson(
            startDate: startDate,
            endDate: endDate,
          ),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.invalidData)),
        );
      });
    });

    group('error handling', () {
      test('should wrap all unexpected exceptions in StorageException', () async {
        // Arrange
        when(() => mockLocalDataSource.getStorageInfo())
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getStorageInfo(),
          throwsA(isA<StorageException>()
              .having((e) => e.type, 'type', StorageExceptionType.operationFailed)
              .having((e) => e.originalError, 'originalError', isA<Exception>())),
        );
      });

      test('should preserve StorageException from data source', () async {
        // Arrange
        final originalException = StorageException(
          'Original error',
          type: StorageExceptionType.databaseError,
        );
        when(() => mockLocalDataSource.getStorageInfo())
            .thenThrow(originalException);

        // Act & Assert
        expect(
          () => repository.getStorageInfo(),
          throwsA(same(originalException)),
        );
      });
    });
  });
}
