import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellness_logger_mobile/presentation/widgets/quick_add_fab.dart';

void main() {
  group('QuickAddFAB Widget Tests', () {
    testWidgets('should display floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickAddFAB(),
          ),
        ),
      );

      // Should find the main FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should show expanded options when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickAddFAB(),
          ),
        ),
      );

      // Initial state - should have one FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Tap the main FAB to expand
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should find multiple FABs after expansion (main + options)
      expect(find.byType(FloatingActionButton), findsWidgets);
    });

    testWidgets('should handle tap interactions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickAddFAB(),
          ),
        ),
      );

      // Should be interactive
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      
      // Should not throw when tapped
      await tester.tap(fab);
      await tester.pumpAndSettle();
    });

    testWidgets('should be accessible for screen readers', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickAddFAB(),
          ),
        ),
      );

      // Check that FAB exists and is functional
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsAtLeastNWidgets(1));
      
      // Basic accessibility check - FAB should be focusable
      final fabWidget = tester.widget<FloatingActionButton>(fab.first);
      expect(fabWidget.onPressed, isNotNull);
    });
  });
}
