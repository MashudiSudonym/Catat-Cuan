/// Central exports for all providers
/// Following SRP: Each module has its own provider file, this file only exports them
library;

// ============================================================================
// Core Dependencies
// ============================================================================

// Repository providers
export 'repositories/repository_providers.dart';

// Use case providers
export 'usecases/transaction_usecase_providers.dart';
export 'usecases/category_usecase_providers.dart';

// Service providers
export 'services/service_providers.dart';

// Theme provider
export 'theme/theme_provider.dart';

// ============================================================================
// Feature Providers (Refactored with @riverpod)
// ============================================================================

// Navigation
export 'navigation/navigation_provider.dart';

// Transaction providers
export 'transaction/transaction_filter_provider.dart';
export 'transaction/transaction_list_provider.dart';
export 'transaction/transaction_form_provider.dart';

// Category providers
export 'category/category_list_provider.dart';
export 'category/category_form_provider.dart';
export 'category/category_management_provider.dart';

// Summary providers
export 'summary/monthly_summary_provider.dart';

// Scan providers
export 'scan/receipt_scan_provider.dart';

// ============================================================================
// State Classes (for backward compatibility with UI)
// ============================================================================

// Note: TransactionFilterState is now in transaction_filter_provider.dart
// TransactionFormState remains in states/transaction_form_state.dart

export 'package:catat_cuan/presentation/states/transaction_form_state.dart';

// Export MonthlySummaryData for backward compatibility (as MonthlySummaryState alias)
export 'package:catat_cuan/presentation/providers/summary/monthly_summary_provider.dart' show MonthlySummaryData;

// ============================================================================
// Legacy Providers (to be removed after UI migration)
// ============================================================================

// These are kept for backward compatibility during migration
// TODO: Remove after UI is updated to use new providers
export 'notifiers/transaction_provider.dart';
export 'package:catat_cuan/presentation/states/transaction_list_state.dart';

// ============================================================================
// Additional Use Case Providers & Initialization
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/providers/navigation/navigation_provider.dart';
import 'package:catat_cuan/presentation/providers/transaction/transaction_filter_provider.dart';
import 'package:catat_cuan/presentation/providers/transaction/transaction_list_provider.dart';
import 'package:catat_cuan/presentation/providers/transaction/transaction_form_provider.dart';
import 'package:catat_cuan/presentation/providers/category/category_list_provider.dart';
import 'package:catat_cuan/presentation/providers/category/category_form_provider.dart';
import 'package:catat_cuan/presentation/providers/category/category_management_provider.dart';
import 'package:catat_cuan/presentation/providers/summary/monthly_summary_provider.dart';
import 'package:catat_cuan/presentation/providers/scan/receipt_scan_provider.dart';
import 'package:catat_cuan/presentation/providers/usecases/category_usecase_providers.dart';

// Aliases for backward compatibility (deprecated - use *NotifierProvider directly)
@Deprecated('Use navigationNotifierProvider instead')
final navigationProvider = navigationNotifierProvider;

@Deprecated('Use transactionFilterNotifierProvider instead')
final transactionFilterProvider = transactionFilterNotifierProvider;

@Deprecated('Use transactionListNotifierProvider instead')
final transactionListProvider = transactionListNotifierProvider;

@Deprecated('Use transactionFormNotifierProvider instead')
final transactionFormProvider = transactionFormNotifierProvider;

@Deprecated('Use categoryListNotifierProvider instead')
final categoryListProvider = categoryListNotifierProvider;

@Deprecated('Use categoryFormNotifierProvider instead')
final categoryFormProvider = categoryFormNotifierProvider;

@Deprecated('Use categoryManagementNotifierProvider instead')
final categoryManagementProvider = categoryManagementNotifierProvider;

@Deprecated('Use monthlySummaryNotifierProvider instead')
final monthlySummaryProvider = monthlySummaryNotifierProvider;

@Deprecated('Use receiptScanNotifierProvider instead')
final receiptScanProvider = receiptScanNotifierProvider;

/// Simple cache provider to track initialization state
final cacheProvider = StateProvider<Map<String, bool>>((ref) => {});

/// Provider untuk inisialisasi data awal (seed categories)
/// Menggunakan FutureProvider dengan cache untuk mencegah re-execution saat app resume
final appInitializationProvider = FutureProvider<void>((ref) async {
  // Keep the provider alive even when no one is listening
  ref.keepAlive();

  // Use a cache key to track if we've already initialized
  const cacheKey = 'app_initialized';
  final cache = ref.read(cacheProvider);

  // If already initialized, skip
  if (cache[cacheKey] == true) {
    return;
  }

  // Perform initialization
  final getCategoriesUseCase = ref.read(getCategoriesUseCaseProvider);

  // Cek apakah perlu seed default categories
  if (await getCategoriesUseCase.needsSeed()) {
    await getCategoriesUseCase.seedDefaultCategories();
  }

  // Mark as initialized
  ref.read(cacheProvider.notifier).state = {...cache, cacheKey: true};
});
