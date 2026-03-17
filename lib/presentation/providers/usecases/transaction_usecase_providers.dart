import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/usecases/add_transaction.dart';
import 'package:catat_cuan/domain/usecases/delete_transaction.dart';
import 'package:catat_cuan/domain/usecases/delete_all_transactions.dart';
import 'package:catat_cuan/domain/usecases/get_transactions.dart';
import 'package:catat_cuan/domain/usecases/update_transaction.dart';
import 'package:catat_cuan/domain/usecases/transaction/get_monthly_summary_usecase.dart';
import 'package:catat_cuan/domain/usecases/transaction/get_category_breakdown_usecase.dart';
import 'package:catat_cuan/domain/usecases/transaction/get_multi_month_summary_usecase.dart';
import 'package:catat_cuan/domain/usecases/transaction/get_insights_usecase.dart';
import 'package:catat_cuan/domain/usecases/search_transactions_usecase.dart';
import 'package:catat_cuan/domain/usecases/get_transactions_paginated_usecase.dart';
import 'package:catat_cuan/presentation/providers/repositories/repository_providers.dart';

/// Provider untuk AddTransactionUseCase
final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  return AddTransactionUseCase(ref.read(transactionRepositoryProvider));
});

/// Provider untuk UpdateTransactionUseCase
final updateTransactionUseCaseProvider = Provider<UpdateTransactionUseCase>((ref) {
  return UpdateTransactionUseCase(ref.read(transactionRepositoryProvider));
});

/// Provider untuk DeleteTransactionUseCase
final deleteTransactionUseCaseProvider = Provider<DeleteTransactionUseCase>((ref) {
  return DeleteTransactionUseCase(ref.read(transactionRepositoryProvider));
});

/// Provider untuk DeleteAllTransactionsUseCase
final deleteAllTransactionsUseCaseProvider = Provider<DeleteAllTransactionsUseCase>((ref) {
  return DeleteAllTransactionsUseCase(ref.read(transactionRepositoryProvider));
});

/// Provider untuk GetTransactionsUseCase
final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  return GetTransactionsUseCase(ref.read(transactionRepositoryProvider));
});

/// Provider untuk GetMonthlySummaryUseCase (split from get_monthly_summary.dart)
final getMonthlySummaryUseCaseProvider = Provider<GetMonthlySummaryUseCase>((ref) {
  return GetMonthlySummaryUseCase(ref.read(transactionRepositoryProvider));
});

/// Provider untuk GetCategoryBreakdownUseCase (split from get_monthly_summary.dart)
final getCategoryBreakdownUseCaseProvider = Provider<GetCategoryBreakdownUseCase>((ref) {
  return GetCategoryBreakdownUseCase(ref.read(transactionRepositoryProvider));
});

/// Provider untuk GetInsightsUseCase (split from get_monthly_summary.dart)
final getInsightsUseCaseProvider = Provider<GetInsightsUseCase>((ref) {
  return GetInsightsUseCase(
    ref.read(getMonthlySummaryUseCaseProvider),
    ref.read(getCategoryBreakdownUseCaseProvider),
  );
});

/// Provider untuk GetMultiMonthSummaryUseCase
final getMultiMonthSummaryUseCaseProvider = Provider<GetMultiMonthSummaryUseCase>((ref) {
  return GetMultiMonthSummaryUseCase(ref.read(transactionRepositoryProvider));
});

/// Provider untuk SearchTransactionsUseCase
final searchTransactionsUseCaseProvider = Provider<SearchTransactionsUseCase>((ref) {
  return SearchTransactionsUseCase(ref.read(transactionRepositoryProvider));
});

/// Provider untuk GetTransactionsPaginatedUseCase
final getTransactionsPaginatedUseCaseProvider = Provider<GetTransactionsPaginatedUseCase>((ref) {
  return GetTransactionsPaginatedUseCase(ref.read(transactionRepositoryProvider));
});

/// Provider untuk GetTransactionsPaginatedUseCase
/// Note: This is exported from transaction_list_paginated_provider.dart
/// This is kept here for backward compatibility during migration
