import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_write_repository.dart';
import 'package:catat_cuan/domain/usecases/delete_multiple_transactions_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<TransactionWriteRepository>(),
])
import 'delete_multiple_transactions_usecase_test.mocks.dart';

void main() {
  late DeleteMultipleTransactionsUseCase useCase;
  late MockTransactionWriteRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionWriteRepository();
    useCase = DeleteMultipleTransactionsUseCase(mockRepository);
  });

  group('DeleteMultipleTransactionsUseCase', () {
    test('should delete multiple transactions successfully', () async {
      // Arrange
      const transactionIds = [1, 2, 3, 4, 5];

      when(mockRepository.deleteMultipleTransactions(transactionIds))
          .thenAnswer((_) async => Result.success(null));

      // Act
      final result = await useCase(transactionIds);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockRepository.deleteMultipleTransactions(transactionIds)).called(1);
    });

    test('should delete single transaction', () async {
      // Arrange
      const transactionIds = [1];

      when(mockRepository.deleteMultipleTransactions(transactionIds))
          .thenAnswer((_) async => Result.success(null));

      // Act
      final result = await useCase(transactionIds);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockRepository.deleteMultipleTransactions([1])).called(1);
    });

    test('should return validation failure when list is empty', () async {
      // Arrange
      const transactionIds = <int>[];

      // Act
      final result = await useCase(transactionIds);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('Daftar transaksi tidak boleh kosong'));
      verifyNever(mockRepository.deleteMultipleTransactions(any));
    });

    test('should return validation failure when any ID is 0', () async {
      // Arrange
      const transactionIds = [1, 2, 0, 4];

      // Act
      final result = await useCase(transactionIds);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('ID transaksi tidak valid: 0'));
      verifyNever(mockRepository.deleteMultipleTransactions(any));
    });

    test('should return validation failure when any ID is negative', () async {
      // Arrange
      const transactionIds = [1, 2, -1, 4];

      // Act
      final result = await useCase(transactionIds);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('ID transaksi tidak valid: -1'));
      verifyNever(mockRepository.deleteMultipleTransactions(any));
    });

    test('should return database failure on repository exception', () async {
      // Arrange
      const transactionIds = [1, 2, 3];

      when(mockRepository.deleteMultipleTransactions(transactionIds))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(transactionIds);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Gagal menghapus transaksi'));
    });

    test('should handle large list of IDs', () async {
      // Arrange
      final transactionIds = List.generate(100, (i) => i + 1);

      when(mockRepository.deleteMultipleTransactions(transactionIds))
          .thenAnswer((_) async => Result.success(null));

      // Act
      final result = await useCase(transactionIds);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockRepository.deleteMultipleTransactions(transactionIds)).called(1);
    });
  });
}
