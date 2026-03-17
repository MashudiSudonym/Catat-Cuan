/// Read operations interface for Transaction Repository
///
/// This interface follows the Interface Segregation Principle (ISP)
/// by only defining read operations. Clients that only need to read
/// transactions don't need to depend on write operations.
library;

import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Repository interface for read-only transaction operations
abstract class TransactionReadRepository {
  /// Retrieves a transaction by its ID
  ///
  /// Returns the transaction if found, null otherwise
  Future<TransactionEntity?> getTransactionById(int id);

  /// Retrieves all transactions
  ///
  /// Returns an empty list if no transactions exist
  Future<List<TransactionEntity>> getTransactions();

  /// Retrieves transactions with optional filters
  ///
  /// Parameters:
  /// - [startDate]: Filter by date start (inclusive), null for no filter
  /// - [endDate]: Filter by date end (inclusive), null for no filter
  /// - [categoryId]: Filter by category ID, null for all categories
  /// - [type]: Filter by transaction type, null for all types
  ///
  /// Returns filtered transactions sorted by date descending (newest first)
  Future<List<TransactionEntity>> getTransactionsByFilter({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  });
}
