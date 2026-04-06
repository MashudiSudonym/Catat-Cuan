import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_search_repository.dart';
import 'package:catat_cuan/domain/usecases/search_transactions_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../helpers/test_fixtures.dart';

@GenerateNiceMocks([
  MockSpec<TransactionSearchRepository>(),
])
import 'search_transactions_usecase_test.mocks.dart';

void main() {
  late SearchTransactionsUseCase useCase;
  late MockTransactionSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionSearchRepository();
    useCase = SearchTransactionsUseCase(mockRepository);
  });

  group('SearchTransactionsUseCase', () {
    test('should return transactions for valid query', () async {
      // Arrange
      final transactions = [TestFixtures.transactionLunch(id: 1)];
      const params = SearchTransactionsParams(query: 'makan');

      when(mockRepository.searchTransactions('makan', type: anyNamed('type'), limit: anyNamed('limit')))
          .thenAnswer((_) async => Result.success(transactions));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, hasLength(1));
      verify(mockRepository.searchTransactions('makan', type: null, limit: 50)).called(1);
    });

    test('should return empty result for empty query', () async {
      // Arrange
      const params = SearchTransactionsParams(query: '');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
      verifyNever(mockRepository.searchTransactions(any, type: anyNamed('type'), limit: anyNamed('limit')));
    });

    test('should return empty result for whitespace-only query', () async {
      // Arrange
      const params = SearchTransactionsParams(query: '   ');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
      verifyNever(mockRepository.searchTransactions(any, type: anyNamed('type'), limit: anyNamed('limit')));
    });

    test('should trim whitespace from query', () async {
      // Arrange
      final transactions = [TestFixtures.transactionLunch(id: 1)];
      const params = SearchTransactionsParams(query: '  makan  ');

      when(mockRepository.searchTransactions('  makan  ', type: anyNamed('type'), limit: anyNamed('limit')))
          .thenAnswer((_) async => Result.success(transactions));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('should pass type parameter to repository', () async {
      // Arrange
      final transactions = [TestFixtures.transactionSalary(id: 1)];
      const params = SearchTransactionsParams(
        query: 'gaji',
        type: TransactionType.income,
      );

      when(mockRepository.searchTransactions('gaji', type: TransactionType.income, limit: anyNamed('limit')))
          .thenAnswer((_) async => Result.success(transactions));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.first.type, equals(TransactionType.income));
    });

    test('should pass custom limit parameter to repository', () async {
      // Arrange
      final transactions = [TestFixtures.transactionLunch(id: 1)];
      const params = SearchTransactionsParams(
        query: 'makan',
        limit: 20,
      );

      when(mockRepository.searchTransactions('makan', type: anyNamed('type'), limit: 20))
          .thenAnswer((_) async => Result.success(transactions));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockRepository.searchTransactions('makan', type: null, limit: 20)).called(1);
    });

    test('should return database failure on repository exception', () async {
      // Arrange
      const params = SearchTransactionsParams(query: 'makan');

      when(mockRepository.searchTransactions('makan', type: anyNamed('type'), limit: anyNamed('limit')))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Gagal mencari transaksi'));
    });

    test('should handle no results found', () async {
      // Arrange
      const params = SearchTransactionsParams(query: 'nonexistent');

      when(mockRepository.searchTransactions('nonexistent', type: anyNamed('type'), limit: 50))
          .thenAnswer((_) async => Result.success([]));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });
  });
}
