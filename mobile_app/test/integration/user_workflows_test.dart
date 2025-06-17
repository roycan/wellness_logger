import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellness_logger_mobile/data/datasources/hive_local_data_source.dart';
import 'package:wellness_logger_mobile/data/repositories/wellness_repository_impl.dart';
import 'package:wellness_logger_mobile/domain/entities/svt_episode.dart';
import 'package:wellness_logger_mobile/domain/entities/exercise.dart';
import 'package:wellness_logger_mobile/domain/entities/medication.dart';
import 'package:wellness_logger_mobile/domain/repositories/wellness_repository_simple.dart';

/// Integration tests that test the wellness logger as users would experience it.
/// 
/// These tests focus on user workflows rather than implementation details:
/// - Can users save health entries?
/// - Can they retrieve their data later?
/// - Can they export their data?
/// 
/// Following our Testing Philosophy: Test what would embarrass us if it broke.
void main() {
  group('Wellness Logger Integration Tests', () {
    late WellnessRepository repository;
    late HiveLocalDataSource dataSource;
    late Directory tempDir;

    setUp(() async {
      // Create a temporary directory for test data
      tempDir = await Directory.systemTemp.createTemp('wellness_test_');
      
      // Create real instances for integration testing with test directory
      dataSource = HiveLocalDataSource(testDirectory: tempDir.path);
      repository = WellnessRepositoryImpl(localDataSource: dataSource);
      
      // Initialize the system
      await repository.initialize();
    });

    tearDown(() async {
      // Clean up after each test - handle case where repository might be disposed
      try {
        await repository.clearAllEntries();
        await repository.dispose();
      } catch (e) {
        // Repository might already be disposed in some tests (like persistence test)
        // This is okay, just continue with cleanup
      }
      
      // Clean up temporary directory
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('Core User Workflows', () {
      test('User can save and retrieve an SVT episode', () async {
        // This is what users care about: Can I log my SVT episode and see it later?
        
        // Arrange - Create a realistic SVT episode
        final episode = SvtEpisode(
          id: 'test-episode-1',
          timestamp: DateTime.now(),
          comments: 'Heart racing after climbing stairs, lasted about 5 minutes',
          duration: '5 minutes',
        );

        // Act - User saves the episode
        await repository.createEntry(episode);
        
        // User retrieves their episode
        final retrieved = await repository.getEntryById(episode.id);
        
        // Assert - The episode should be exactly what they saved
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals(episode.id));
        expect(retrieved.type, equals('SVT Episode'));
        expect(retrieved.comments, equals(episode.comments));
        
        if (retrieved is SvtEpisode) {
          expect(retrieved.duration, equals(episode.duration));
        }
      });

      test('User can save multiple entries and get them all back', () async {
        // Real scenario: User logs various health activities over time
        
        // Arrange - Create realistic entries
        final entries = [
          SvtEpisode(
            id: 'episode-1',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            comments: 'Episode during work meeting',
            duration: '3 minutes',
          ),
          Exercise(
            id: 'exercise-1',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            comments: 'Morning walk in the park',
            duration: '30 minutes',
          ),
          Medication(
            id: 'med-1',
            timestamp: DateTime.now(),
            comments: 'Took beta blocker as prescribed',
            dosage: '25mg',
          ),
        ];

        // Act - User saves all their entries
        for (final entry in entries) {
          await repository.createEntry(entry);
        }
        
        // User wants to see all their entries
        final allEntries = await repository.getAllEntries();
        
        // Assert - User should see all their data
        expect(allEntries.length, equals(3));
        
        // Verify each type is present
        final types = allEntries.map((e) => e.type).toSet();
        expect(types, contains('SVT Episode'));
        expect(types, contains('Exercise'));
        expect(types, contains('Medication'));
      });

      test('User can export their data for their doctor', () async {
        // Real scenario: User needs to share their health data with healthcare provider
        
        // Arrange - User has some health data
        final episode = SvtEpisode(
          id: 'episode-for-doctor',
          timestamp: DateTime.now(),
          comments: 'Severe episode, need to discuss with cardiologist',
          duration: '10 minutes',
        );
        
        await repository.createEntry(episode);
        
        // Act - User exports their data
        final exportData = await repository.exportToJson();
        
        // Assert - Export should contain the data in a useful format
        expect(exportData, isA<Map<String, dynamic>>());
        expect(exportData['totalEntries'], equals(1));
        expect(exportData['entries'], isA<List>());
        
        final entries = exportData['entries'] as List;
        expect(entries.length, equals(1));
        
        final entryData = entries.first as Map<String, dynamic>;
        expect(entryData['id'], equals(episode.id));
        expect(entryData['type'], equals('SVT Episode'));
      });

      test('User data persists between app sessions', () async {
        // Real scenario: User closes app and reopens it later
        
        // Arrange - User saves data in "first session"
        final episode = SvtEpisode(
          id: 'persistent-episode',
          timestamp: DateTime.now(),
          comments: 'This should persist between sessions',
          duration: '2 minutes',
        );
        
        await repository.createEntry(episode);
        
        // Act - Simulate app restart by disposing and reinitializing
        await repository.dispose();
        
        final newDataSource = HiveLocalDataSource(testDirectory: tempDir.path);
        final newRepository = WellnessRepositoryImpl(localDataSource: newDataSource);
        await newRepository.initialize();
        
        // User opens app and looks for their data
        final retrievedEntry = await newRepository.getEntryById(episode.id);
        
        // Assert - Data should still be there
        expect(retrievedEntry, isNotNull);
        expect(retrievedEntry!.id, equals(episode.id));
        expect(retrievedEntry.comments, equals(episode.comments));
        
        // Cleanup
        await newRepository.clearAllEntries();
        await newRepository.dispose();
      });
    });

    group('Error Scenarios Users Might Encounter', () {
      test('User tries to save entry with empty ID - should get helpful error', () async {
        // Real scenario: Bug in app creates invalid entry
        
        final invalidEntry = SvtEpisode(
          id: '', // Empty ID
          timestamp: DateTime.now(),
          comments: 'This should fail gracefully',
        );
        
        // Act & Assert - Should fail gracefully with meaningful error
        expect(
          () => repository.createEntry(invalidEntry),
          throwsA(isA<Exception>()),
        );
      });

      test('User looks for non-existent entry - should return null gracefully', () async {
        // Real scenario: User tries to access deleted or never-existed entry
        
        // Act
        final result = await repository.getEntryById('definitely-does-not-exist');
        
        // Assert - Should handle gracefully
        expect(result, isNull);
      });
    });

    group('Analytics Users Care About', () {
      test('User can see basic statistics about their health data', () async {
        // Real scenario: User wants to understand their health patterns
        
        // Arrange - User has some health history
        await repository.createEntry(SvtEpisode(
          id: 'episode-1',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          comments: 'Stress-related episode',
          duration: '5 minutes',
        ));
        
        await repository.createEntry(Exercise(
          id: 'exercise-1',
          timestamp: DateTime.now(),
          comments: 'Light walking after episode',
          duration: '20 minutes',
        ));
        
        // Act - User views their analytics
        final analytics = await repository.getAnalyticsData();
        
        // Assert - Should provide meaningful insights
        expect(analytics.totalEntries, equals(2));
        expect(analytics.totalSvtEpisodes, equals(1));
        expect(analytics.totalExerciseSessions, equals(1));
        expect(analytics.insights, isNotEmpty);
      });
    });
  });
}
