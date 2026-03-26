/// Read operations interface for Transaction Repository
///
/// This interface follows the Interface Segregation Principle (ISP)
/// by only defining read operations. Clients that only need to read
/// transactions don't need to depend on write operations.
library;

import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Repository interface for read-only transaction operations
abstract class TransactionReadRepository {
  /// Retrieves a transaction by its ID
  ///
  /// Returns Result with the transaction if found, NotFoundFailure if not found
  Future<Result<TransactionEntity>> getTransactionById(int id);

  /// Retrieves all transactions
  ///
  /// Returns Result with empty list if no transactions exist
  Future<Result<List<TransactionEntity>>> getTransactions();
}
