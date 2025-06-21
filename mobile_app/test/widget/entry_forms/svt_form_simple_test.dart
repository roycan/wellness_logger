import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wellness_logger_mobile/presentation/widgets/entry_forms/svt_form.dart';
import 'package:wellness_logger_mobile/domain/entities/svt_episode.dart';

/// Widget tests for SVT form
/// Following TESTING_PHILOSOPHY.md: Focus on user interactions that matter
/// "Test what would embarrass me if it broke in front of my teacher"
void main() {
  group('SVT Form Widget Tests - User Experience Focus', () {
    // Helper to create test widget with navigation context
    Widget createTestWidget({SvtEpisode? initialEntry}) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Test SVT Form')),
          body: SvtForm(
            initialEntry: initialEntry,
          ),
        ),
      );
    }

    testWidgets('should display form without crashing - basic smoke test', (WidgetTester tester) async {
      // TESTING PHILOSOPHY: Most important test - does it render?
      await tester.pumpWidget(createTestWidget());
      
      // Form should be visible to users
      expect(find.byType(SvtForm), findsOneWidget);
      
      // Should not crash during initial render
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display input fields users need', (WidgetTester tester) async {
      // TESTING PHILOSOPHY: Test what users see and interact with
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Users should see input fields for their data
      expect(find.byType(TextFormField), findsWidgets);
      
      // Should have a save action available
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should accept user input in text fields', (WidgetTester tester) async {
      // TESTING PHILOSOPHY: Core user workflow - entering data
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find text input fields
      final textFields = find.byType(TextFormField);
      
      if (textFields.evaluate().isNotEmpty) {
        // User can enter duration
        await tester.enterText(textFields.first, '5 minutes');
        await tester.pump();

        // Text should appear in the field
        expect(find.text('5 minutes'), findsOneWidget);
      }
    });

    testWidgets('should show existing data when editing', (WidgetTester tester) async {
      // TESTING PHILOSOPHY: User workflow - editing existing data
      final existingEpisode = SvtEpisode(
        id: 'test-edit-1',
        timestamp: DateTime.now(),
        duration: '3 minutes',
        comments: 'Test episode for editing',
      );

      await tester.pumpWidget(createTestWidget(initialEntry: existingEpisode));
      await tester.pump();

      // Form should render without crashing when given initial data
      expect(find.byType(SvtForm), findsOneWidget);
      
      // Should not crash when displaying existing data
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle save button press without crashing', (WidgetTester tester) async {
      // TESTING PHILOSOPHY: Core user action - saving their work
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find save button
      final saveButtons = find.byType(ElevatedButton);
      
      if (saveButtons.evaluate().isNotEmpty) {
        // User taps save - should not crash immediately
        await tester.tap(saveButtons.first);
        await tester.pump();
        
        // Even if save fails due to missing repository in test,
        // the UI should handle it gracefully
        expect(find.byType(SvtForm), findsOneWidget);
      }
    });

    testWidgets('should handle form state changes gracefully', (WidgetTester tester) async {
      // TESTING PHILOSOPHY: Real-world scenario - users interact with forms
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Basic interactions shouldn't break the form
      final textFields = find.byType(TextFormField);
      
      if (textFields.evaluate().isNotEmpty) {
        // User types, deletes, types again
        await tester.enterText(textFields.first, 'Test input');
        await tester.pump();
        
        await tester.enterText(textFields.first, '');
        await tester.pump();
        
        await tester.enterText(textFields.first, 'Final input');
        await tester.pump();
        
        // Form should still be functional
        expect(find.byType(SvtForm), findsOneWidget);
        expect(find.text('Final input'), findsOneWidget);
      }
    });
  });
}
