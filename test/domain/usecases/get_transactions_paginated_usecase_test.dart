import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/paginated_result_entity.dart';
import 'package:catat_cuan/domain/entities/pagination_params_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_query_repository.dart';
import 'package:catat_cuan/domain/usecases/get_transactions_paginated_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../helpers/test_fixtures.dart';

@GenerateNiceMocks([
  MockSpec<TransactionQueryRepository>(),
])
import 'get_transactions_paginated_usecase_test.mocks.dart';

void main() {
  late GetTransactionsPaginatedUseCase useCase;
  late MockTransactionQueryRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionQueryRepository();
    useCase = GetTransactionsPaginatedUseCase(mockRepository);
  });

  group('GetTransactionsPaginatedUseCase', () {
    test('should return paginated transactions successfully', () async {
      // Arrange
      final transactions = [
        TestFixtures.transactionLunch(id: 1),
        TestFixtures.transactionTransport(id: 2),
      ];
      final paginatedResult = PaginatedResultEntity<TransactionEntity>.create(
        data: transactions,
        page: 1,
        limit: 20,
        totalItems: 50,
      );

      final params = GetTransactionsPaginatedParams(
        pagination: const PaginationParamsEntity(page: 1, limit: 20),
      );

      when(mockRepository.getTransactionsPaginated(
        const PaginationParamsEntity(page: 1, limit: 20),
        startDate: null,
        endDate: null,
        categoryId: null,
        type: null,
      )).thenAnswer((_) async => Result.success(paginatedResult));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.data, hasLength(2));
      expect(result.data?.totalPages, equals(3));
      verify(mockRepository.getTransactionsPaginated(
        const PaginationParamsEntity(page: 1, limit: 20),
        startDate: null,
        endDate: null,
        categoryId: null,
        type: null,
      )).called(1);
    });

    test('should filter by date range', () async {
      // Arrange
      final startDate = DateTime(2024, 3, 1);
      final endDate = DateTime(2024, 3, 31);
      final paginatedResult = PaginatedResultEntity<TransactionEntity>.create(
        data: [TestFixtures.transactionLunch(id: 1)],
        page: 1,
        limit: 20,
        totalItems: 1,
      );

      final params = GetTransactionsPaginatedParams(
        pagination: const PaginationParamsEntity(page: 1, limit: 20),
        startDate: startDate,
        endDate: endDate,
      );

      when(mockRepository.getTransactionsPaginated(
        const PaginationParamsEntity(page: 1, limit: 20),
        startDate: startDate,
        endDate: endDate,
        categoryId: null,
        type: null,
      )).thenAnswer((_) async => Result.success(paginatedResult));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockRepository.getTransactionsPaginated(
        const PaginationParamsEntity(page: 1, limit: 20),
        startDate: startDate,
        endDate: endDate,
        categoryId: null,
        type: null,
      )).called(1);
    });

    test('should filter by category', () async {
      // Arrange
      final paginatedResult = PaginatedResultEntity<TransactionEntity>.create(
        data: [TestFixtures.transactionLunch(id: 1)],
        page: 1,
        limit: 20,
        totalItems: 15,
      );

      final params = GetTransactionsPaginatedParams(
        pagination: const PaginationParamsEntity(page: 1, limit: 20),
        categoryId: 1,
      );

      when(mockRepository.getTransactionsPaginated(
        const PaginationParamsEntity(page: 1, limit: 20),
        startDate: null,
        endDate: null,
        categoryId: 1,
        type: null,
      )).thenAnswer((_) async => Result.success(paginatedResult));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockRepository.getTransactionsPaginated(
        const PaginationParamsEntity(page: 1, limit: 20),
        startDate: null,
        endDate: null,
        categoryId: 1,
        type: null,
      )).called(1);
    });

    test('should filter by transaction type', () async {
      // Arrange
      final paginatedResult = PaginatedResultEntity<TransactionEntity>.create(
        data: [TestFixtures.transactionLunch(id: 1)],
        page: 1,
        limit: 20,
        totalItems: 25,
      );

      final params = GetTransactionsPaginatedParams(
        pagination: const PaginationParamsEntity(page: 1, limit: 20),
        type: TransactionType.expense,
      );

      when(mockRepository.getTransactionsPaginated(
        const PaginationParamsEntity(page: 1, limit: 20),
        startDate: null,
        endDate: null,
        categoryId: null,
        type: TransactionType.expense,
      )).thenAnswer((_) async => Result.success(paginatedResult));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('should handle second page', () async {
      // Arrange
      final paginatedResult = PaginatedResultEntity<TransactionEntity>.create(
        data: [TestFixtures.transactionLunch(id: 21)],
        page: 2,
        limit: 20,
        totalItems: 50,
      );

      final params = GetTransactionsPaginatedParams(
        pagination: const PaginationParamsEntity(page: 2, limit: 20),
      );

      when(mockRepository.getTransactionsPaginated(
        const PaginationParamsEntity(page: 2, limit: 20),
        startDate: null,
        endDate: null,
        categoryId: null,
        type: null,
      )).thenAnswer((_) async => Result.success(paginatedResult));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.currentPage, equals(2));
      expect(result.data?.hasPreviousPage, isTrue);
    });

    test('should return empty result for page beyond data', () async {
      // Arrange
      final paginatedResult = PaginatedResultEntity<TransactionEntity>.create(
        data: [],
        page: 10,
        limit: 20,
        totalItems: 50,
      );

      final params = GetTransactionsPaginatedParams(
        pagination: const PaginationParamsEntity(page: 10, limit: 20),
      );

      when(mockRepository.getTransactionsPaginated(
        const PaginationParamsEntity(page: 10, limit: 20),
        startDate: null,
        endDate: null,
        categoryId: null,
        type: null,
      )).thenAnswer((_) async => Result.success(paginatedResult));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.isDataEmpty, isTrue);
    });

    test('should return database failure on repository exception', () async {
      // Arrange
      final params = GetTransactionsPaginatedParams(
        pagination: const PaginationParamsEntity(page: 1, limit: 20),
      );

      when(mockRepository.getTransactionsPaginated(
        const PaginationParamsEntity(page: 1, limit: 20),
        startDate: null,
        endDate: null,
        categoryId: null,
        type: null,
      )).thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Gagal mengambil transaksi'));
    });
  });
}
