import 'package:mockito/mockito.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/category_breakdown_entity.dart';
import 'package:catat_cuan/domain/entities/paginated_result_entity.dart';
import 'package:catat_cuan/domain/entities/pagination_params_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_write_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_management_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_seeding_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_read_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_write_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_query_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_search_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_analytics_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_summary_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_export_repository.dart';
import 'package:catat_cuan/domain/services/ocr_service.dart';
import 'package:catat_cuan/domain/services/export_service.dart';
import 'package:catat_cuan/domain/services/file_naming_service.dart';

// === Mock Classes ===

class MockCategoryReadRepository extends Mock implements CategoryReadRepository {}
class MockCategoryWriteRepository extends Mock implements CategoryWriteRepository {}
class MockCategoryManagementRepository extends Mock implements CategoryManagementRepository {}
class MockCategorySeedingRepository extends Mock implements CategorySeedingRepository {}

class MockTransactionReadRepository extends Mock implements TransactionReadRepository {}
class MockTransactionWriteRepository extends Mock implements TransactionWriteRepository {}
class MockTransactionQueryRepository extends Mock implements TransactionQueryRepository {}
class MockTransactionSearchRepository extends Mock implements TransactionSearchRepository {}
class MockTransactionAnalyticsRepository extends Mock implements TransactionAnalyticsRepository {}
class MockTransactionSummaryRepository extends Mock implements TransactionSummaryRepository {}
class MockTransactionExportRepository extends Mock implements TransactionExportRepository {}

class MockOcrService extends Mock implements OcrService {}
class MockExportService extends Mock implements ExportService {}
class MockFileNamingService extends Mock implements FileNamingService {}

/// Helper class for setting up mock repositories with common behaviors
class MockRepositoryHelpers {
  // === Category Read Repository ===
  static void setupCategoryReadRepositorySuccess(
    MockCategoryReadRepository mock,
    List<CategoryEntity> categories,
  ) {
    when(mock.getCategories())
        .thenAnswer((_) async => Result.success(categories));
    when(mock.getCategoryById(any))
        .thenAnswer((_) async => Result.success(categories.first));
    when(mock.getCategoriesByType(any))
        .thenAnswer((_) async => Result.success(categories));
  }

  static void setupCategoryReadRepositoryEmpty(
    MockCategoryReadRepository mock,
  ) {
    when(mock.getCategories())
        .thenAnswer((_) async => Result.success(<CategoryEntity>[]));
    when(mock.getCategoryById(0))
        .thenAnswer((_) async => Result.failure(NotFoundFailure('Category not found')));
  }

  // === Transaction Read Repository ===
  static void setupTransactionReadRepositorySuccess(
    MockTransactionReadRepository mock,
    List<TransactionEntity> transactions,
  ) {
    when(mock.getTransactions())
        .thenAnswer((_) async => Result.success(transactions));
    when(mock.getTransactionById(0))
        .thenAnswer((_) async => Result.success(transactions.first));
  }

  static void setupTransactionReadRepositoryEmpty(
    MockTransactionReadRepository mock,
  ) {
    when(mock.getTransactions())
        .thenAnswer((_) async => Result.success(<TransactionEntity>[]));
    when(mock.getTransactionById(0))
        .thenAnswer((_) async => Result.failure(NotFoundFailure('Transaction not found')));
  }

  // === Transaction Query Repository ===
  static void setupTransactionQueryRepositorySuccess(
    MockTransactionQueryRepository mock,
    List<TransactionEntity> transactions,
  ) {
    when(mock.getTransactionsByFilter(
      startDate: anyNamed('startDate'),
      endDate: anyNamed('endDate'),
      categoryId: anyNamed('categoryId'),
      type: anyNamed('type'),
    ))
        .thenAnswer((_) async => Result.success(transactions));
    when(mock.getTransactionsPaginated(any, startDate: anyNamed('startDate'), endDate: anyNamed('endDate'), categoryId: anyNamed('categoryId'), type: anyNamed('type')))
        .thenAnswer((_) async => Result.success(PaginatedResultEntity.create(
              data: transactions,
              page: 1,
              limit: 10,
              totalItems: transactions.length,
            )));
  }

  // === Transaction Search Repository ===
  static void setupTransactionSearchRepositorySuccess(
    MockTransactionSearchRepository mock,
    List<TransactionEntity> results,
  ) {
    when(mock.searchTransactions(''))
        .thenAnswer((_) async => Result.success(results));
  }

  static void setupTransactionSearchRepositoryEmpty(
    MockTransactionSearchRepository mock,
  ) {
    when(mock.searchTransactions(''))
        .thenAnswer((_) async => Result.success(<TransactionEntity>[]));
  }

  // === Transaction Analytics Repository ===
  static void setupTransactionAnalyticsRepositorySuccess(
    MockTransactionAnalyticsRepository mock,
    MonthlySummaryEntity summary,
    List<CategoryBreakdownEntity> breakdown,
  ) {
    when(mock.getMonthlySummary(''))
        .thenAnswer((_) async => Result.success(summary));
    when(mock.getCategoryBreakdown('', any))
        .thenAnswer((_) async => Result.success(breakdown));
  }

  // === OCR Service ===
  static void setupOcrServiceSuccess(
    MockOcrService mock,
    String extractedText,
  ) {
    when(mock.extractText(any))
        .thenAnswer((_) async => Result.success(extractedText));
  }

  static void setupOcrServiceFailure(
    MockOcrService mock,
  ) {
    when(mock.extractText(any))
        .thenAnswer((_) async => Result.failure(OcrFailure('OCR failed')));
  }

  // === Export Service ===
  static void setupExportServiceSuccess(
    MockExportService mock,
    String filePath,
  ) {
    when(mock.saveTransactionsToCsv(transactions: any, fileName: any))
        .thenAnswer((_) async => Result.success(filePath));
  }
}
