/// Segregated repository interfaces for Transaction operations
///
/// Following Interface Segregation Principle (ISP), these interfaces
/// split the monolithic TransactionRepository into focused, single-responsibility
/// interfaces.
///
/// Clients should depend only on the interfaces they need:
/// - TransactionReadRepository: For reading transaction data
/// - TransactionWriteRepository: For creating/updating/deleting transactions
/// - TransactionQueryRepository: For filtering and pagination
/// - TransactionSearchRepository: For full-text search
/// - TransactionAnalyticsRepository: For summaries and breakdowns
/// - TransactionExportRepository: For export data preparation
library;

// Basic CRUD operations
export 'transaction_read_repository.dart';
export 'transaction_write_repository.dart';

// Query and search operations
export 'transaction_query_repository.dart';
export 'transaction_search_repository.dart';

// Analytics and export operations
export 'transaction_analytics_repository.dart';
export 'transaction_export_repository.dart';

// Legacy (deprecated)
export 'transaction_summary_repository.dart';
