import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/screens/transaction_form_screen.dart';
import 'package:catat_cuan/presentation/widgets/transaction_card.dart';
import 'package:catat_cuan/presentation/widgets/transaction_filter_chip.dart';
import 'package:catat_cuan/presentation/widgets/transaction_search_bar.dart';
import 'package:catat_cuan/presentation/widgets/export_bottom_sheet.dart';
import 'package:catat_cuan/presentation/screens/transaction_list/bottom_sheets/transaction_filter_bottom_sheet.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:intl/intl.dart';

/// Screen untuk menampilkan list transaksi
/// Menggunakan TransactionCard widget dan filter chips
/// Refactored untuk SOLID compliance:
/// - SRP: Screen hanya handle UI, business logic di notifier
/// - DIP: Depends on provider abstractions, not concrete implementations
/// - Pagination: Uses paginated provider with infinite scroll
class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottomReached) {
      ref.read(transactionListPaginatedNotifierProvider.notifier).loadMore();
    }
  }

  bool get _isBottomReached {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Load when 80% scrolled
    return currentScroll >= (maxScroll * 0.8);
  }

  @override
  Widget build(BuildContext context) {
    final paginatedState = ref.watch(transactionListPaginatedNotifierProvider);
    final filterState = ref.watch(transactionFilterNotifierProvider);
    final searchAsync = ref.watch(transactionSearchNotifierProvider);
    final hasSearchQuery = searchAsync.value?.isNotEmpty == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          // Export button
          if (paginatedState.transactions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.file_download),
              tooltip: 'Ekspor CSV',
              onPressed: () {
                ExportOptionsBottomSheet.show(
                  context,
                  currentTypeFilter: filterState.type,
                );
              },
            ),
          // Delete all transactions button (only visible if there are transactions)
          if (paginatedState.transactions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Hapus Semua Transaksi',
              onPressed: () => _showDeleteAllDialog(context, ref),
            ),
          // Filter button (AC-LOG-005.3)
          IconButton(
            icon: Icon(
              filterState.hasActiveFilter ? Icons.filter_list_alt : Icons.filter_list,
              color: filterState.hasActiveFilter ? AppColors.primary : null,
            ),
            onPressed: () {
              TransactionFilterBottomSheetHelper.show(context, ref, filterState);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          TransactionSearchBar(currentTypeFilter: filterState.type),

          // Filter chips for quick filtering by type
          _buildFilterChips(context, ref, filterState),

          // Content - using paginated state
          Expanded(
            child: hasSearchQuery
                ? _buildSearchResults(context, ref, searchAsync)
                : _buildPaginatedContent(context, ref, paginatedState),
          ),
        ],
      ),
    );
  }

  /// Build paginated transaction list (non-search mode)
  Widget _buildPaginatedContent(
    BuildContext context,
    WidgetRef ref,
    PaginatedTransactionListState state,
  ) {
    // Initial loading state
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (state.error != null) {
      return _ErrorState(
        error: state.error!,
        onRetry: () => ref.read(transactionListPaginatedNotifierProvider.notifier).refresh(),
      );
    }

    // Empty state
    if (state.transactions.isEmpty) {
      return _buildEmptyState(context);
    }

    // Get categories for display
    final categories = ref.watch(categoryListNotifierProvider);

    return categories.when(
      data: (categoryData) {
        // Group transactions by date
        final groupedTransactions = _groupTransactionsByDate(state.transactions);

        return RefreshIndicator(
          onRefresh: () => ref.read(transactionListPaginatedNotifierProvider.notifier).refresh(),
          child: ListView.builder(
            controller: _scrollController,
            padding: AppSpacing.only(bottom: AppSpacing.lg),
            itemCount: groupedTransactions.length + (state.hasNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              // Loading indicator at bottom
              if (index == groupedTransactions.length) {
                return state.isLoadingMore
                    ? const Padding(
                        padding: AppSpacing.lgAll,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox.shrink();
              }

              final group = groupedTransactions[index];
              final groupDate = group['date'] as DateTime;
              final transactions = group['transactions'] as List<TransactionEntity>;
              final totalAmount = group['total'] as double;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header with total
                  TransactionDateHeader(
                    date: groupDate,
                    totalAmount: totalAmount,
                  ),
                  // Transactions for this date
                  ...transactions.map((transaction) {
                    final category = categoryData.firstWhere(
                      (c) => c.id == transaction.categoryId,
                      orElse: () => categoryData.isNotEmpty
                          ? categoryData.first
                          : _createDefaultCategory(),
                    );
                    return TransactionCard(
                      transaction: transaction,
                      category: category,
                      onEdit: () {
                        // Navigate to edit screen (AC-LOG-006.1)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionFormScreen(
                              transactionToEdit: transaction,
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        // Show delete confirmation (AC-LOG-007.2)
                        _showDeleteDialog(context, ref, transaction);
                      },
                    );
                  }),
                ],
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => const Center(child: Text('Gagal memuat kategori')),
    );
  }

  /// Build search results
  Widget _buildSearchResults(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<TransactionEntity>> searchAsync,
  ) {
    return searchAsync.when(
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            AppSpacingWidget.verticalLG(),
            Text('Mencari...'),
          ],
        ),
      ),
      error: (error, stack) => _ErrorState(
        error: error.toString(),
        onRetry: () => ref.invalidate(transactionSearchNotifierProvider),
      ),
      data: (transactions) {
        if (transactions.isEmpty) {
          return _buildNoSearchResults(context, ref);
        }
        return _buildTransactionList(context, ref, transactions);
      },
    );
  }

  /// Build empty state for no search results
  Widget _buildNoSearchResults(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? AppColors.textOnDark.withValues(alpha: 0.7)
        : AppColors.textSecondary;
    return Center(
      child: Padding(
        padding: AppSpacing.xxxlAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppGlassContainer.glassPill(
              width: 100,
              height: 100,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              child: Icon(
                Icons.search_off,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const AppSpacingWidget.verticalXL(),
            Text(
              'Tidak Ditemukan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const AppSpacingWidget.verticalSM(),
            Text(
              'Coba kata kunci lain atau periksa filter Anda',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: secondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const AppSpacingWidget.verticalLG(),
            TextButton.icon(
              onPressed: () {
                ref.read(transactionSearchNotifierProvider.notifier).clear();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Hapus Pencarian'),
            ),
          ],
        ),
      ),
    );
  }

  /// Filter chips untuk filter cepat berdasarkan tipe
  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef ref,
    TransactionFilterState filterState,
  ) {
    return TransactionFilterChip(
      selectedType: filterState.type,
      onTypeChanged: (type) {
        final notifier = ref.read(transactionListPaginatedNotifierProvider.notifier);
        // Use withType() to properly handle null values (for "Semua" option)
        notifier.setFilters(filterState.withType(type));
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary;
    return Center(
      child: Padding(
        padding: AppSpacing.xxxlAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppGlassContainer.glassPill(
              width: 100,
              height: 100,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              child: Icon(
                Icons.receipt_long_outlined,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const AppSpacingWidget.verticalXL(),
            Text(
              'Belum ada transaksi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const AppSpacingWidget.verticalSM(),
            Text(
              'Tekan tombol Tambah di navigasi bawah untuk menambah transaksi baru',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: secondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    WidgetRef ref,
    List<TransactionEntity> transactions,
  ) {
    // Get categories for display
    final categories = ref.watch(categoryListNotifierProvider);

    return categories.when(
      data: (categoryData) {
        // Group transactions by date
        final groupedTransactions = _groupTransactionsByDate(transactions);

        return ListView.builder(
          padding: AppSpacing.only(bottom: AppSpacing.lg),
          itemCount: groupedTransactions.length,
          itemBuilder: (context, index) {
            final group = groupedTransactions[index];
            final groupDate = group['date'] as DateTime;
            final transactions = group['transactions'] as List<TransactionEntity>;
            final totalAmount = group['total'] as double;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date header with total
                TransactionDateHeader(
                  date: groupDate,
                  totalAmount: totalAmount,
                ),
                // Transactions for this date
                ...transactions.map((transaction) {
                  final category = categoryData.firstWhere(
                    (c) => c.id == transaction.categoryId,
                    orElse: () => categoryData.isNotEmpty
                        ? categoryData.first
                        : _createDefaultCategory(),
                  );
                  return TransactionCard(
                    transaction: transaction,
                    category: category,
                    onEdit: () {
                      // Navigate to edit screen (AC-LOG-006.1)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionFormScreen(
                            transactionToEdit: transaction,
                          ),
                        ),
                      );
                    },
                    onDelete: () {
                      // Show delete confirmation (AC-LOG-007.2)
                      _showDeleteDialog(context, ref, transaction);
                    },
                  );
                }),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => const Center(child: Text('Gagal memuat kategori')),
    );
  }

  /// Group transactions by date
  List<Map<String, dynamic>> _groupTransactionsByDate(
      List<TransactionEntity> transactions) {
    final Map<String, Map<String, dynamic>> grouped = {};

    for (var transaction in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.dateTime);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = {
          'date': DateTime(
            transaction.dateTime.year,
            transaction.dateTime.month,
            transaction.dateTime.day,
          ),
          'transactions': <TransactionEntity>[],
          'total': 0.0,
        };
      }

      grouped[dateKey]!['transactions'].add(transaction);

      // Calculate total (income - expense)
      final amount = transaction.type == TransactionType.income
          ? transaction.amount
          : -transaction.amount;
      grouped[dateKey]!['total'] =
          (grouped[dateKey]!['total'] as double) + amount;
    }

    // Convert to list and sort by date descending
    final sortedList = grouped.values.toList()
      ..sort((a, b) => (b['date'] as DateTime)
          .compareTo(a['date'] as DateTime));

    return sortedList;
  }

  CategoryEntity _createDefaultCategory() {
    return CategoryEntity(
      id: 0,
      name: 'Umum',
      type: CategoryType.expense,
      color: 'FF64748B',
      icon: '📦',
      sortOrder: 0,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    TransactionEntity transaction,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text(
          'Apakah Anda yakin ingin menghapus transaksi ini?\n\n'
          '${transaction.amount.toRupiah()}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(deleteTransactionUseCaseProvider)
                    .execute(transaction.id!);
                if (context.mounted) {
                  // Invalidate all transaction list providers and summary to trigger refresh
                  ref.invalidate(transactionListNotifierProvider);
                  ref.invalidate(transactionListPaginatedNotifierProvider);
                  ref.invalidate(monthlySummaryNotifierProvider);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaksi berhasil dihapus'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus transaksi: $e'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.expense,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Transaksi'),
        content: const Text(
          '⚠️ PERINGATAN!\n\n'
          'Semua transaksi akan dihapus secara permanen. '
          'Tindakan ini TIDAK DAPAT dibatalkan.\n\n'
          'Apakah Anda yakin ingin melanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(deleteAllTransactionsUseCaseProvider).execute();
                if (context.mounted) {
                  // Invalidate all transaction list providers and summary to trigger refresh
                  ref.invalidate(transactionListNotifierProvider);
                  ref.invalidate(transactionListPaginatedNotifierProvider);
                  ref.invalidate(monthlySummaryNotifierProvider);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua transaksi berhasil dihapus'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus transaksi: $e'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }
}

/// Error state widget
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary;
    return Center(
      child: Padding(
        padding: AppSpacing.xxlAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppGlassContainer.glassPill(
              width: 80,
              height: 80,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const AppSpacingWidget.verticalXL(),
            Text(
              'Terjadi Kesalahan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const AppSpacingWidget.verticalSM(),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: secondaryColor,
                  ),
            ),
            const AppSpacingWidget.verticalXXL(),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
