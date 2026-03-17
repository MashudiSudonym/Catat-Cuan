import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/presentation/providers/transaction/transaction_search_provider.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Search bar untuk mencari transaksi
/// Pencarian dilakukan pada note dan nama kategori dengan debouncing
class TransactionSearchBar extends ConsumerStatefulWidget {
  final TransactionType? currentTypeFilter;

  const TransactionSearchBar({
    super.key,
    this.currentTypeFilter,
  });

  @override
  ConsumerState<TransactionSearchBar> createState() =>
      _TransactionSearchBarState();
}

class _TransactionSearchBarState extends ConsumerState<TransactionSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Debounce search untuk menghindari query berlebihan
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(transactionSearchNotifierProvider.notifier).search(
            query,
            type: widget.currentTypeFilter,
          );
    });
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(transactionSearchNotifierProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    return AppGlassContainer.glassSurface(
      padding: AppSpacing.all(AppSpacing.md),
      margin: AppSpacing.horizontal(AppSpacing.lg),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Cari catatan atau kategori...',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14),
                isDense: true,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          // Clear button hanya muncul jika ada teks
          if (_controller.text.isNotEmpty)
            InkWell(
              onTap: _clearSearch,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.clear, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}
