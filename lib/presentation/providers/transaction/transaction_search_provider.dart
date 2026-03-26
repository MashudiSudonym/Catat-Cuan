import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/usecases/search_transactions_usecase.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:catat_cuan/presentation/providers/usecases/transaction_usecase_providers.dart';

part 'transaction_search_provider.g.dart';

/// Provider untuk transaction search
/// Following SRP: Only manages search state and operations
/// Following DIP: Depends on UseCase abstraction, not concrete implementation
/// Uses AsyncNotifier for proper async handling without constructor side effects
@riverpod
class TransactionSearchNotifier extends _$TransactionSearchNotifier {
  @override
  Future<List<TransactionEntity>> build() async {
    // No constructor side effects - initialize with empty list
    return [];
  }

  /// Mencari transaksi berdasarkan query
  /// Pencarian dilakukan pada note dan nama kategori
  /// - [query]: Kata kunci pencarian
  /// - [type]: Filter tipe transaksi (opsional)
  Future<void> search(
    String query, {
    TransactionType? type,
  }) async {
    // Return empty list jika query kosong
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    // Set loading state
    state = const AsyncValue.loading();

    final searchUseCase = ref.read(searchTransactionsUseCaseProvider);

    final result = await searchUseCase(SearchTransactionsParams(
      query: query,
      type: type,
    ));

    if (result.isFailure) {
      AppLogger.e('Search failed: ${result.failure?.message}');
      state = AsyncValue.data([]);
    } else {
      state = AsyncValue.data(result.data ?? []);
    }
  }

  /// Clear search results
  void clear() {
    state = const AsyncValue.data([]);
  }
}
