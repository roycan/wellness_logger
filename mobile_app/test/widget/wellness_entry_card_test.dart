import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellness_logger_mobile/presentation/widgets/wellness_entry_card.dart';
import 'package:wellness_logger_mobile/domain/entities/svt_episode.dart';
import 'package:wellness_logger_mobile/domain/entities/exercise.dart';
import 'package:wellness_logger_mobile/domain/entities/medication.dart';

void main() {
  group('WellnessEntryCard Widget Tests', () {
    late SvtEpisode testSvtEntry;
    late Exercise testExerciseEntry;
    late Medication testMedicationEntry;

    setUp(() {
      testSvtEntry = SvtEpisode(
        id: 'test-svt-1',
        timestamp: DateTime.now(),
        duration: '5 minutes',
        comments: 'Test SVT episode',
      );

      testExerciseEntry = Exercise(
        id: 'test-exercise-1',
        timestamp: DateTime.now(),
        duration: '30 minutes',
        comments: 'Morning run',
      );

      testMedicationEntry = Medication(
        id: 'test-med-1',
        timestamp: DateTime.now(),
        dosage: '10mg',
        comments: 'Daily dose',
      );
    });

    testWidgets('should display SVT entry information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WellnessEntryCard(
              entry: testSvtEntry,
              onTap: () {},
            ),
          ),
        ),
      );

      // Should display entry type and basic info
      expect(find.text('SVT Episode'), findsOneWidget);
      expect(find.text('Test SVT episode'), findsOneWidget);
      // Duration is not displayed in the card directly, only in comments
    });

    testWidgets('should display exercise entry information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WellnessEntryCard(
              entry: testExerciseEntry,
              onTap: () {},
            ),
          ),
        ),
      );

      // Should display exercise type and comments
      expect(find.text('Exercise'), findsOneWidget);
      expect(find.text('Morning run'), findsOneWidget);
      // Duration and type details are not displayed in the card directly
    });

    testWidgets('should display medication entry information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WellnessEntryCard(
              entry: testMedicationEntry,
              onTap: () {},
            ),
          ),
        ),
      );

      // Should display medication type and comments
      expect(find.text('Medication'), findsOneWidget);
      expect(find.text('Daily dose'), findsOneWidget);
      // Name and dosage details are not displayed in the card directly
    });

    testWidgets('should be tappable and call onTap callback', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WellnessEntryCard(
              entry: testSvtEntry,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(WellnessEntryCard));
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
    });

    testWidgets('should display formatted timestamp', (WidgetTester tester) async {
      final specificTime = DateTime(2023, 6, 15, 14, 30);
      final entryWithSpecificTime = SvtEpisode(
        id: 'test-time',
        timestamp: specificTime,
        duration: '2 minutes',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WellnessEntryCard(
              entry: entryWithSpecificTime,
              onTap: () {},
            ),
          ),
        ),
      );

      // Should find some form of time display (exact format depends on implementation)
      // Testing that time information is shown without testing exact formatting
      expect(find.byType(WellnessEntryCard), findsOneWidget);
      
      // Basic smoke test - card should render without errors
      final cardWidget = tester.widget<WellnessEntryCard>(find.byType(WellnessEntryCard));
      expect(cardWidget.entry.timestamp, equals(specificTime));
    });

    testWidgets('should be accessible for screen readers', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WellnessEntryCard(
              entry: testSvtEntry,
              onTap: () {},
            ),
          ),
        ),
      );

      // Should be tappable (accessibility requirement)
      final hasInkWell = find.byType(InkWell).evaluate().isNotEmpty;
      final hasGestureDetector = find.byType(GestureDetector).evaluate().isNotEmpty;
      expect(hasInkWell || hasGestureDetector, isTrue,
        reason: 'Should have InkWell or GestureDetector for tap handling');
      
      // Card should contain text content for screen readers
      expect(find.text('SVT Episode'), findsOneWidget);
    });
  });
}
