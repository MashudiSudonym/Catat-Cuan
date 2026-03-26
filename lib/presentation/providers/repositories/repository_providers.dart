import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/data/datasources/local/database_helper.dart';
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

/// ============================================================================
/// Transaction Repository Providers (Segregated Interfaces)
/// ============================================================================

/// Provider for TransactionReadRepository (segregated interface)
///
/// Provides only read operations for transactions.
/// Use this when you only need to query transaction data (by ID or all).
final transactionReadRepositoryProvider = Provider<TransactionReadRepository>((ref) {
  return TransactionReadRepositoryImpl(ref.read(databaseHelperProvider));
});

/// Provider for TransactionWriteRepository (segregated interface)
///
/// Provides only write operations for transactions.
/// Use this when you only need to create/update/delete transactions.
final transactionWriteRepositoryProvider = Provider<TransactionWriteRepository>((ref) {
  return TransactionWriteRepositoryImpl(ref.read(databaseHelperProvider));
});

/// Provider for TransactionQueryRepository (segregated interface)
///
/// Provides filtering and pagination operations for transactions.
/// Use this when you need to query transactions with filters or pagination.
final transactionQueryRepositoryProvider = Provider<TransactionQueryRepository>((ref) {
  return TransactionQueryRepositoryImpl(ref.read(databaseHelperProvider));
});

/// Provider for TransactionSearchRepository (segregated interface)
///
/// Provides search operations for transactions.
/// Use this when you need to search transactions by text.
final transactionSearchRepositoryProvider = Provider<TransactionSearchRepository>((ref) {
  return TransactionSearchRepositoryImpl(ref.read(databaseHelperProvider));
});

/// Provider for TransactionAnalyticsRepository (segregated interface)
///
/// Provides analytics and summary operations for transactions.
/// Use this when you need summaries, breakdowns, and aggregations.
final transactionAnalyticsRepositoryProvider = Provider<TransactionAnalyticsRepository>((ref) {
  return TransactionAnalyticsRepositoryImpl(ref.read(databaseHelperProvider));
});

/// Provider for TransactionExportRepository (segregated interface)
///
/// Provides export data preparation operations for transactions.
/// Use this when you need to prepare transaction data for export.
final transactionExportRepositoryProvider = Provider<TransactionExportRepository>((ref) {
  return TransactionExportRepositoryImpl(ref.read(databaseHelperProvider));
});

/// ============================================================================
/// Category Repository Providers (Segregated Interfaces)
/// ============================================================================

/// Provider untuk CategoryReadRepository (segregated interface)
///
/// Provides only read operations for categories
/// Use this when you only need to query category data
final categoryReadRepositoryProvider = Provider<CategoryReadRepository>((ref) {
  return CategoryReadRepositoryImpl(ref.read(databaseHelperProvider));
});

/// Provider untuk CategoryWriteRepository (segregated interface)
///
/// Provides only write operations for categories
/// Use this when you only need to create/update/delete categories
final categoryWriteRepositoryProvider =
    Provider<CategoryWriteRepository>((ref) {
  return CategoryWriteRepositoryImpl(ref.read(databaseHelperProvider));
});

/// Provider untuk CategoryManagementRepository (segregated interface)
///
/// Provides management operations for categories (reactivate, reorder)
/// Use this when you need to manage category status and ordering
final categoryManagementRepositoryProvider =
    Provider<CategoryManagementRepository>((ref) {
  return CategoryManagementRepositoryImpl(ref.read(databaseHelperProvider));
});

/// Provider untuk CategorySeedingRepository (segregated interface)
///
/// Provides seeding operations for default categories
/// Use this when you need to seed initial category data
final categorySeedingRepositoryProvider =
    Provider<CategorySeedingRepository>((ref) {
  return CategorySeedingRepositoryImpl(ref.read(databaseHelperProvider));
});
