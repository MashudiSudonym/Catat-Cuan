/// Base UseCase interface for Clean Architecture
///
/// All use cases should implement this interface to ensure consistency
/// and enable dependency injection through abstractions (DIP).
///
/// Following SOLID principles:
/// - Interface Segregation: Simple, focused interface
/// - Dependency Inversion: High-level modules depend on this abstraction
/// - Single Responsibility: Each use case performs one operation
library;

import 'package:catat_cuan/domain/core/result.dart';

/// Base interface for all use cases following SRP
///
/// Type parameters:
/// - Type: The return type of the use case execution
/// - Params: The parameter type required for execution
///
/// Usage:
/// ```dart
/// class GetTransactionUseCase implements UseCase<TransactionEntity, int> {
///   final TransactionRepository _repository;
///
///   GetTransactionUseCase(this._repository);
///
///   @override
///   Result<TransactionEntity> call(int params) {
///     return _repository.getTransactionById(params);
///   }
/// }
/// ```
abstract class UseCase<T, Params> {
  /// Executes the use case with the given parameters
  Result<T> call(Params params);
}

/// For use cases without parameters
///
/// Usage:
/// ```dart
/// class GetAllTransactionsUseCase implements UseCase<List<TransactionEntity>, NoParams> {
///   @override
///   Result<List<TransactionEntity>> call(NoParams params) {
///     // Implementation
///   }
/// }
/// ```
class NoParams {
  const NoParams();
}

/// For use cases with multiple parameters
///
/// Usage:
/// ```dart
/// class GetTransactionsByDateRangeUseCase implements UseCase<List<TransactionEntity>, DateRangeParams> {
///   @override
///   Result<List<TransactionEntity>> call(DateRangeParams params) {
///     // Implementation using params.startDate and params.endDate
///   }
/// }
/// ```
///
/// Create your own parameter classes as needed:
/// ```dart
/// class DateRangeParams {
///   final DateTime startDate;
///   final DateTime endDate;
///
///   const DateRangeParams({
///     required this.startDate,
///     required this.endDate,
///   });
/// }
/// ```
