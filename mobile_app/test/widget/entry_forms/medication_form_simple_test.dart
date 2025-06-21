import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellness_logger_mobile/presentation/widgets/entry_forms/medication_form.dart';
import 'package:wellness_logger_mobile/domain/entities/medication.dart';

void main() {
  group('Medication Form Widget Tests', () {
    // Simple widget tests without service locator dependencies

    testWidgets('should display medication form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicationForm(),
          ),
        ),
      );

      // Verify medication-specific fields are present
      expect(find.text('Dosage *'), findsOneWidget);
      expect(find.text('Comments (Optional)'), findsOneWidget);
    });

    testWidgets('should show save button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicationForm(),
          ),
        ),
      );

      expect(find.text('Save Medication'), findsOneWidget);
    });

    testWidgets('should display with existing medication data', (WidgetTester tester) async {
      final medication = Medication(
        id: 'test-medication',
        timestamp: DateTime.now(),
        dosage: '50mg',
        comments: 'Taken with breakfast',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicationForm(initialEntry: medication),
          ),
        ),
      );

      await tester.pump();

      // Should show existing data
      expect(find.text('50mg'), findsOneWidget);
      expect(find.text('Taken with breakfast'), findsOneWidget);
    });

    testWidgets('should allow editing dosage', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicationForm(),
          ),
        ),
      );

      final dosageField = find.widgetWithText(TextFormField, 'Dosage *').first;
      await tester.enterText(dosageField, '100mg');
      await tester.pump();

      expect(find.text('100mg'), findsOneWidget);
    });

    testWidgets('should allow editing comments', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicationForm(),
          ),
        ),
      );

      final commentsField = find.widgetWithText(TextFormField, 'Comments (Optional)').first;
      await tester.enterText(commentsField, 'Helps with blood pressure');
      await tester.pump();

      expect(find.text('Helps with blood pressure'), findsOneWidget);
    });
  });
}
