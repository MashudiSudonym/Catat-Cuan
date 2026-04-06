import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_write_repository.dart';
import 'package:catat_cuan/domain/usecases/update_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../helpers/test_fixtures.dart';

@GenerateNiceMocks([
  MockSpec<TransactionWriteRepository>(),
])
import 'update_transaction_usecase_test.mocks.dart';

void main() {
  late UpdateTransactionUseCase useCase;
  late MockTransactionWriteRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionWriteRepository();
    useCase = UpdateTransactionUseCase(mockRepository);
  });

  group('UpdateTransactionUseCase', () {
    test('should update transaction successfully with valid data', () async {
      // Arrange
      final existingTransaction = TestFixtures.transactionLunch(id: 1);
      final updatedTransaction = existingTransaction.copyWith(
        amount: 75000,
        note: 'Makan siang update',
      );

      when(mockRepository.updateTransaction(any))
          .thenAnswer((_) async => Result.success(updatedTransaction));

      // Act
      final result = await useCase(updatedTransaction);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.amount, equals(75000));
      expect(result.data?.note, equals('Makan siang update'));
      verify(mockRepository.updateTransaction(any)).called(1);
    });

    test('should set updatedAt timestamp', () async {
      // Arrange
      final transaction = TestFixtures.transactionLunch(id: 1);
      final beforeUpdate = DateTime.now();

      when(mockRepository.updateTransaction(any))
          .thenAnswer((_) async => Result.success(transaction));

      // Act
      final result = await useCase(transaction);
      final afterUpdate = DateTime.now();

      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(mockRepository.updateTransaction(captureAny)).captured.single
          as TransactionEntity;
      expect(captured.updatedAt, isNotNull);
      expect(captured.updatedAt.isAfter(beforeUpdate.subtract(const Duration(seconds: 1))), isTrue);
      expect(captured.updatedAt.isBefore(afterUpdate.add(const Duration(seconds: 1))), isTrue);
    });

    test('should not modify createdAt timestamp', () async {
      // Arrange
      final originalCreatedAt = DateTime(2024, 3, 15, 10, 30);
      final originalUpdatedAt = DateTime(2024, 3, 15, 10, 30);
      final transaction = TransactionEntity(
        id: 1,
        amount: 50000,
        type: TransactionType.expense,
        categoryId: 1,
        dateTime: DateTime(2024, 3, 15, 12, 0),
        note: 'Test',
        createdAt: originalCreatedAt,
        updatedAt: originalUpdatedAt,
      );

      when(mockRepository.updateTransaction(any))
          .thenAnswer((_) async => Result.success(transaction));

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockRepository.updateTransaction(captureAny)).called(1);
      // updatedAt will be modified by the use case, but createdAt should be preserved in the original
      expect(transaction.createdAt, equals(originalCreatedAt));
    });

    test('should return validation failure when ID is null', () async {
      // Arrange - Create transaction directly without using TestFixtures
      // because TestFixtures has default id value
      final now = DateTime.now();
      final transaction = TransactionEntity(
        id: null, // Invalid for update: ID must be present
        amount: 50000,
        type: TransactionType.expense,
        categoryId: 1,
        dateTime: now,
        note: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('ID transaksi wajib ada untuk update'));
      verifyNever(mockRepository.updateTransaction(any));
    });

    test('should return validation failure when amount is negative', () async {
      // Arrange
      final transaction = TestFixtures.transactionLunch(id: 1, amount: -50000);

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockRepository.updateTransaction(any));
    });

    test('should return validation failure when amount is zero', () async {
      // Arrange
      final transaction = TestFixtures.transactionLunch(id: 1, amount: 0);

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockRepository.updateTransaction(any));
    });

    test('should return validation failure when categoryId is null', () async {
      // Arrange - Create transaction directly without using TestFixtures
      // because TestFixtures has default values
      final now = DateTime.now();
      final transaction = TransactionEntity(
        id: 1,
        amount: 50000,
        type: TransactionType.expense,
        categoryId: 0, // Invalid: categoryId must be > 0
        dateTime: now,
        note: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockRepository.updateTransaction(any));
    });

    test('should return database failure on repository exception', () async {
      // Arrange
      final transaction = TestFixtures.transactionLunch(id: 1);

      when(mockRepository.updateTransaction(any))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Gagal mengupdate transaksi'));
    });

    test('should handle updating transaction type from expense to income', () async {
      // Arrange
      final expenseTransaction = TestFixtures.transactionLunch(id: 1);
      final incomeTransaction = expenseTransaction.copyWith(
        type: TransactionType.income,
        categoryId: 2, // Different category for income
      );

      when(mockRepository.updateTransaction(any))
          .thenAnswer((_) async => Result.success(incomeTransaction));

      // Act
      final result = await useCase(incomeTransaction);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.type, equals(TransactionType.income));
    });

    test('should accept empty note update', () async {
      // Arrange
      final transaction = TestFixtures.transactionLunch(id: 1, note: '');

      when(mockRepository.updateTransaction(any))
          .thenAnswer((_) async => Result.success(transaction));

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('should accept null note update', () async {
      // Arrange
      final transaction = TestFixtures.transactionLunch(id: 1, note: null);

      when(mockRepository.updateTransaction(any))
          .thenAnswer((_) async => Result.success(transaction));

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isSuccess, isTrue);
    });
  });
}
