import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/usecases/add_transaction.dart';
import 'package:catat_cuan/domain/usecases/delete_transaction.dart';
import 'package:catat_cuan/domain/usecases/delete_all_transactions.dart';
import 'package:catat_cuan/domain/usecases/delete_multiple_transactions_usecase.dart';
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
  return AddTransactionUseCase(
    ref.read(transactionWriteRepositoryProvider),
  );
});

/// Provider untuk UpdateTransactionUseCase
final updateTransactionUseCaseProvider = Provider<UpdateTransactionUseCase>((ref) {
  return UpdateTransactionUseCase(
    ref.read(transactionWriteRepositoryProvider),
  );
});

/// Provider untuk DeleteTransactionUseCase
final deleteTransactionUseCaseProvider = Provider<DeleteTransactionUseCase>((ref) {
  return DeleteTransactionUseCase(
    ref.read(transactionWriteRepositoryProvider),
  );
});

/// Provider untuk DeleteAllTransactionsUseCase
final deleteAllTransactionsUseCaseProvider = Provider<DeleteAllTransactionsUseCase>((ref) {
  return DeleteAllTransactionsUseCase(
    ref.read(transactionWriteRepositoryProvider),
  );
});

/// Provider untuk DeleteMultipleTransactionsUseCase
final deleteMultipleTransactionsUseCaseProvider = Provider<DeleteMultipleTransactionsUseCase>((ref) {
  return DeleteMultipleTransactionsUseCase(
    ref.read(transactionWriteRepositoryProvider),
  );
});

/// Provider untuk GetTransactionsUseCase
final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  return GetTransactionsUseCase(
    ref.read(transactionReadRepositoryProvider),
  );
});

/// Provider untuk GetTransactionsByFilterUseCase
final getTransactionsByFilterUseCaseProvider = Provider<GetTransactionsByFilterUseCase>((ref) {
  return GetTransactionsByFilterUseCase(
    ref.read(transactionQueryRepositoryProvider),
  );
});

/// Provider untuk GetTransactionByIdUseCase
final getTransactionByIdUseCaseProvider = Provider<GetTransactionByIdUseCase>((ref) {
  return GetTransactionByIdUseCase(
    ref.read(transactionReadRepositoryProvider),
  );
});

/// Provider untuk GetMonthlySummaryUseCase
final getMonthlySummaryUseCaseProvider = Provider<GetMonthlySummaryUseCase>((ref) {
  return GetMonthlySummaryUseCase(
    ref.read(transactionAnalyticsRepositoryProvider),
  );
});

/// Provider untuk GetAllTimeSummaryUseCase
final getAllTimeSummaryUseCaseProvider = Provider<GetAllTimeSummaryUseCase>((ref) {
  return GetAllTimeSummaryUseCase(
    ref.read(transactionAnalyticsRepositoryProvider),
  );
});

/// Provider untuk GetCategoryBreakdownUseCase
final getCategoryBreakdownUseCaseProvider = Provider<GetCategoryBreakdownUseCase>((ref) {
  return GetCategoryBreakdownUseCase(
    ref.read(transactionAnalyticsRepositoryProvider),
  );
});

/// Provider untuk GetAllCategoryBreakdownUseCase
final getAllCategoryBreakdownUseCaseProvider = Provider<GetAllCategoryBreakdownUseCase>((ref) {
  return GetAllCategoryBreakdownUseCase(
    ref.read(transactionAnalyticsRepositoryProvider),
  );
});

/// Provider untuk GetInsightsUseCase
final getInsightsUseCaseProvider = Provider<GetInsightsUseCase>((ref) {
  return GetInsightsUseCase(
    ref.read(getMonthlySummaryUseCaseProvider),
    ref.read(getCategoryBreakdownUseCaseProvider),
  );
});

/// Provider untuk GetMultiMonthSummaryUseCase
final getMultiMonthSummaryUseCaseProvider = Provider<GetMultiMonthSummaryUseCase>((ref) {
  return GetMultiMonthSummaryUseCase(
    ref.read(transactionAnalyticsRepositoryProvider),
  );
});

/// Provider untuk SearchTransactionsUseCase
final searchTransactionsUseCaseProvider = Provider<SearchTransactionsUseCase>((ref) {
  return SearchTransactionsUseCase(
    ref.read(transactionSearchRepositoryProvider),
  );
});

/// Provider untuk GetTransactionsPaginatedUseCase
final getTransactionsPaginatedUseCaseProvider = Provider<GetTransactionsPaginatedUseCase>((ref) {
  return GetTransactionsPaginatedUseCase(
    ref.read(transactionQueryRepositoryProvider),
  );
});
