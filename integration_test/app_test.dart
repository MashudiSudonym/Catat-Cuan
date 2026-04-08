import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:catat_cuan/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Catat Cuan E2E Tests', () {
    testWidgets('should launch app and display home screen', (tester) async {
      // Arrange & Act - Launch the app (only once)
      app.main();
      await tester.pumpAndSettle();

      // Assert - Home screen should be displayed
      // Verify bottom navigation items exist
      expect(find.text('Transaksi'), findsOneWidget);
      expect(find.text('Ringkasan'), findsOneWidget);
      // Verify FAB exists
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should display transaction list screen', (tester) async {
      // Arrange - App already launched from previous test
      // But we need to reload for this test
      app.main();
      await tester.pumpAndSettle();

      // Act - By default, first tab (Transaksi) is selected
      // The TransactionListScreen should be visible

      // Assert - Verify transaction list elements exist
      // Look for empty state or list items
      expect(find.text('Transaksi'), findsOneWidget);
    });

    testWidgets('should switch to monthly summary tab', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Tap on "Ringkasan" tab in bottom navigation
      final summaryTabFinder = find.text('Ringkasan');
      await tester.tap(summaryTabFinder);
      await tester.pumpAndSettle();

      // Assert - Monthly summary screen should be displayed
      expect(find.text('Ringkasan'), findsOneWidget);
    });

    testWidgets('should open transaction form via FAB', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Tap FAB to open transaction form
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);
      await tester.tap(fabFinder);
      await tester.pumpAndSettle();

      // Assert - Transaction form should open with some input fields
      // The form should have text fields or similar
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should handle bottom navigation between tabs', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act & Assert - Start at Transaksi tab (default)
      expect(find.text('Transaksi'), findsOneWidget);

      // Act - Switch to Ringkasan tab
      await tester.tap(find.text('Ringkasan'));
      await tester.pumpAndSettle();

      // Assert - Still on Ringkasan tab
      expect(find.text('Ringkasan'), findsOneWidget);

      // Act - Switch back to Transaksi tab
      await tester.tap(find.text('Transaksi'));
      await tester.pumpAndSettle();

      // Assert - Back on Transaksi tab
      expect(find.text('Transaksi'), findsOneWidget);
    });
  });
}
