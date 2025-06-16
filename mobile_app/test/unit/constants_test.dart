import 'package:flutter_test/flutter_test.dart';
import 'package:wellness_logger_mobile/core/constants/app_constants.dart';

/// Test suite for application constants.
/// 
/// These tests ensure that all constants are properly defined and maintain
/// expected values across app updates. Constants are critical for app
/// consistency and these tests prevent accidental changes.
void main() {
  group('AppConstants', () {
    group('App Metadata', () {
      test('should have valid app name', () {
        expect(AppConstants.appName, isNotEmpty);
        expect(AppConstants.appName, 'Wellness Logger');
      });
      
      test('should have valid app version', () {
        expect(AppConstants.appVersion, isNotEmpty);
        expect(AppConstants.appVersion, matches(RegExp(r'^\d+\.\d+\.\d+$')));
      });
      
      test('should have valid app description', () {
        expect(AppConstants.appDescription, isNotEmpty);
        expect(AppConstants.appDescription.length, lessThan(100));
      });
    });
    
    group('Database Configuration', () {
      test('should have valid database name', () {
        expect(AppConstants.databaseName, isNotEmpty);
        expect(AppConstants.databaseName, endsWith('.db'));
      });
      
      test('should have positive database version', () {
        expect(AppConstants.databaseVersion, greaterThan(0));
      });
      
      test('should have valid box names', () {
        expect(AppConstants.entriesBoxName, isNotEmpty);
        expect(AppConstants.settingsBoxName, isNotEmpty);
        expect(AppConstants.analyticsBoxName, isNotEmpty);
      });
    });
    
    group('UI Dimensions', () {
      test('should meet accessibility requirements', () {
        // Minimum touch target size for accessibility
        expect(AppConstants.minimumTouchTarget, greaterThanOrEqualTo(44.0));
      });
      
      test('should have consistent padding values', () {
        expect(AppConstants.smallPadding, lessThan(AppConstants.defaultPadding));
        expect(AppConstants.defaultPadding, lessThan(AppConstants.largePadding));
      });
      
      test('should have positive border radius values', () {
        expect(AppConstants.borderRadius, greaterThan(0));
        expect(AppConstants.smallBorderRadius, greaterThan(0));
        expect(AppConstants.smallBorderRadius, lessThan(AppConstants.borderRadius));
      });
    });
    
    group('Entry Types', () {
      test('should have all required entry types', () {
        expect(AppConstants.entryTypes, hasLength(3));
        expect(AppConstants.entryTypes, contains(AppConstants.entryTypeSVT));
        expect(AppConstants.entryTypes, contains(AppConstants.entryTypeExercise));
        expect(AppConstants.entryTypes, contains(AppConstants.entryTypeMedication));
      });
      
      test('should have valid entry type constants', () {
        expect(AppConstants.entryTypeSVT, isNotEmpty);
        expect(AppConstants.entryTypeExercise, isNotEmpty);
        expect(AppConstants.entryTypeMedication, isNotEmpty);
      });
      
      test('should have colors for all entry types', () {
        for (final entryType in AppConstants.entryTypes) {
          expect(AppConstants.entryTypeColors.containsKey(entryType), isTrue);
          expect(AppConstants.entryTypeColors[entryType], isNotNull);
        }
      });
    });
    
    group('Date Formats', () {
      test('should have valid date format patterns', () {
        expect(AppConstants.dateFormat, isNotEmpty);
        expect(AppConstants.timeFormat, isNotEmpty);
        expect(AppConstants.dateTimeFormat, isNotEmpty);
        expect(AppConstants.displayDateFormat, isNotEmpty);
        expect(AppConstants.displayDateTimeFormat, isNotEmpty);
      });
    });
    
    group('CSV Export Configuration', () {
      test('should have valid CSV filename', () {
        expect(AppConstants.csvFileName, isNotEmpty);
        expect(AppConstants.csvFileName, isNot(contains(' ')));
      });
      
      test('should have all required CSV headers', () {
        expect(AppConstants.csvHeaders, isNotEmpty);
        expect(AppConstants.csvHeaders, contains('Date'));
        expect(AppConstants.csvHeaders, contains('Time'));
        expect(AppConstants.csvHeaders, contains('Type'));
      });
    });
    
    group('Performance Configuration', () {
      test('should have reasonable performance limits', () {
        expect(AppConstants.maxEntriesPerPage, greaterThan(0));
        expect(AppConstants.maxEntriesPerPage, lessThan(1000)); // Reasonable limit
        expect(AppConstants.searchDebounceMs, greaterThan(0));
        expect(AppConstants.searchDebounceMs, lessThan(1000)); // Not too slow
      });
    });
    
    group('Validation Limits', () {
      test('should have reasonable validation limits', () {
        expect(AppConstants.maxCommentLength, greaterThan(0));
        expect(AppConstants.maxDurationMinutes, greaterThan(0));
      });
    });
    
    group('Quick Entry Defaults', () {
      test('should have defaults for all entry types', () {
        for (final entryType in AppConstants.entryTypes) {
          expect(AppConstants.quickEntryDefaults.containsKey(entryType), isTrue);
          expect(AppConstants.quickEntryDefaults[entryType], isNotEmpty);
        }
      });
    });
  });
  
  group('AppUrls', () {
    test('should have valid URL format', () {
      expect(AppUrls.privacyPolicy, startsWith('https://'));
      expect(AppUrls.termsOfService, startsWith('https://'));
      expect(AppUrls.githubRepo, startsWith('https://'));
    });
    
    test('should have valid email format', () {
      expect(AppUrls.supportEmail, contains('@'));
      expect(AppUrls.supportEmail, contains('.'));
    });
  });
  
  group('AppRegex', () {
    group('Duration Validation', () {
      test('should accept valid duration formats', () {
        final validDurations = [
          '5 minutes',
          '1.5 hours',
          '30 min',
          '2 hrs',
          '45 seconds',
          '10 sec',
        ];
        
        for (final duration in validDurations) {
          expect(AppRegex.duration.hasMatch(duration), isTrue,
              reason: 'Should accept: $duration');
        }
      });
      
      test('should reject invalid duration formats', () {
        final invalidDurations = [
          'invalid',
          '5',
          'minutes 5',
          '5 invalid',
          '',
        ];
        
        for (final duration in invalidDurations) {
          expect(AppRegex.duration.hasMatch(duration), isFalse,
              reason: 'Should reject: $duration');
        }
      });
    });
    
    group('Dosage Validation', () {
      test('should accept any non-empty text for flexible dosage input', () {
        final validDosages = [
          '1/2 tablet',
          '2.5 mg',
          '1 pill',
          '5 ml',
          '2 capsules',
          '3 drops',
          'half a tablet with food',
          'took one this morning',
          'usual dose',
          '100mg twice daily',
          'as needed',
          'skipped today',
        ];
        
        for (final dosage in validDosages) {
          expect(AppRegex.dosage.hasMatch(dosage), isTrue,
              reason: 'Should accept: $dosage');
        }
      });
      
      test('should reject only empty dosage', () {
        final invalidDosages = [
          '', // only empty string should be rejected
        ];
        
        for (final dosage in invalidDosages) {
          expect(AppRegex.dosage.hasMatch(dosage), isFalse,
              reason: 'Should reject: $dosage');
        }
      });
    });
    
    group('Time Format Validation', () {
      test('should accept valid time formats', () {
        final validTimes = [
          '09:30',
          '9:30',   // Single digit hour should be valid
          '23:59',
          '00:00',
          '12:00',
        ];
        
        for (final time in validTimes) {
          expect(AppRegex.timeFormat.hasMatch(time), isTrue,
              reason: 'Should accept: $time');
        }
      });
      
      test('should reject invalid time formats', () {
        final invalidTimes = [
          '24:00',
          '12:60',
          '12:5',  // Missing leading zero for minutes
          'invalid',
          '',
        ];
        
        for (final time in invalidTimes) {
          expect(AppRegex.timeFormat.hasMatch(time), isFalse,
              reason: 'Should reject: $time');
        }
      });
    });
  });
}
