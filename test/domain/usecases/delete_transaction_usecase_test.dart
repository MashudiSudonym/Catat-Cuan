import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_write_repository.dart';
import 'package:catat_cuan/domain/usecases/delete_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<TransactionWriteRepository>(),
])
import 'delete_transaction_usecase_test.mocks.dart';

void main() {
  late DeleteTransactionUseCase useCase;
  late MockTransactionWriteRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionWriteRepository();
    useCase = DeleteTransactionUseCase(mockRepository);
  });

  group('DeleteTransactionUseCase', () {
    test('should delete transaction successfully with valid ID', () async {
      // Arrange
      const transactionId = 1;

      when(mockRepository.deleteTransaction(transactionId))
          .thenAnswer((_) async => Result.success(null));

      // Act
      final result = await useCase(transactionId);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockRepository.deleteTransaction(transactionId)).called(1);
    });

    test('should return validation failure when ID is 0', () async {
      // Arrange
      const transactionId = 0;

      // Act
      final result = await useCase(transactionId);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('ID transaksi tidak valid'));
      verifyNever(mockRepository.deleteTransaction(any));
    });

    test('should return validation failure when ID is negative', () async {
      // Arrange
      const transactionId = -1;

      // Act
      final result = await useCase(transactionId);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockRepository.deleteTransaction(any));
    });

    test('should return database failure on repository exception', () async {
      // Arrange
      const transactionId = 1;

      when(mockRepository.deleteTransaction(transactionId))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(transactionId);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Gagal menghapus transaksi'));
    });

    test('should handle large transaction ID', () async {
      // Arrange
      const transactionId = 999999;

      when(mockRepository.deleteTransaction(transactionId))
          .thenAnswer((_) async => Result.success(null));

      // Act
      final result = await useCase(transactionId);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockRepository.deleteTransaction(transactionId)).called(1);
    });
  });
}
