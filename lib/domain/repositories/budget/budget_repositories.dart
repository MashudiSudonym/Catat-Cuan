/// Segregated repository interfaces for Budget operations
///
/// Following Interface Segregation Principle (ISP), these interfaces
/// split budget operations into focused, single-responsibility interfaces.
///
/// Clients should depend only on the interfaces they need:
/// - BudgetReadRepository: For reading budget data
/// - BudgetWriteRepository: For creating/updating/deleting budgets
/// - BudgetQueryRepository: For spent calculation and budget analytics
library;

// Read operations
export 'budget_read_repository.dart';

// Write operations
export 'budget_write_repository.dart';

// Query and analytics operations
export 'budget_query_repository.dart';
