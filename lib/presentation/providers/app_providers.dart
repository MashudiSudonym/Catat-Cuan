/// Central exports for all providers
/// Following SRP: Each module has its own provider file, this file only exports them
library;

// ============================================================================
// Core Dependencies
// ============================================================================

// App widgets
export 'package:catat_cuan/presentation/app/app_widget.dart';
export 'package:catat_cuan/presentation/app/initialization_screen.dart';
export 'package:catat_cuan/presentation/app/error_screen.dart';

// Repository providers
export 'repositories/repository_providers.dart';

// Use case providers
export 'usecases/transaction_usecase_providers.dart';
export 'usecases/category_usecase_providers.dart';

// Service providers
export 'services/service_providers.dart';

// Theme provider
export 'theme/theme_provider.dart';

// Currency provider
export 'currency/currency_provider.dart';

// ============================================================================
// Feature Providers (Refactored with @riverpod)
// ============================================================================

// Navigation
export 'navigation/navigation_provider.dart';
export 'package:catat_cuan/presentation/navigation/providers/router_provider.dart';

// Transaction providers
export 'transaction/transaction_filter_provider.dart';
export 'transaction/transaction_list_provider.dart';
export 'transaction/transaction_form_provider.dart';
export 'transaction/transaction_search_provider.dart';
export 'transaction/transaction_list_paginated_provider.dart';
export 'transaction/transaction_selection_provider.dart';

// Category providers
export 'category/category_list_provider.dart';
export 'category/category_form_provider.dart';
export 'category/category_management_provider.dart';

// Summary providers
export 'summary/monthly_summary_provider.dart';

// Scan providers
export 'scan/receipt_scan_provider.dart';

// Export providers
export 'export/export_provider.dart';

// Onboarding providers
export 'onboarding/onboarding_provider.dart';

// Controller providers (SRP refactoring)
export 'controllers/controller_providers.dart';

// ============================================================================
// State Classes (for backward compatibility with UI)
// ============================================================================

// Note: TransactionFilterState is now in transaction_filter_provider.dart
// TransactionFormState remains in states/transaction_form_state.dart

export 'package:catat_cuan/presentation/states/transaction_form_state.dart';

// Export MonthlySummaryData for backward compatibility (as MonthlySummaryState alias)
export 'package:catat_cuan/presentation/providers/summary/monthly_summary_provider.dart' show MonthlySummaryData;

// ============================================================================
// Additional Use Case Providers & Initialization
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/providers/repositories/repository_providers.dart';
import 'package:catat_cuan/presentation/providers/cache_provider.dart';

/// Provider untuk inisialisasi data awal (seed categories)
/// Menggunakan FutureProvider dengan cache untuk mencegah re-execution saat app resume
final appInitializationProvider = FutureProvider<void>((ref) async {
  // Keep the provider alive even when no one is listening
  ref.keepAlive();

  // Use a cache key to track if we've already initialized
  const cacheKey = 'app_initialized';

  // If already initialized, skip
  if (ref.read(cacheProvider.notifier).isSet(cacheKey)) {
    return;
  }

  // Perform initialization
  final categorySeedingRepository = ref.read(categorySeedingRepositoryProvider);

  // Cek apakah perlu seed default categories
  final needsSeedResult = await categorySeedingRepository.needsSeed();

  if (needsSeedResult.isSuccess && (needsSeedResult.data ?? false)) {
    await categorySeedingRepository.seedDefaultCategories();
  }

  // Mark as initialized
  ref.read(cacheProvider.notifier).set(cacheKey);
});
