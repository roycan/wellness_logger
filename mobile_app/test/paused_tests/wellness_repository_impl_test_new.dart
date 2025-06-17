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
      registerFallbackValue(<WellnessEntry>[]);
      registerFallbackValue(<String>[]);
      registerFallbackValue('');
    });

    setUp(() {
      mockLocalDataSource = MockLocalDataSource();
      repository = WellnessRepositoryImpl(
        localDataSource: mockLocalDataSource,
      );
      testEntry = TestHelpers.createSampleSvtEpisode();
    });

    group('lifecycle', () {
      test('should initialize successfully', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.initialize();

        // Assert
        expect(result, isTrue);
        expect(repository.isReady, isTrue);
        verify(() => mockLocalDataSource.initialize()).called(1);
      });

      test('should dispose successfully', () async {
        // Act
        await repository.dispose();

        // Assert
        expect(repository.isReady, isFalse);
      });
    });

    group('createEntry', () {
      test('should create entry successfully when data is valid', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.saveEntry(any()))
            .thenAnswer((_) async => testEntry);
        
        await repository.initialize();

        // Act
        await repository.createEntry(testEntry);

        // Assert
        verify(() => mockLocalDataSource.saveEntry(testEntry)).called(1);
      });

      test('should throw StorageException when entry ID is empty', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        await repository.initialize();
        
        final invalidEntry = SvtEpisode(
          id: '',
          timestamp: DateTime.now(),
          comments: 'Test',
        );

        // Act & Assert
        expect(
          () => repository.createEntry(invalidEntry),
          throwsA(isA<StorageException>()),
        );
      });
    });

    group('getEntryById', () {
      test('should return entry when ID exists', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.getEntry(testEntry.id))
            .thenAnswer((_) async => testEntry);
        
        await repository.initialize();

        // Act
        final result = await repository.getEntryById(testEntry.id);

        // Assert
        expect(result, equals(testEntry));
        verify(() => mockLocalDataSource.getEntry(testEntry.id)).called(1);
      });

      test('should return null when ID does not exist', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.getEntry('nonexistent-id'))
            .thenAnswer((_) async => null);
        
        await repository.initialize();

        // Act
        final result = await repository.getEntryById('nonexistent-id');

        // Assert
        expect(result, isNull);
      });

      test('should throw StorageException when ID is empty', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        await repository.initialize();

        // Act & Assert
        expect(
          () => repository.getEntryById(''),
          throwsA(isA<StorageException>()),
        );
      });
    });

    group('getAllEntries', () {
      test('should return entries when successful', () async {
        // Arrange
        final entries = [testEntry];
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.getEntries(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => entries);
        
        await repository.initialize();

        // Act
        final result = await repository.getAllEntries();

        // Assert
        expect(result, equals(entries));
      });

      test('should throw StorageException when start date is after end date', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        await repository.initialize();

        final startDate = DateTime.now();
        final endDate = startDate.subtract(const Duration(days: 1));

        // Act & Assert
        expect(
          () => repository.getAllEntries(
            startDate: startDate,
            endDate: endDate,
          ),
          throwsA(isA<StorageException>()),
        );
      });

      test('should throw StorageException when limit is invalid', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        await repository.initialize();

        // Act & Assert
        expect(
          () => repository.getAllEntries(limit: 0),
          throwsA(isA<StorageException>()),
        );
      });

      test('should throw StorageException when offset is negative', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        await repository.initialize();

        // Act & Assert
        expect(
          () => repository.getAllEntries(offset: -1),
          throwsA(isA<StorageException>()),
        );
      });
    });

    group('updateEntry', () {
      test('should update entry successfully', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.updateEntry(any()))
            .thenAnswer((_) async => testEntry);
        
        await repository.initialize();

        // Act
        await repository.updateEntry(testEntry);

        // Assert
        verify(() => mockLocalDataSource.updateEntry(testEntry)).called(1);
      });
    });

    group('deleteEntry', () {
      test('should delete entry successfully when entry exists', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.deleteEntry(testEntry.id))
            .thenAnswer((_) async => true);
        
        await repository.initialize();

        // Act
        final result = await repository.deleteEntry(testEntry.id);

        // Assert
        expect(result, isTrue);
        verify(() => mockLocalDataSource.deleteEntry(testEntry.id)).called(1);
      });

      test('should return false when entry does not exist', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.deleteEntry('nonexistent-id'))
            .thenAnswer((_) async => false);
        
        await repository.initialize();

        // Act
        final result = await repository.deleteEntry('nonexistent-id');

        // Assert
        expect(result, isFalse);
      });
    });

    group('getAnalyticsData', () {
      test('should return analytics data successfully', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.getEntries(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => [testEntry]);
        
        await repository.initialize();

        // Act
        final result = await repository.getAnalyticsData();

        // Assert
        expect(result, isA<AnalyticsData>());
        expect(result.totalEntries, equals(1));
      });

      test('should throw StorageException when date range is invalid', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        await repository.initialize();

        final startDate = DateTime.now();
        final endDate = startDate.subtract(const Duration(days: 1));

        // Act & Assert
        expect(
          () => repository.getAnalyticsData(
            startDate: startDate,
            endDate: endDate,
          ),
          throwsA(isA<StorageException>()),
        );
      });
    });

    group('importFromJson', () {
      test('should import data successfully', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.importEntries(
              any(),
              overwriteExisting: any(named: 'overwriteExisting'),
            )).thenAnswer((_) async => {'added': 1, 'updated': 0, 'errors': 0});
        
        await repository.initialize();

        final jsonData = {
          'entries': [testEntry.toJson()],
        };

        // Act
        await repository.importFromJson(jsonData);

        // Assert
        verify(() => mockLocalDataSource.importEntries(
              any(),
              overwriteExisting: true,
            )).called(1);
      });

      test('should throw StorageException when JSON is empty', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        await repository.initialize();

        // Act & Assert
        expect(
          () => repository.importFromJson({}),
          throwsA(isA<StorageException>()),
        );
      });
    });

    group('exportToJson', () {
      test('should export data successfully', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.getEntries(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => [testEntry]);
        
        await repository.initialize();

        // Act
        final result = await repository.exportToJson();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['totalEntries'], equals(1));
        expect(result['entries'], isA<List>());
      });
    });

    group('getStorageInfo', () {
      test('should return storage info successfully', () async {
        // Arrange
        when(() => mockLocalDataSource.initialize())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.getStorageStats())
            .thenAnswer((_) async => {'totalEntries': 1, 'dbSize': 1024});
        
        await repository.initialize();

        // Act
        final result = await repository.getStorageInfo();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['isInitialized'], isTrue);
        expect(result['totalEntries'], equals(1));
      });
    });
  });
}
