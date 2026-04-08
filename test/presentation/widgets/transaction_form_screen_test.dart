import 'package:catat_cuan/presentation/screens/transaction_form_screen.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  // Initialize logger for tests
  setUpAll(() {
    AppLogger.initialize();
  });

  group('TransactionFormScreen', () {
    test('should be instantiatable without errors', () {
      // Arrange & Act - Verify the widget can be instantiated
      // This is a basic smoke test to ensure the widget compiles and has no obvious errors
      expect(() => const TransactionFormScreen(), returnsNormally);
    });

    test('should accept transactionToEdit parameter', () {
      // Arrange
      final transaction = TestFixtures.transactionLunch();

      // Act & Assert - Verify the widget accepts the parameter
      expect(
        () => TransactionFormScreen(transactionToEdit: transaction),
        returnsNormally,
      );
    });
  });
}
