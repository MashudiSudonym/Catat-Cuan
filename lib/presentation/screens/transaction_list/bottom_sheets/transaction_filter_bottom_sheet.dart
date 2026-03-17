import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/utils/app_colors.dart';
import 'package:catat_cuan/presentation/utils/glassmorphism/app_glassmorphism.dart';
import 'package:intl/intl.dart';

/// Bottom sheet untuk filter transaksi
/// Following SRP: Only handles filter UI and state management
class TransactionFilterBottomSheet extends ConsumerStatefulWidget {
  final TransactionFilterState currentFilters;
  final Function(TransactionFilterState) onApply;
  final VoidCallback onClear;

  const TransactionFilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
    required this.onClear,
  });

  @override
  ConsumerState<TransactionFilterBottomSheet> createState() =>
      _TransactionFilterBottomSheetState();
}

class _TransactionFilterBottomSheetState
    extends ConsumerState<TransactionFilterBottomSheet> {
  late DateTime? startDate;
  late DateTime? endDate;
  late int? categoryId;
  late TransactionType? type;

  @override
  void initState() {
    super.initState();
    startDate = widget.currentFilters.startDate;
    endDate = widget.currentFilters.endDate;
    categoryId = widget.currentFilters.categoryId;
    type = widget.currentFilters.type;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adjustedBlur = GlassVariant.overlay.getAdjustedBlur(isDark: isDark);
    final adjustedAlpha = GlassVariant.overlay.getAdjustedAlpha(isDark: isDark);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: adjustedBlur, sigmaY: adjustedBlur),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.getGlassOverlay(isDark: isDark, alpha: adjustedAlpha),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(
                  top: BorderSide(
                    color: AppColors.getGlassBorder(isDark: isDark),
                    width: GlassBorder.width,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getGlassAmbientShadow(isDark: isDark),
                    blurRadius: adjustedBlur * 0.6,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildHandle(),
                  _buildHeader(),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildTypeFilter(),
                        const SizedBox(height: 24),
                        _buildDateRangeFilter(),
                        const SizedBox(height: 24),
                        _buildCategoryFilter(categories),
                      ],
                    ),
                  ),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filter Transaksi',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (widget.currentFilters.hasActiveFilter)
            TextButton(
              onPressed: widget.onClear,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.expense,
              ),
              child: const Text('Hapus Semua'),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipe Transaksi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<TransactionType?>(
          segments: const [
            ButtonSegment(value: null, label: Text('Semua')),
            ButtonSegment(
              value: TransactionType.expense,
              label: Text('Pengeluaran'),
            ),
            ButtonSegment(
              value: TransactionType.income,
              label: Text('Pemasukan'),
            ),
          ],
          selected: {type},
          onSelectionChanged: (Set<TransactionType?> newSelection) {
            setState(() {
              type = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rentang Tanggal',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickStartDate(),
                icon: const Icon(Icons.calendar_today),
                label: Text(startDate != null
                    ? DateFormat('dd MMM yyyy').format(startDate!)
                    : 'Dari Tanggal'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickEndDate(),
                icon: const Icon(Icons.calendar_today),
                label: Text(endDate != null
                    ? DateFormat('dd MMM yyyy').format(endDate!)
                    : 'Sampai Tanggal'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(CategoryListState categoryData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedLabelColor = isDark ? Colors.white70 : Colors.black87;
    final borderSideColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;

    return categoryData.when(
      data: (categories) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 12),
            ChipTheme(
              data: ChipThemeData(
                selectedColor: AppColors.primary,
                backgroundColor: Colors.transparent,
                labelStyle: WidgetStateTextStyle.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(color: Colors.white, fontWeight: FontWeight.w600);
                  }
                  return TextStyle(color: unselectedLabelColor);
                }),
                side: BorderSide(color: borderSideColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Semua'),
                    selected: categoryId == null,
                    onSelected: (selected) {
                      setState(() {
                        categoryId = selected ? null : categoryId;
                      });
                    },
                  ),
                  ...categories.map<Widget>((cat) {
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat.icon ?? '📦'),
                          const SizedBox(width: 4),
                          Text(cat.name),
                        ],
                      ),
                      selected: categoryId == cat.id,
                      onSelected: (selected) {
                        setState(() {
                          categoryId = selected ? cat.id : null;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => const Text('Gagal memuat kategori'),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(TransactionFilterState(
                  startDate: startDate,
                  endDate: endDate,
                  categoryId: categoryId,
                  type: type,
                ));
                Navigator.pop(context);
              },
              child: const Text('Terapkan'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (startDate != null && startDate!.isBefore(now))
          ? startDate!
          : now,
      firstDate: DateTime(2020), // Tanggal awal yang wajar
      lastDate: now, // Tidak bisa memilih tanggal masa depan
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        // Jika end date yang ada sekarang tidak valid (kurang dari start date atau lebih dari today), hapus
        if (endDate != null) {
          if (endDate!.isBefore(startDate!) || endDate!.isAfter(now)) {
            endDate = null;
          }
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();

    // Tentukan batas atas: tidak boleh melebihi hari ini
    final DateTime lastDate = now;

    // Tentukan batas bawah: tidak boleh sebelum "dari tanggal"
    DateTime firstDate;
    if (startDate != null) {
      // Jika "dari tanggal" sudah dipilih, gunakan itu sebagai batas bawah
      firstDate = startDate!;
    } else {
      // Jika belum ada "dari tanggal", gunakan tanggal yang wajar sebagai batas bawah
      firstDate = DateTime(2020);
    }

    // Tentukan initial date untuk date picker
    DateTime initialDate;
    if (endDate != null) {
      initialDate = endDate!;
      // Pastikan end date yang tersimpan masih dalam range yang valid
      if (initialDate.isBefore(firstDate)) {
        initialDate = firstDate;
      } else if (initialDate.isAfter(lastDate)) {
        initialDate = lastDate;
      }
    } else {
      // Jika belum ada end date yang dipilih:
      // - Jika ada start date, gunakan start date (tapi tidak boleh melebihi today)
      // - Jika tidak ada start date, gunakan today
      if (startDate != null && startDate!.isBefore(now)) {
        initialDate = startDate!;
      } else {
        initialDate = now;
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate, // Tidak boleh sebelum "dari tanggal"
      lastDate: lastDate, // Tidak boleh melebihi hari ini
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }
}

/// Helper untuk menampilkan filter bottom sheet
class TransactionFilterBottomSheetHelper {
  static void show(
    BuildContext context,
    WidgetRef ref,
    TransactionFilterState currentFilters,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionFilterBottomSheet(
        currentFilters: currentFilters,
        onApply: (filters) {
          ref.read(transactionListProvider.notifier).setFilters(filters);
        },
        onClear: () {
          ref.read(transactionListProvider.notifier).clearFilters();
          Navigator.pop(context);
        },
      ),
    );
  }
}
