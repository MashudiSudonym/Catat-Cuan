/// Summary operations interface for Transaction Repository
///
/// This interface follows the Interface Segregation Principle (ISP)
/// by only defining summary/aggregation operations. Clients that need
/// summaries don't need to depend on individual CRUD operations.
library;

import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Repository interface for transaction summary and aggregation operations
abstract class TransactionSummaryRepository {
  /// Retrieves monthly summary for transactions
  ///
  /// Parameters:
  /// - [yearMonth]: Format "YYYY-MM" (e.g., "2024-03")
  ///
  /// Returns [MonthlySummaryEntity] with aggregated data for the month
  Future<MonthlySummaryEntity> getMonthlySummary(String yearMonth);

  /// Retrieves category breakdown for transactions in a month
  ///
  /// Parameters:
  /// - [yearMonth]: Format "YYYY-MM" (e.g., "2024-03")
  /// - [type]: Filter by transaction type (income/expense)
  ///
  /// Returns list of [CategoryBreakdownEntity] sorted by total amount descending
  Future<List<CategoryBreakdownEntity>> getCategoryBreakdown(
    String yearMonth,
    TransactionType type,
  );
}
