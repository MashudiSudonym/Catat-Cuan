import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/datasources/local/sqlite_data_source.dart';
import 'package:catat_cuan/data/repositories/category/category_read_repository_impl.dart';
import 'package:catat_cuan/data/repositories/category/category_write_repository_impl.dart';
import 'package:catat_cuan/data/repositories/category/category_management_repository_impl.dart';
import 'package:catat_cuan/data/repositories/category/category_seeding_repository_impl.dart';
import 'package:catat_cuan/data/repositories/transaction/transaction_read_repository_impl.dart';
import 'package:catat_cuan/data/repositories/transaction/transaction_write_repository_impl.dart';
import 'package:catat_cuan/data/repositories/transaction/transaction_analytics_repository_impl.dart';
import 'package:catat_cuan/data/repositories/transaction/transaction_export_repository_impl.dart';
import 'package:catat_cuan/data/repositories/transaction/transaction_query_repository_impl.dart';
import 'package:catat_cuan/data/repositories/transaction/transaction_search_repository_impl.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_write_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_management_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_seeding_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_repositories.dart';

/// Provider untuk DatabaseHelper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

/// Provider for LocalDataSource abstraction
///
/// Following DIP: Provides the abstraction (LocalDataSource) rather than
/// the concrete implementation (DatabaseHelper).
///
/// This allows repositories to depend on the abstraction, making it
/// easy to swap implementations (e.g., for testing or different storage backends).
final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SqliteDataSource(dbHelper);
});

/// ============================================================================
/// Transaction Repository Providers (Segregated Interfaces)
/// ============================================================================

/// Provider for TransactionReadRepository (segregated interface)
///
/// Provides only read operations for transactions.
/// Use this when you only need to query transaction data (by ID or all).
///
/// Following DIP: Depends on LocalDataSource abstraction, not concrete DatabaseHelper.
final transactionReadRepositoryProvider = Provider<TransactionReadRepository>((ref) {
  return TransactionReadRepositoryImpl(ref.read(localDataSourceProvider));
});

/// Provider for TransactionWriteRepository (segregated interface)
///
/// Provides only write operations for transactions.
/// Use this when you only need to create/update/delete transactions.
///
/// Following DIP: Depends on LocalDataSource abstraction, not concrete DatabaseHelper.
final transactionWriteRepositoryProvider = Provider<TransactionWriteRepository>((ref) {
  return TransactionWriteRepositoryImpl(ref.read(localDataSourceProvider));
});

/// Provider for TransactionQueryRepository (segregated interface)
///
/// Provides filtering and pagination operations for transactions.
/// Use this when you need to query transactions with filters or pagination.
///
/// Following DIP: Depends on LocalDataSource abstraction, not concrete DatabaseHelper.
final transactionQueryRepositoryProvider = Provider<TransactionQueryRepository>((ref) {
  return TransactionQueryRepositoryImpl(ref.read(localDataSourceProvider));
});

/// Provider for TransactionSearchRepository (segregated interface)
///
/// Provides search operations for transactions.
/// Use this when you need to search transactions by text.
///
/// Following DIP: Depends on LocalDataSource abstraction, not concrete DatabaseHelper.
final transactionSearchRepositoryProvider = Provider<TransactionSearchRepository>((ref) {
  return TransactionSearchRepositoryImpl(ref.read(localDataSourceProvider));
});

/// Provider for TransactionAnalyticsRepository (segregated interface)
///
/// Provides analytics and summary operations for transactions.
/// Use this when you need summaries, breakdowns, and aggregations.
///
/// Following DIP: Depends on LocalDataSource abstraction, not concrete DatabaseHelper.
final transactionAnalyticsRepositoryProvider = Provider<TransactionAnalyticsRepository>((ref) {
  return TransactionAnalyticsRepositoryImpl(ref.read(localDataSourceProvider));
});

/// Provider for TransactionExportRepository (segregated interface)
///
/// Provides export data preparation operations for transactions.
/// Use this when you need to prepare transaction data for export.
///
/// Following DIP: Depends on LocalDataSource abstraction, not concrete DatabaseHelper.
final transactionExportRepositoryProvider = Provider<TransactionExportRepository>((ref) {
  return TransactionExportRepositoryImpl(ref.read(localDataSourceProvider));
});

/// ============================================================================
/// Category Repository Providers (Segregated Interfaces)
/// ============================================================================

/// Provider untuk CategoryReadRepository (segregated interface)
///
/// Provides only read operations for categories
/// Use this when you only need to query category data
///
/// Following DIP: Depends on LocalDataSource abstraction, not concrete DatabaseHelper.
final categoryReadRepositoryProvider = Provider<CategoryReadRepository>((ref) {
  return CategoryReadRepositoryImpl(ref.read(localDataSourceProvider));
});

/// Provider untuk CategoryWriteRepository (segregated interface)
///
/// Provides only write operations for categories
/// Use this when you only need to create/update/delete categories
///
/// Following DIP: Depends on LocalDataSource abstraction, not concrete DatabaseHelper.
final categoryWriteRepositoryProvider =
    Provider<CategoryWriteRepository>((ref) {
  return CategoryWriteRepositoryImpl(ref.read(localDataSourceProvider));
});

/// Provider untuk CategoryManagementRepository (segregated interface)
///
/// Provides management operations for categories (reactivate, reorder)
/// Use this when you need to manage category status and ordering
///
/// Following DIP: Depends on LocalDataSource abstraction, not concrete DatabaseHelper.
final categoryManagementRepositoryProvider =
    Provider<CategoryManagementRepository>((ref) {
  return CategoryManagementRepositoryImpl(ref.read(localDataSourceProvider));
});

/// Provider untuk CategorySeedingRepository (segregated interface)
///
/// Provides seeding operations for default categories
/// Use this when you need to seed initial category data
///
/// Following DIP: Depends on LocalDataSource abstraction, not concrete DatabaseHelper.
final categorySeedingRepositoryProvider =
    Provider<CategorySeedingRepository>((ref) {
  return CategorySeedingRepositoryImpl(ref.read(localDataSourceProvider));
});
