import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_export_repository.dart';
import 'package:catat_cuan/domain/services/export_service.dart';
import 'package:catat_cuan/domain/usecases/export_transactions_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<TransactionExportRepository>(),
  MockSpec<ExportService>(),
])
import 'export_transactions_usecase_test.mocks.dart';

void main() {
  late ExportTransactionsUseCase useCase;
  late MockTransactionExportRepository mockRepository;
  late MockExportService mockExportService;

  setUp(() {
    mockRepository = MockTransactionExportRepository();
    mockExportService = MockExportService();
    useCase = ExportTransactionsUseCase(mockRepository, mockExportService);
  });

  group('ExportTransactionsUseCase', () {
    final testTransactions = [
      {
        'id': 1,
        'amount': 50000.0,
        'type': 'expense',
        'dateTime': DateTime(2024, 3, 15),
        'categoryId': 1,
        'categoryName': 'Makan',
        'note': 'Makan siang',
        'createdAt': DateTime(2024, 3, 15),
        'updatedAt': DateTime(2024, 3, 15),
      },
    ];

    test('should export transactions successfully with default filename', () async {
      // Arrange
      const params = ExportTransactionsParams();

      when(mockRepository.getTransactionsWithCategoryNames(
        startDate: null,
        endDate: null,
        categoryId: null,
        type: null,
      )).thenAnswer((_) async => Result.success(testTransactions));

      when(mockExportService.exportTransactionsToCsv(
        transactions: testTransactions,
        fileName: argThat(isA<String>(), named: 'fileName'),
      )).thenAnswer((_) async => Result.success('/path/to/export.csv'));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, endsWith('.csv'));
      verify(mockRepository.getTransactionsWithCategoryNames(
        startDate: null,
        endDate: null,
        categoryId: null,
        type: null,
      )).called(1);
      verify(mockExportService.exportTransactionsToCsv(
        transactions: testTransactions,
        fileName: argThat(contains(RegExp(r'\d{8}')), named: 'fileName'),
      )).called(1);
    });

    test('should export with custom filename suffix', () async {
      // Arrange
      const params = ExportTransactionsParams(fileNameSuffix: 'custom_file');

      when(mockRepository.getTransactionsWithCategoryNames(
        startDate: null,
        endDate: null,
        categoryId: null,
        type: null,
      )).thenAnswer((_) async => Result.success(testTransactions));

      when(mockExportService.exportTransactionsToCsv(
        transactions: testTransactions,
        fileName: 'custom_file',
      )).thenAnswer((_) async => Result.success('/path/to/custom_file.csv'));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockExportService.exportTransactionsToCsv(
        transactions: testTransactions,
        fileName: 'custom_file',
      )).called(1);
    });

    test('should filter by date range', () async {
      // Arrange
      final startDate = DateTime(2024, 3, 1);
      final endDate = DateTime(2024, 3, 31);
      final params = ExportTransactionsParams(
        startDate: startDate,
        endDate: endDate,
      );

      when(mockRepository.getTransactionsWithCategoryNames(
        startDate: startDate,
        endDate: endDate,
        categoryId: null,
        type: null,
      )).thenAnswer((_) async => Result.success(testTransactions));

      when(mockExportService.exportTransactionsToCsv(
        transactions: testTransactions,
        fileName: anyNamed('fileName'),
      )).thenAnswer((_) async => Result.success('/path/to/export.csv'));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockRepository.getTransactionsWithCategoryNames(
        startDate: startDate,
        endDate: endDate,
        categoryId: null,
        type: null,
      )).called(1);
    });

    test('should filter by category', () async {
      // Arrange
      const params = ExportTransactionsParams(categoryId: 1);

      when(mockRepository.getTransactionsWithCategoryNames(
        startDate: null,
        endDate: null,
        categoryId: 1,
        type: null,
      )).thenAnswer((_) async => Result.success(testTransactions));

      when(mockExportService.exportTransactionsToCsv(
        transactions: testTransactions,
        fileName: anyNamed('fileName'),
      )).thenAnswer((_) async => Result.success('/path/to/export.csv'));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockRepository.getTransactionsWithCategoryNames(
        startDate: null,
        endDate: null,
        categoryId: 1,
        type: null,
      )).called(1);
    });

    test('should filter by transaction type', () async {
      // Arrange
      const params = ExportTransactionsParams(type: TransactionType.expense);

      when(mockRepository.getTransactionsWithCategoryNames(
        startDate: null,
        endDate: null,
        categoryId: null,
        type: TransactionType.expense,
      )).thenAnswer((_) async => Result.success(testTransactions));

      when(mockExportService.exportTransactionsToCsv(
        transactions: testTransactions,
        fileName: anyNamed('fileName'),
      )).thenAnswer((_) async => Result.success('/path/to/export.csv'));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('should return ExportFailure when no transactions found', () async {
      // Arrange
      const params = ExportTransactionsParams();

      when(mockRepository.getTransactionsWithCategoryNames(
        startDate: null,
        endDate: null,
        categoryId: null,
        type: null,
      )).thenAnswer((_) async => Result.success([]));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ExportFailure>());
      expect(result.failure?.message, contains('Tidak ada transaksi untuk diekspor'));
      verifyNever(mockExportService.exportTransactionsToCsv(
        transactions: anyNamed('transactions'),
        fileName: anyNamed('fileName'),
      ));
    });

    test('should propagate repository failure', () async {
      // Arrange
      const params = ExportTransactionsParams();

      when(mockRepository.getTransactionsWithCategoryNames(
        startDate: null,
        endDate: null,
        categoryId: null,
        type: null,
      )).thenAnswer((_) async => Result.failure(DatabaseFailure('Database error')));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isFailure, isTrue);
      verifyNever(mockExportService.exportTransactionsToCsv(
        transactions: anyNamed('transactions'),
        fileName: anyNamed('fileName'),
      ));
    });
  });
}
