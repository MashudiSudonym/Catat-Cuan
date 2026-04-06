import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_write_repository.dart';
import 'package:catat_cuan/domain/usecases/add_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../helpers/test_fixtures.dart';

@GenerateNiceMocks([
  MockSpec<TransactionWriteRepository>(),
])
import 'add_transaction_usecase_test.mocks.dart';

void main() {
  late AddTransactionUseCase useCase;
  late MockTransactionWriteRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionWriteRepository();
    useCase = AddTransactionUseCase(mockRepository);
  });

  group('AddTransactionUseCase', () {
    test('should add transaction successfully with valid data', () async {
      // Arrange
      final transaction = TestFixtures.transactionLunch();

      when(mockRepository.addTransaction(any))
          .thenAnswer((_) async => Result.success(transaction.copyWith(id: 1)));

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.id, equals(1));
      verify(mockRepository.addTransaction(any)).called(1);
    });

    test('should set createdAt and updatedAt timestamps', () async {
      // Arrange
      final transaction = TestFixtures.transactionLunch();
      final beforeAdd = DateTime.now();

      when(mockRepository.addTransaction(any))
          .thenAnswer((_) async => Result.success(transaction.copyWith(id: 1)));

      // Act
      final result = await useCase(transaction);
      final afterAdd = DateTime.now();

      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(mockRepository.addTransaction(captureAny)).captured.single
          as TransactionEntity;
      expect(captured.createdAt, isNotNull);
      expect(captured.updatedAt, isNotNull);
      expect(captured.createdAt.isAfter(beforeAdd.subtract(const Duration(seconds: 1))), isTrue);
      expect(captured.createdAt.isBefore(afterAdd.add(const Duration(seconds: 1))), isTrue);
    });

    test('should return validation failure when amount is zero', () async {
      // Arrange
      final transaction = TestFixtures.transactionLunch(amount: 0);

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockRepository.addTransaction(any));
    });

    test('should return validation failure when amount is negative', () async {
      // Arrange
      final transaction = TestFixtures.transactionLunch(amount: -1000);

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockRepository.addTransaction(any));
    });

    test('should return validation failure when categoryId is null', () async {
      // Arrange - Create transaction directly without using TestFixtures
      // because TestFixtures has default values
      final now = DateTime.now();
      final transaction = TransactionEntity(
        id: null,
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
      verifyNever(mockRepository.addTransaction(any));
    });

    test('should return database failure on repository exception', () async {
      // Arrange
      final transaction = TestFixtures.transactionLunch();

      when(mockRepository.addTransaction(any))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Gagal menyimpan transaksi'));
    });

    test('should handle income transaction type', () async {
      // Arrange
      final transaction = TestFixtures.transactionSalary();

      when(mockRepository.addTransaction(any))
          .thenAnswer((_) async => Result.success(transaction.copyWith(id: 1)));

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.type, equals(TransactionType.income));
    });

    test('should handle expense transaction type', () async {
      // Arrange
      final transaction = TestFixtures.transactionLunch();

      when(mockRepository.addTransaction(any))
          .thenAnswer((_) async => Result.success(transaction.copyWith(id: 1)));

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.type, equals(TransactionType.expense));
    });

    test('should accept note with 500 characters (boundary)', () async {
      // Arrange
      final transaction = TestFixtures.transactionLunch(note: 'a' * 500);

      when(mockRepository.addTransaction(any))
          .thenAnswer((_) async => Result.success(transaction.copyWith(id: 1)));

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('should accept transaction with null note (optional)', () async {
      // Arrange
      final now = DateTime.now();
      final transaction = TransactionEntity(
        id: null,
        amount: 50000,
        type: TransactionType.expense,
        categoryId: 1,
        dateTime: now,
        note: null,
        createdAt: now,
        updatedAt: now,
      );

      when(mockRepository.addTransaction(any))
          .thenAnswer((_) async => Result.success(transaction.copyWith(id: 1)));

      // Act
      final result = await useCase(transaction);

      // Assert
      expect(result.isSuccess, isTrue);
    });
  });
}
