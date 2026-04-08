import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/presentation/controllers/transaction_form_submission_controller.dart';
import 'package:catat_cuan/presentation/states/transaction_form_state.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../helpers/test_fixtures.dart';
import '../presentation_mocks.mocks.dart';

void main() {
  // Initialize logger for tests
  setUpAll(() {
    AppLogger.initialize();
  });

  late TransactionFormSubmissionController controller;
  late MockAddTransactionUseCase mockAddUseCase;
  late MockUpdateTransactionUseCase mockUpdateUseCase;

  setUp(() {
    mockAddUseCase = MockAddTransactionUseCase();
    mockUpdateUseCase = MockUpdateTransactionUseCase();
    controller = TransactionFormSubmissionController(
      addStrategy: AddTransactionStrategy(mockAddUseCase),
      updateStrategy: UpdateTransactionStrategy(mockUpdateUseCase),
    );
  });

  group('TransactionFormSubmissionController', () {
    test('should use AddTransactionStrategy for new transaction', () async {
      // Arrange
      final now = DateTime.now();
      final formState = TransactionFormState(
        nominal: 50000.0,
        type: TransactionType.expense,
        date: now,
        time: now,
        categoryId: 1,
        note: 'Test transaction',
      );

      final testTransaction = TestFixtures.transactionLunch();
      when(mockAddUseCase(any))
          .thenAnswer((_) async => Result.success(testTransaction));

      String? capturedError;
      bool onErrorCalled = false;

      // Act
      final result = await controller.submit(formState, (error) {
        capturedError = error;
        onErrorCalled = true;
      });

      // Assert
      expect(result, isTrue);
      expect(onErrorCalled, isFalse);
      expect(capturedError, isNull);
      verify(mockAddUseCase(any)).called(1);
    });

    test('should combine date and time correctly when creating transaction', () async {
      verifyNever(mockUpdateUseCase(any));
    });

    test('should use UpdateTransactionStrategy for edit transaction', () async {
      // Arrange
      final now = DateTime.now();
      final editingTransaction = TestFixtures.transactionLunch();
      final formState = TransactionFormState(
        nominal: 50000.0,
        type: TransactionType.expense,
        date: now,
        time: now,
        categoryId: 1,
        note: 'Updated transaction',
        isEditMode: true,
        editingTransaction: editingTransaction,
      );

      when(mockUpdateUseCase(any))
          .thenAnswer((_) async => Result.success(editingTransaction));

      String? capturedError;
      bool onErrorCalled = false;

      // Act
      final result = await controller.submit(formState, (error) {
        capturedError = error;
        onErrorCalled = true;
      });

      // Assert
      expect(result, isTrue);
      expect(onErrorCalled, isFalse);
      expect(capturedError, isNull);
      verify(mockUpdateUseCase(any)).called(1);
      verifyNever(mockAddUseCase(any));
    });

    test('should return false and call onError for invalid form', () async {
      // Arrange - Invalid form (no amount)
      final now = DateTime.now();
      final formState = TransactionFormState(
        nominal: null, // Invalid: nominal is required
        type: TransactionType.expense,
        date: now,
        time: now,
        categoryId: 1,
        note: 'Test',
      );

      String? capturedError;
      bool onErrorCalled = false;

      // Act
      final result = await controller.submit(formState, (error) {
        capturedError = error;
        onErrorCalled = true;
      });

      // Assert
      expect(result, isFalse);
      expect(onErrorCalled, isTrue);
      expect(capturedError, isNotNull);
      expect(capturedError, contains('Mohon lengkapi'));
      verifyNever(mockAddUseCase(any));
      verifyNever(mockUpdateUseCase(any));
    });

    test('should return false and call onError for zero nominal', () async {
      // Arrange - Invalid form (zero nominal)
      final now = DateTime.now();
      final formState = TransactionFormState(
        nominal: 0, // Invalid: nominal must be > 0
        type: TransactionType.expense,
        date: now,
        time: now,
        categoryId: 1,
        note: 'Test',
      );

      String? capturedError;
      bool onErrorCalled = false;

      // Act
      final result = await controller.submit(formState, (error) {
        capturedError = error;
        onErrorCalled = true;
      });

      // Assert
      expect(result, isFalse);
      expect(onErrorCalled, isTrue);
      expect(capturedError, isNotNull);
      verifyNever(mockAddUseCase(any));
      verifyNever(mockUpdateUseCase(any));
    });

    test('should return false and call onError when strategy throws exception', () async {
      // Arrange
      final now = DateTime.now();
      final formState = TransactionFormState(
        nominal: 50000.0,
        type: TransactionType.expense,
        date: now,
        time: now,
        categoryId: 1,
        note: 'Test transaction',
      );

      // The strategy throws an exception when use case fails
      when(mockAddUseCase(any))
          .thenThrow(Exception('Database error'));

      String? capturedError;
      bool onErrorCalled = false;

      // Act
      final result = await controller.submit(formState, (error) {
        capturedError = error;
        onErrorCalled = true;
      });

      // Assert
      expect(result, isFalse);
      expect(onErrorCalled, isTrue);
      expect(capturedError, isNotNull);
      verify(mockAddUseCase(any)).called(1);
    });

    test('should combine date and time correctly when creating transaction', () async {
      // Arrange
      final date = DateTime(2026, 3, 18);
      final time = DateTime(2026, 3, 18, 14, 30);
      final formState = TransactionFormState(
        nominal: 50000.0,
        type: TransactionType.expense,
        date: date,
        time: time,
        categoryId: 1,
        note: 'Test transaction',
      );

      final testTransaction = TestFixtures.transactionLunch();
      when(mockAddUseCase(any))
          .thenAnswer((_) async => Result.success(testTransaction));

      // Act
      await controller.submit(formState, (_) {});

      // Assert
      final captured = verify(mockAddUseCase(captureAny)).captured.single
          as TransactionEntity;
      expect(captured.dateTime.year, equals(2026));
      expect(captured.dateTime.month, equals(3));
      expect(captured.dateTime.day, equals(18));
      expect(captured.dateTime.hour, equals(14));
      expect(captured.dateTime.minute, equals(30));
    });
  });
}
