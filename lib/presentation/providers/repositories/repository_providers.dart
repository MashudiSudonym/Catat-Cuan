import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/repositories/category/category_read_repository_impl.dart';
import 'package:catat_cuan/data/repositories/category/category_write_repository_impl.dart';
import 'package:catat_cuan/data/repositories/category/category_management_repository_impl.dart';
import 'package:catat_cuan/data/repositories/category/category_seeding_repository_impl.dart';
import 'package:catat_cuan/data/repositories/category/category_repository_adapter.dart';
import 'package:catat_cuan/data/repositories/transaction/transaction_repository_adapter.dart';
import 'package:catat_cuan/data/repositories/transaction_repository_impl.dart';
import 'package:catat_cuan/domain/repositories/category_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_write_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_management_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_seeding_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_repositories.dart';

/// Provider untuk DatabaseHelper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

/// Provider untuk TransactionRepository (legacy monolithic interface)
///
/// @deprecated Use segregated repository providers below for new code
/// Following DIP: Provides abstraction (TransactionRepository), not concrete implementation
@Deprecated('Use segregated repository providers instead')
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(ref.read(databaseHelperProvider));
});

/// Provider untuk TransactionRepositoryAdapter
///
/// Internal provider that creates the adapter wrapping the legacy implementation.
/// This is used by all the segregated repository providers below.
final _transactionRepositoryAdapterProvider = Provider<TransactionRepositoryAdapter>((ref) {
  final legacyImpl = TransactionRepositoryImpl(ref.read(databaseHelperProvider));
  return TransactionRepositoryAdapter(legacyImpl);
});

/// Provider untuk TransactionReadRepository (segregated interface)
///
/// Provides only read operations for transactions
/// Use this when you only need to query transaction data
final transactionReadRepositoryProvider = Provider<TransactionReadRepository>((ref) {
  return ref.read(_transactionRepositoryAdapterProvider);
});

/// Provider untuk TransactionWriteRepository (segregated interface)
///
/// Provides only write operations for transactions
/// Use this when you only need to create/update/delete transactions
final transactionWriteRepositoryProvider = Provider<TransactionWriteRepository>((ref) {
  return ref.read(_transactionRepositoryAdapterProvider);
});

/// Provider untuk TransactionQueryRepository (segregated interface)
///
/// Provides filtering and pagination operations for transactions
/// Use this when you need to query transactions with filters or pagination
final transactionQueryRepositoryProvider = Provider<TransactionQueryRepository>((ref) {
  return ref.read(_transactionRepositoryAdapterProvider);
});

/// Provider untuk TransactionSearchRepository (segregated interface)
///
/// Provides search operations for transactions
/// Use this when you need to search transactions by text
final transactionSearchRepositoryProvider = Provider<TransactionSearchRepository>((ref) {
  return ref.read(_transactionRepositoryAdapterProvider);
});

/// Provider untuk TransactionAnalyticsRepository (segregated interface)
///
/// Provides analytics and summary operations for transactions
/// Use this when you need summaries, breakdowns, and aggregations
final transactionAnalyticsRepositoryProvider = Provider<TransactionAnalyticsRepository>((ref) {
  return ref.read(_transactionRepositoryAdapterProvider);
});

/// Provider untuk TransactionExportRepository (segregated interface)
///
/// Provides export data preparation operations for transactions
/// Use this when you need to prepare transaction data for export
final transactionExportRepositoryProvider = Provider<TransactionExportRepository>((ref) {
  return ref.read(_transactionRepositoryAdapterProvider);
});

/// Provider untuk CategoryRepository (legacy monolithic interface)
///
/// @deprecated Use segregated repository providers below for new code
/// Following DIP: Provides abstraction (CategoryRepository), not concrete implementation
@Deprecated('Use segregated category repository providers instead')
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  // Use the adapter that combines segregated repositories
  return ref.read(_categoryRepositoryAdapterProvider);
});

/// Provider untuk CategoryRepositoryAdapter
///
/// Internal provider that creates the adapter combining the segregated implementations.
/// This is used by the legacy categoryRepositoryProvider for backward compatibility.
final _categoryRepositoryAdapterProvider = Provider<CategoryRepositoryAdapter>((ref) {
  return CategoryRepositoryAdapter(
    ref.read(categoryReadRepositoryProvider),
    ref.read(categoryWriteRepositoryProvider),
    ref.read(categoryManagementRepositoryProvider),
    ref.read(categorySeedingRepositoryProvider),
  );
});

/// ============================================================================
/// Segregated Category Repository Providers
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
