import 'package:catat_cuan/domain/entities/transaction_entity.dart';
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

    try {
      final results = await searchUseCase.execute(query, type: type);
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Clear search results
  void clear() {
    state = const AsyncValue.data([]);
  }
}
