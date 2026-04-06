import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_write_repository.dart';
import 'package:catat_cuan/domain/usecases/delete_all_transactions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<TransactionWriteRepository>(),
])
import 'delete_all_transactions_usecase_test.mocks.dart';

void main() {
  late DeleteAllTransactionsUseCase useCase;
  late MockTransactionWriteRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionWriteRepository();
    useCase = DeleteAllTransactionsUseCase(mockRepository);
  });

  group('DeleteAllTransactionsUseCase', () {
    test('should delete all transactions successfully', () async {
      // Arrange
      when(mockRepository.deleteAllTransactions())
          .thenAnswer((_) async => Result.success(null));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockRepository.deleteAllTransactions()).called(1);
    });

    test('should work with execute() method', () async {
      // Arrange
      when(mockRepository.deleteAllTransactions())
          .thenAnswer((_) async => Result.success(null));

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('should return database failure on repository exception', () async {
      // Arrange
      when(mockRepository.deleteAllTransactions())
          .thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Gagal menghapus semua transaksi'));
    });
  });
}
