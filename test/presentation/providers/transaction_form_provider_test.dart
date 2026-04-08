import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/presentation/providers/transaction/transaction_form_provider.dart';
import 'package:catat_cuan/presentation/providers/usecases/transaction_usecase_providers.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_fixtures.dart';
import '../presentation_mocks.mocks.dart';

void main() {
  // Initialize logger for tests
  setUpAll(() {
    AppLogger.initialize();
  });

  group('TransactionFormNotifier', () {
    test('should validate nominal and set validation error for invalid amount', () {
      // Arrange
      final mockAddUseCase = MockAddTransactionUseCase();
      final mockUpdateUseCase = MockUpdateTransactionUseCase();

      final container = ProviderContainer(
        overrides: [
          addTransactionUseCaseProvider.overrideWithValue(mockAddUseCase),
          updateTransactionUseCaseProvider.overrideWithValue(mockUpdateUseCase),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(transactionFormProvider.notifier);

      // Act - Set invalid nominal (zero)
      notifier.setNominal(0);

      // Assert
      final state = container.read(transactionFormProvider);
      expect(state.validationErrors, contains('nominal'));
      expect(state.validationErrors['nominal'], equals('Nominal harus lebih dari 0'));
      expect(state.nominal, equals(0));
    });

    test('should clear validation error when valid nominal is set', () {
      // Arrange
      final mockAddUseCase = MockAddTransactionUseCase();
      final mockUpdateUseCase = MockUpdateTransactionUseCase();

      final container = ProviderContainer(
        overrides: [
          addTransactionUseCaseProvider.overrideWithValue(mockAddUseCase),
          updateTransactionUseCaseProvider.overrideWithValue(mockUpdateUseCase),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(transactionFormProvider.notifier);

      // Act - First set invalid, then valid
      notifier.setNominal(0);
      expect(container.read(transactionFormProvider).validationErrors, contains('nominal'));

      notifier.setNominal(50000);

      // Assert
      final state = container.read(transactionFormProvider);
      expect(state.validationErrors, isEmpty);
      expect(state.nominal, equals(50000));
    });

    test('should load transaction data for editing', () {
      // Arrange
      final mockAddUseCase = MockAddTransactionUseCase();
      final mockUpdateUseCase = MockUpdateTransactionUseCase();

      final container = ProviderContainer(
        overrides: [
          addTransactionUseCaseProvider.overrideWithValue(mockAddUseCase),
          updateTransactionUseCaseProvider.overrideWithValue(mockUpdateUseCase),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(transactionFormProvider.notifier);
      final transaction = TestFixtures.transactionLunch();

      // Act
      notifier.loadForEdit(transaction);

      // Assert
      final state = container.read(transactionFormProvider);
      expect(state.nominal, equals(transaction.amount));
      expect(state.type, equals(transaction.type));
      expect(state.categoryId, equals(transaction.categoryId));
      expect(state.note, equals(transaction.note));
      expect(state.isEditMode, isTrue);
      expect(state.editingTransaction, equals(transaction));
    });

    test('should set date and time correctly', () {
      // Arrange
      final mockAddUseCase = MockAddTransactionUseCase();
      final mockUpdateUseCase = MockUpdateTransactionUseCase();

      final container = ProviderContainer(
        overrides: [
          addTransactionUseCaseProvider.overrideWithValue(mockAddUseCase),
          updateTransactionUseCaseProvider.overrideWithValue(mockUpdateUseCase),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(transactionFormProvider.notifier);
      final testDate = DateTime(2026, 3, 18);
      final testTime = DateTime(2026, 3, 18, 14, 30);

      // Act
      notifier.setDate(testDate);
      notifier.setTime(testTime);

      // Assert
      final state = container.read(transactionFormProvider);
      expect(state.date, equals(testDate));
      expect(state.time, equals(testTime));
      expect(state.validationErrors, isEmpty);
    });

    test('should validate category and set error for null category', () {
      // Arrange
      final mockAddUseCase = MockAddTransactionUseCase();
      final mockUpdateUseCase = MockUpdateTransactionUseCase();

      final container = ProviderContainer(
        overrides: [
          addTransactionUseCaseProvider.overrideWithValue(mockAddUseCase),
          updateTransactionUseCaseProvider.overrideWithValue(mockUpdateUseCase),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(transactionFormProvider.notifier);

      // Act - Set null category
      notifier.setCategory(null);

      // Assert
      final state = container.read(transactionFormProvider);
      expect(state.validationErrors, contains('categoryId'));
      expect(state.validationErrors['categoryId'], equals('Kategori wajib dipilih'));
    });

    test('should clear validation error when valid category is set', () {
      // Arrange
      final mockAddUseCase = MockAddTransactionUseCase();
      final mockUpdateUseCase = MockUpdateTransactionUseCase();

      final container = ProviderContainer(
        overrides: [
          addTransactionUseCaseProvider.overrideWithValue(mockAddUseCase),
          updateTransactionUseCaseProvider.overrideWithValue(mockUpdateUseCase),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(transactionFormProvider.notifier);

      // Act - First set null, then valid category
      notifier.setCategory(null);
      expect(container.read(transactionFormProvider).validationErrors, contains('categoryId'));

      notifier.setCategory(1);

      // Assert
      final state = container.read(transactionFormProvider);
      expect(state.validationErrors, isEmpty);
      expect(state.categoryId, equals(1));
    });

    test('should set transaction type', () {
      // Arrange
      final mockAddUseCase = MockAddTransactionUseCase();
      final mockUpdateUseCase = MockUpdateTransactionUseCase();

      final container = ProviderContainer(
        overrides: [
          addTransactionUseCaseProvider.overrideWithValue(mockAddUseCase),
          updateTransactionUseCaseProvider.overrideWithValue(mockUpdateUseCase),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(transactionFormProvider.notifier);

      // Act
      notifier.setType(TransactionType.income);

      // Assert
      final state = container.read(transactionFormProvider);
      expect(state.type, equals(TransactionType.income));
    });

    test('should set note and clear it when empty', () {
      // Arrange
      final mockAddUseCase = MockAddTransactionUseCase();
      final mockUpdateUseCase = MockUpdateTransactionUseCase();

      final container = ProviderContainer(
        overrides: [
          addTransactionUseCaseProvider.overrideWithValue(mockAddUseCase),
          updateTransactionUseCaseProvider.overrideWithValue(mockUpdateUseCase),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(transactionFormProvider.notifier);

      // Act - Set note
      notifier.setNote('Test note');
      var state = container.read(transactionFormProvider);
      expect(state.note, equals('Test note'));

      // Act - Clear note
      notifier.setNote('');

      // Assert
      state = container.read(transactionFormProvider);
      expect(state.note, isNull);
    });

    test('should reset form to initial state', () {
      // Arrange
      final mockAddUseCase = MockAddTransactionUseCase();
      final mockUpdateUseCase = MockUpdateTransactionUseCase();

      final container = ProviderContainer(
        overrides: [
          addTransactionUseCaseProvider.overrideWithValue(mockAddUseCase),
          updateTransactionUseCaseProvider.overrideWithValue(mockUpdateUseCase),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(transactionFormProvider.notifier);

      // Act - Modify form state
      notifier.setNominal(50000);
      notifier.setType(TransactionType.income);
      notifier.setNote('Test note');
      expect(container.read(transactionFormProvider).nominal, equals(50000));

      // Reset form
      notifier.resetForm();

      // Assert - Should be back to initial state
      final state = container.read(transactionFormProvider);
      expect(state.nominal, isNull);
      expect(state.type, equals(TransactionType.expense)); // Default
      expect(state.note, isNull);
      expect(state.isEditMode, isFalse);
    });

    test('should clear submit error', () {
      // Arrange
      final mockAddUseCase = MockAddTransactionUseCase();
      final mockUpdateUseCase = MockUpdateTransactionUseCase();

      final container = ProviderContainer(
        overrides: [
          addTransactionUseCaseProvider.overrideWithValue(mockAddUseCase),
          updateTransactionUseCaseProvider.overrideWithValue(mockUpdateUseCase),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(transactionFormProvider.notifier);

      // Act - We can't directly set submitError, but we can verify clearError doesn't crash
      notifier.clearError();

      // Assert - No error should be present
      final state = container.read(transactionFormProvider);
      expect(state.submitError, isNull);
    });
  });
}
