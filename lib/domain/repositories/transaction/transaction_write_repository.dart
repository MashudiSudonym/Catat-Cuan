/// Write operations interface for Transaction Repository
///
/// This interface follows the Interface Segregation Principle (ISP)
/// by only defining write operations. Clients that only need to write
/// transactions don't need to depend on read operations.
library;

import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Repository interface for write-only transaction operations
abstract class TransactionWriteRepository {
  /// Adds a new transaction
  ///
  /// Returns the transaction with its generated ID
  /// Throws an exception if the operation fails
  Future<TransactionEntity> addTransaction(TransactionEntity transaction);

  /// Updates an existing transaction
  ///
  /// Returns the updated transaction
  /// Throws an exception if the transaction is not found or update fails
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction);

  /// Deletes a transaction by ID
  ///
  /// Returns true if deleted, false if not found
  Future<bool> deleteTransaction(int id);

  /// Deletes all transactions
  ///
  /// Use with caution - this is a destructive operation
  Future<void> deleteAllTransactions();
}
