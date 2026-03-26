/// Summary operations interface for Transaction Repository
///
/// This interface follows the Interface Segregation Principle (ISP)
/// by only defining summary/aggregation operations. Clients that need
/// summaries don't need to depend on individual CRUD operations.
///
/// Note: This interface is now superseded by TransactionAnalyticsRepository
/// which provides the same functionality with proper Result/Failure handling.
/// Use TransactionAnalyticsRepository for new code.
///
/// This interface is kept for backward compatibility during migration.
library;

import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Repository interface for transaction summary and aggregation operations
@Deprecated('Use TransactionAnalyticsRepository instead')
abstract class TransactionSummaryRepository {
  /// Retrieves monthly summary for transactions
  ///
  /// Parameters:
  /// - [yearMonth]: Format "YYYY-MM" (e.g., "2024-03")
  ///
  /// Returns Result with [MonthlySummaryEntity] with aggregated data for the month
  Future<Result<MonthlySummaryEntity>> getMonthlySummary(String yearMonth);

  /// Retrieves category breakdown for transactions in a month
  ///
  /// Parameters:
  /// - [yearMonth]: Format "YYYY-MM" (e.g., "2024-03")
  /// - [type]: Filter by transaction type (income/expense)
  ///
  /// Returns Result with list of [CategoryBreakdownEntity] sorted by total amount descending
  Future<Result<List<CategoryBreakdownEntity>>> getCategoryBreakdown(
    String yearMonth,
    TransactionType type,
  );
}
