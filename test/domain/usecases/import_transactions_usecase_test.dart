import 'package:catat_cuan/data/services/csv_import_service_impl.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/entities/import_result_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_management_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_write_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_query_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_write_repository.dart';
import 'package:catat_cuan/domain/usecases/import_transactions_usecase.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<CsvImportServiceImpl>(),
  MockSpec<CategoryReadRepository>(),
  MockSpec<CategoryWriteRepository>(),
  MockSpec<CategoryManagementRepository>(),
  MockSpec<TransactionWriteRepository>(),
  MockSpec<TransactionQueryRepository>(),
])
import 'import_transactions_usecase_test.mocks.dart';

void main() {
  // Initialize AppLogger for tests
  setUpAll(() {
    AppLogger.initialize();
  });

  late ImportTransactionsUseCase useCase;
  late MockCsvImportServiceImpl mockImportService;
  late MockCategoryReadRepository mockCategoryReadRepository;
  late MockCategoryWriteRepository mockCategoryWriteRepository;
  late MockCategoryManagementRepository mockCategoryManagementRepository;
  late MockTransactionWriteRepository mockTransactionWriteRepository;
  late MockTransactionQueryRepository mockTransactionQueryRepository;

  setUp(() {
    mockImportService = MockCsvImportServiceImpl();
    mockCategoryReadRepository = MockCategoryReadRepository();
    mockCategoryWriteRepository = MockCategoryWriteRepository();
    mockCategoryManagementRepository = MockCategoryManagementRepository();
    mockTransactionWriteRepository = MockTransactionWriteRepository();
    mockTransactionQueryRepository = MockTransactionQueryRepository();

    useCase = ImportTransactionsUseCase(
      mockImportService,
      mockCategoryReadRepository,
      mockCategoryWriteRepository,
      mockCategoryManagementRepository,
      mockTransactionWriteRepository,
      mockTransactionQueryRepository,
    );
  });

  group('ImportTransactionsUseCase - Auto-create categories', () {
    test('Import with unknown category -> auto-creates it, row imports successfully', () async {
      // Arrange
      const filePath = '/test/path/test.csv';
      final parsedRows = [
        const ParsedCsvRow(
          rowNumber: 2,
          date: '15/03/2026',
          type: 'Pengeluaran',
          category: 'Makan Siang',
          amount: '25000',
          note: '',
        ),
      ];

      when(mockImportService.parseCsvFile(filePath))
          .thenAnswer((_) async => Result.success(parsedRows));

      when(mockCategoryReadRepository.getCategories())
          .thenAnswer((_) async => Result.success([]));

      when(mockTransactionQueryRepository.getTransactionsByFilter())
          .thenAnswer((_) async => Result.success([]));

      // First call returns null (not found), second call returns the newly created category
      when(mockCategoryReadRepository.getCategoryByName('Makan Siang', CategoryType.expense))
          .thenAnswer((_) async => Result.success(null));

      when(mockCategoryWriteRepository.addCategory(any))
          .thenAnswer((_) async {
        final category = CategoryEntity(
          id: 1,
          name: 'Makan Siang',
          type: CategoryType.expense,
          color: '#6B7280',
          icon: null,
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return Result.success(category);
      });

      when(mockTransactionWriteRepository.addTransaction(any))
          .thenAnswer((_) async {
        final transaction = TransactionEntity(
          id: 1,
          amount: 25000,
          type: TransactionType.expense,
          dateTime: DateTime(2026, 3, 15),
          categoryId: 1,
          note: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return Result.success(transaction);
      });

      // Act
      final result = await useCase(ImportTransactionsParams(filePath: filePath));

      // Assert
      expect(result.isSuccess, true);
      expect(result.data!.imported, 1);
      expect(result.data!.skipped, 0);
      expect(result.data!.errors, isEmpty);
      expect(result.data!.categoriesCreated, 1);

      verify(mockCategoryWriteRepository.addCategory(any)).called(1);
      verify(mockTransactionWriteRepository.addTransaction(any)).called(1);
    });

    test('Multiple rows with same unknown category -> category created only once', () async {
      // Arrange
      const filePath = '/test/path/test.csv';
      final parsedRows = [
        const ParsedCsvRow(
          rowNumber: 2,
          date: '15/03/2026',
          type: 'Pengeluaran',
          category: 'Makan Siang',
          amount: '25000',
          note: '',
        ),
        const ParsedCsvRow(
          rowNumber: 3,
          date: '15/03/2026',
          type: 'Pengeluaran',
          category: 'Makan Siang',
          amount: '30000',
          note: '',
        ),
      ];

      when(mockImportService.parseCsvFile(filePath))
          .thenAnswer((_) async => Result.success(parsedRows));

      when(mockCategoryReadRepository.getCategories())
          .thenAnswer((_) async => Result.success([]));

      when(mockTransactionQueryRepository.getTransactionsByFilter())
          .thenAnswer((_) async => Result.success([]));

      // First call returns null (not found)
      when(mockCategoryReadRepository.getCategoryByName('Makan Siang', CategoryType.expense))
          .thenAnswer((_) async => Result.success(null));

      when(mockCategoryWriteRepository.addCategory(any))
          .thenAnswer((_) async {
        final category = CategoryEntity(
          id: 1,
          name: 'Makan Siang',
          type: CategoryType.expense,
          color: '#6B7280',
          icon: null,
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return Result.success(category);
      });

      when(mockTransactionWriteRepository.addTransaction(any))
          .thenAnswer((_) async {
        final transaction = TransactionEntity(
          id: 1,
          amount: 25000,
          type: TransactionType.expense,
          dateTime: DateTime(2026, 3, 15),
          categoryId: 1,
          note: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return Result.success(transaction);
      });

      // Act
      final result = await useCase(ImportTransactionsParams(filePath: filePath));

      // Assert
      expect(result.isSuccess, true);
      expect(result.data!.imported, 2);
      expect(result.data!.skipped, 0);
      expect(result.data!.errors, isEmpty);
      expect(result.data!.categoriesCreated, 1);

      // Category should be created only once
      verify(mockCategoryWriteRepository.addCategory(any)).called(1);
      verify(mockTransactionWriteRepository.addTransaction(any)).called(2);
    });

    test('Import with soft-deleted category -> reactivates it instead of creating new', () async {
      // Arrange
      const filePath = '/test/path/test.csv';
      final parsedRows = [
        const ParsedCsvRow(
          rowNumber: 2,
          date: '15/03/2026',
          type: 'Pengeluaran',
          category: 'Makan Siang',
          amount: '25000',
          note: '',
        ),
      ];

      when(mockImportService.parseCsvFile(filePath))
          .thenAnswer((_) async => Result.success(parsedRows));

      when(mockCategoryReadRepository.getCategories())
          .thenAnswer((_) async => Result.success([]));

      when(mockTransactionQueryRepository.getTransactionsByFilter())
          .thenAnswer((_) async => Result.success([]));

      // Return soft-deleted category
      final softDeletedCategory = CategoryEntity(
        id: 5,
        name: 'Makan Siang',
        type: CategoryType.expense,
        color: '#EC5B13',
        icon: null,
        sortOrder: 1,
        isActive: false, // Soft-deleted
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockCategoryReadRepository.getCategoryByName('Makan Siang', CategoryType.expense))
          .thenAnswer((_) async => Result.success(softDeletedCategory));

      when(mockCategoryManagementRepository.reactivateCategory(5))
          .thenAnswer((_) async => Result.success(null as dynamic));

      when(mockTransactionWriteRepository.addTransaction(any))
          .thenAnswer((_) async {
        final transaction = TransactionEntity(
          id: 1,
          amount: 25000,
          type: TransactionType.expense,
          dateTime: DateTime(2026, 3, 15),
          categoryId: 1,
          note: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return Result.success(transaction);
      });

      // Act
      final result = await useCase(ImportTransactionsParams(filePath: filePath));

      // Assert
      expect(result.isSuccess, true);
      expect(result.data!.imported, 1);
      expect(result.data!.skipped, 0);
      expect(result.data!.errors, isEmpty);
      expect(result.data!.categoriesCreated, 0);

      verify(mockCategoryManagementRepository.reactivateCategory(5)).called(1);
      verifyNever(mockCategoryWriteRepository.addCategory(any));
      verify(mockTransactionWriteRepository.addTransaction(any)).called(1);
    });

    test('Reactivate fails -> falls back to creating new category', () async {
      // Arrange
      const filePath = '/test/path/test.csv';
      final parsedRows = [
        const ParsedCsvRow(
          rowNumber: 2,
          date: '15/03/2026',
          type: 'Pengeluaran',
          category: 'Makan Siang',
          amount: '25000',
          note: '',
        ),
      ];

      when(mockImportService.parseCsvFile(filePath))
          .thenAnswer((_) async => Result.success(parsedRows));

      when(mockCategoryReadRepository.getCategories())
          .thenAnswer((_) async => Result.success([]));

      when(mockTransactionQueryRepository.getTransactionsByFilter())
          .thenAnswer((_) async => Result.success([]));

      // Return soft-deleted category
      final softDeletedCategory = CategoryEntity(
        id: 5,
        name: 'Makan Siang',
        type: CategoryType.expense,
        color: '#EC5B13',
        icon: null,
        sortOrder: 1,
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockCategoryReadRepository.getCategoryByName('Makan Siang', CategoryType.expense))
          .thenAnswer((_) async => Result.success(softDeletedCategory));

      // Reactivate fails
      when(mockCategoryManagementRepository.reactivateCategory(5))
          .thenAnswer((_) async => Result.failure(UnknownFailure('Reactivate failed')));

      // Create new category succeeds
      when(mockCategoryWriteRepository.addCategory(any))
          .thenAnswer((_) async {
        final category = CategoryEntity(
          id: 6,
          name: 'Makan Siang',
          type: CategoryType.expense,
          color: '#6B7280',
          icon: null,
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return Result.success(category);
      });

      when(mockTransactionWriteRepository.addTransaction(any))
          .thenAnswer((_) async {
        final transaction = TransactionEntity(
          id: 1,
          amount: 25000,
          type: TransactionType.expense,
          dateTime: DateTime(2026, 3, 15),
          categoryId: 1,
          note: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return Result.success(transaction);
      });

      // Act
      final result = await useCase(ImportTransactionsParams(filePath: filePath));

      // Assert
      expect(result.isSuccess, true);
      expect(result.data!.imported, 1);
      expect(result.data!.skipped, 0);
      expect(result.data!.errors, isEmpty);
      expect(result.data!.categoriesCreated, 1);

      verify(mockCategoryManagementRepository.reactivateCategory(5)).called(1);
      verify(mockCategoryWriteRepository.addCategory(any)).called(1);
      verify(mockTransactionWriteRepository.addTransaction(any)).called(1);
    });

    test('Both reactivate and create fail -> row skipped with error', () async {
      // Arrange
      const filePath = '/test/path/test.csv';
      final parsedRows = [
        const ParsedCsvRow(
          rowNumber: 2,
          date: '15/03/2026',
          type: 'Pengeluaran',
          category: 'Makan Siang',
          amount: '25000',
          note: '',
        ),
      ];

      when(mockImportService.parseCsvFile(filePath))
          .thenAnswer((_) async => Result.success(parsedRows));

      when(mockCategoryReadRepository.getCategories())
          .thenAnswer((_) async => Result.success([]));

      when(mockTransactionQueryRepository.getTransactionsByFilter())
          .thenAnswer((_) async => Result.success([]));

      // Category not found
      when(mockCategoryReadRepository.getCategoryByName('Makan Siang', CategoryType.expense))
          .thenAnswer((_) async => Result.success(null));

      // Create fails
      when(mockCategoryWriteRepository.addCategory(any))
          .thenAnswer((_) async => Result.failure(UnknownFailure('Create failed')));

      // Act
      final result = await useCase(ImportTransactionsParams(filePath: filePath));

      // Assert
      expect(result.isSuccess, true);
      expect(result.data!.imported, 0);
      expect(result.data!.skipped, 0);
      expect(result.data!.errors.length, 1);
      expect(result.data!.errors[0].errorMessage, contains('Gagal membuat kategori'));
      expect(result.data!.categoriesCreated, 0);

      verifyNever(mockTransactionWriteRepository.addTransaction(any));
    });
  });

  group('ImportTransactionsUseCase - Existing functionality', () {
    test('Successfully imports valid CSV rows', () async {
      // Arrange
      const filePath = '/test/path/test.csv';
      final parsedRows = [
        const ParsedCsvRow(
          rowNumber: 2,
          date: '15/03/2026',
          type: 'Pengeluaran',
          category: 'Makan',
          amount: '25000',
          note: '',
        ),
      ];

      final existingCategories = [
        CategoryEntity(
          id: 1,
          name: 'Makan',
          type: CategoryType.expense,
          color: '#EC5B13',
          icon: null,
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockImportService.parseCsvFile(filePath))
          .thenAnswer((_) async => Result.success(parsedRows));

      when(mockCategoryReadRepository.getCategories())
          .thenAnswer((_) async => Result.success(existingCategories));

      when(mockTransactionQueryRepository.getTransactionsByFilter())
          .thenAnswer((_) async => Result.success([]));

      when(mockTransactionWriteRepository.addTransaction(any))
          .thenAnswer((_) async {
        final transaction = TransactionEntity(
          id: 1,
          amount: 25000,
          type: TransactionType.expense,
          dateTime: DateTime(2026, 3, 15),
          categoryId: 1,
          note: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return Result.success(transaction);
      });

      // Act
      final result = await useCase(ImportTransactionsParams(filePath: filePath));

      // Assert
      expect(result.isSuccess, true);
      expect(result.data!.imported, 1);
      expect(result.data!.skipped, 0);
      expect(result.data!.errors, isEmpty);

      verify(mockTransactionWriteRepository.addTransaction(any)).called(1);
    });

    test('Skips duplicate transactions', () async {
      // Arrange
      const filePath = '/test/path/test.csv';
      final parsedRows = [
        const ParsedCsvRow(
          rowNumber: 2,
          date: '15/03/2026',
          type: 'Pengeluaran',
          category: 'Makan',
          amount: '25000',
          note: '',
        ),
      ];

      final existingCategories = [
        CategoryEntity(
          id: 1,
          name: 'Makan',
          type: CategoryType.expense,
          color: '#EC5B13',
          icon: null,
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final testDate = DateTime(2026, 3, 15);
      final existingTransactions = [
        // Duplicate transaction
        TransactionEntity(
          id: 1,
          amount: 25000,
          type: TransactionType.expense,
          dateTime: testDate,
          categoryId: 1,
          note: null,
          createdAt: testDate,
          updatedAt: testDate,
        ),
      ];

      when(mockImportService.parseCsvFile(filePath))
          .thenAnswer((_) async => Result.success(parsedRows));

      when(mockCategoryReadRepository.getCategories())
          .thenAnswer((_) async => Result.success(existingCategories));

      when(mockTransactionQueryRepository.getTransactionsByFilter())
          .thenAnswer((_) async => Result.success(existingTransactions));

      // Act
      final result = await useCase(ImportTransactionsParams(filePath: filePath));

      // Assert
      expect(result.isSuccess, true);
      expect(result.data!.imported, 0);
      expect(result.data!.skipped, 1);
      expect(result.data!.errors.length, 1);
      expect(result.data!.errors[0].errorMessage, 'Duplikat');

      verifyNever(mockTransactionWriteRepository.addTransaction(any));
    });

    test('Returns error for invalid transaction type', () async {
      // Arrange
      const filePath = '/test/path/test.csv';
      final parsedRows = [
        const ParsedCsvRow(
          rowNumber: 2,
          date: '15/03/2026',
          type: 'InvalidType',
          category: 'Makan',
          amount: '25000',
          note: '',
        ),
      ];

      when(mockImportService.parseCsvFile(filePath))
          .thenAnswer((_) async => Result.success(parsedRows));

      when(mockCategoryReadRepository.getCategories())
          .thenAnswer((_) async => Result.success([]));

      when(mockTransactionQueryRepository.getTransactionsByFilter())
          .thenAnswer((_) async => Result.success([]));

      // Act
      final result = await useCase(ImportTransactionsParams(filePath: filePath));

      // Assert
      expect(result.isSuccess, true);
      expect(result.data!.imported, 0);
      expect(result.data!.errors.length, 1);
      expect(result.data!.errors[0].errorMessage, contains('Jenis transaksi tidak valid'));
    });

    test('Returns error for invalid date format', () async {
      // Arrange
      const filePath = '/test/path/test.csv';
      final parsedRows = [
        const ParsedCsvRow(
          rowNumber: 2,
          date: 'invalid-date',
          type: 'Pengeluaran',
          category: 'Makan',
          amount: '25000',
          note: '',
        ),
      ];

      when(mockImportService.parseCsvFile(filePath))
          .thenAnswer((_) async => Result.success(parsedRows));

      when(mockCategoryReadRepository.getCategories())
          .thenAnswer((_) async => Result.success([]));

      when(mockTransactionQueryRepository.getTransactionsByFilter())
          .thenAnswer((_) async => Result.success([]));

      // Act
      final result = await useCase(ImportTransactionsParams(filePath: filePath));

      // Assert
      expect(result.isSuccess, true);
      expect(result.data!.imported, 0);
      expect(result.data!.errors.length, 1);
      expect(result.data!.errors[0].errorMessage, contains('Format tanggal tidak valid'));
    });

    test('Returns error for invalid amount format', () async {
      // Arrange
      const filePath = '/test/path/test.csv';
      final parsedRows = [
        const ParsedCsvRow(
          rowNumber: 2,
          date: '15/03/2026',
          type: 'Pengeluaran',
          category: 'Makan',
          amount: 'invalid-amount',
          note: '',
        ),
      ];

      when(mockImportService.parseCsvFile(filePath))
          .thenAnswer((_) async => Result.success(parsedRows));

      when(mockCategoryReadRepository.getCategories())
          .thenAnswer((_) async => Result.success([]));

      when(mockTransactionQueryRepository.getTransactionsByFilter())
          .thenAnswer((_) async => Result.success([]));

      // Act
      final result = await useCase(ImportTransactionsParams(filePath: filePath));

      // Assert
      expect(result.isSuccess, true);
      expect(result.data!.imported, 0);
      expect(result.data!.errors.length, 1);
      expect(result.data!.errors[0].errorMessage, contains('Format jumlah tidak valid'));
    });
  });
}
