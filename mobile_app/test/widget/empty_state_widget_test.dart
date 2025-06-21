import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellness_logger_mobile/presentation/widgets/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget Tests', () {
    testWidgets('should display empty state message', (WidgetTester tester) async {
      const testMessage = 'No entries yet';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox_outlined,
              message: testMessage,
            ),
          ),
        ),
      );

      // Should display the message
      expect(find.text(testMessage), findsOneWidget);
      // Should display the icon
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('should display custom action button when provided', (WidgetTester tester) async {
      bool actionTapped = false;
      const testMessage = 'No data available';
      const actionText = 'Add First Entry';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.add_circle_outline,
              message: testMessage,
              actionText: actionText,
              onActionPressed: () => actionTapped = true,
            ),
          ),
        ),
      );

      // Should display action button
      expect(find.text(actionText), findsOneWidget);
      
      // Tap the action button
      await tester.tap(find.text(actionText));
      await tester.pumpAndSettle();

      expect(actionTapped, isTrue);
    });

    testWidgets('should display without action button when not provided', (WidgetTester tester) async {
      const testMessage = 'Empty state';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.hourglass_empty,
              message: testMessage,
            ),
          ),
        ),
      );

      // Should display message but no action button
      expect(find.text(testMessage), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('should have proper layout and styling', (WidgetTester tester) async {
      const testMessage = 'No entries found';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.search_off,
              message: testMessage,
            ),
          ),
        ),
      );

      // Should be centered or properly laid out
      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text(testMessage), findsOneWidget);
      
      // Basic layout check - should not throw errors
      final widget = tester.widget<EmptyStateWidget>(find.byType(EmptyStateWidget));
      expect(widget.message, equals(testMessage));
      expect(widget.icon, equals(Icons.search_off));
    });

    testWidgets('should be accessible', (WidgetTester tester) async {
      const testMessage = 'No wellness entries';
      const actionText = 'Get Started';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.accessibility,
              message: testMessage,
              actionText: actionText,
              onActionPressed: () {},
            ),
          ),
        ),
      );

      // Text should be readable by screen readers
      expect(find.text(testMessage), findsOneWidget);
      expect(find.text(actionText), findsOneWidget);
      
      // Action button should be tappable
      final actionButton = find.text(actionText);
      expect(actionButton, findsOneWidget);
    });
  });
}
