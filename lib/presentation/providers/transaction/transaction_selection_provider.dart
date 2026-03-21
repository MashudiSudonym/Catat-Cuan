import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_selection_provider.g.dart';

/// State untuk multi-select mode pada transaksi
class TransactionSelectionState {
  /// Set ID transaksi yang dipilih
  final Set<int> selectedIds;

  /// Apakah selection mode sedang aktif
  final bool isSelectionModeActive;

  const TransactionSelectionState({
    this.selectedIds = const {},
    this.isSelectionModeActive = false,
  });

  TransactionSelectionState copyWith({
    Set<int>? selectedIds,
    bool? isSelectionModeActive,
  }) {
    return TransactionSelectionState(
      selectedIds: selectedIds ?? this.selectedIds,
      isSelectionModeActive: isSelectionModeActive ?? this.isSelectionModeActive,
    );
  }

  /// Jumlah item yang dipilih
  int get selectedCount => selectedIds.length;

  /// Apakah ada item yang dipilih
  bool get hasSelection => selectedIds.isNotEmpty;
}

/// Provider untuk state multi-select transaksi
@riverpod
class TransactionSelectionNotifier extends _$TransactionSelectionNotifier {
  @override
  TransactionSelectionState build() {
    return const TransactionSelectionState();
  }

  /// Toggle selection mode dengan item pertama yang dipilih
  void toggleSelectionMode(int transactionId) {
    state = TransactionSelectionState(
      selectedIds: {transactionId},
      isSelectionModeActive: true,
    );
  }

  /// Toggle item selection (tambah/hapus dari selection)
  void toggleSelection(int transactionId) {
    if (!state.isSelectionModeActive) {
      // Activate selection mode with this item selected
      toggleSelectionMode(transactionId);
      return;
    }

    final newSelectedIds = Set<int>.from(state.selectedIds);

    if (newSelectedIds.contains(transactionId)) {
      newSelectedIds.remove(transactionId);
      // If no more selections, exit selection mode
      if (newSelectedIds.isEmpty) {
        state = const TransactionSelectionState();
        return;
      }
    } else {
      newSelectedIds.add(transactionId);
    }

    state = state.copyWith(selectedIds: newSelectedIds);
  }

  /// Select multiple items sekaligus
  void selectMultiple(List<int> ids) {
    if (ids.isEmpty) return;

    final newSelectedIds = Set<int>.from(state.selectedIds);
    newSelectedIds.addAll(ids);

    state = TransactionSelectionState(
      selectedIds: newSelectedIds,
      isSelectionModeActive: true,
    );
  }

  /// Select all items dari daftar yang tersedia
  void selectAll(List<int> allAvailableIds) {
    if (allAvailableIds.isEmpty) return;

    state = TransactionSelectionState(
      selectedIds: Set<int>.from(allAvailableIds),
      isSelectionModeActive: true,
    );
  }

  /// Deselect all (jika sudah all selected, ini akan deselect semua)
  void deselectAll() {
    state = const TransactionSelectionState(
      isSelectionModeActive: true,
    );
  }

  /// Toggle select all / deselect all
  void toggleSelectAll(List<int> allAvailableIds) {
    if (state.selectedIds.length == allAvailableIds.length) {
      // All selected, deselect all
      deselectAll();
    } else {
      // Not all selected, select all
      selectAll(allAvailableIds);
    }
  }

  /// Clear selection dan exit selection mode
  void clearSelection() {
    state = const TransactionSelectionState();
  }
}
