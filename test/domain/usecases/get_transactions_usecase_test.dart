import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_read_repository.dart';
import 'package:catat_cuan/domain/usecases/transaction/get_transactions_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../helpers/test_fixtures.dart';

@GenerateNiceMocks([
  MockSpec<TransactionReadRepository>(),
])
import 'get_transactions_usecase_test.mocks.dart';

void main() {
  late GetTransactionsUseCase useCase;
  late MockTransactionReadRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionReadRepository();
    useCase = GetTransactionsUseCase(mockRepository);
  });

  group('GetTransactionsUseCase', () {
    test('should return all transactions successfully', () async {
      // Arrange
      final transactions = [
        TestFixtures.transactionLunch(id: 1),
        TestFixtures.transactionTransport(id: 2),
      ];

      when(mockRepository.getTransactions())
          .thenAnswer((_) async => Result.success(transactions));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, hasLength(2));
      verify(mockRepository.getTransactions()).called(1);
    });

    test('should return empty list when no transactions exist', () async {
      // Arrange
      when(mockRepository.getTransactions())
          .thenAnswer((_) async => Result.success([]));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });

    test('should work with execute() method', () async {
      // Arrange
      final transactions = [TestFixtures.transactionLunch(id: 1)];

      when(mockRepository.getTransactions())
          .thenAnswer((_) async => Result.success(transactions));

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, hasLength(1));
    });

    test('should return database failure on repository exception', () async {
      // Arrange
      when(mockRepository.getTransactions())
          .thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Gagal mengambil transaksi'));
    });

    test('should handle large number of transactions', () async {
      // Arrange
      final transactions = List.generate(100, (i) => TestFixtures.transactionLunch(id: i + 1));

      when(mockRepository.getTransactions())
          .thenAnswer((_) async => Result.success(transactions));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, hasLength(100));
    });
  });
}
