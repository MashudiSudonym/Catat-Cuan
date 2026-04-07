import 'package:catat_cuan/data/datasources/widget/widget_local_datasource.dart';
import 'package:catat_cuan/data/repositories/widget/widget_repository_impl.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/entities/widget/widget_data_entity.dart';
import 'package:catat_cuan/presentation/providers/currency/currency_provider.dart';
import 'package:catat_cuan/presentation/providers/transaction/transaction_list_paginated_provider.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'widget_provider.g.dart';

/// Provider untuk WidgetLocalDatasource
///
/// Provides data source for widget storage operations
@riverpod
WidgetLocalDatasource widgetLocalDatasource(Ref ref) {
  return WidgetLocalDatasource();
}

/// Provider untuk WidgetRepository
///
/// Following DIP: Provides WidgetRepository abstraction
/// Uses WidgetLocalDatasource for data operations
@riverpod
WidgetRepositoryImpl widgetRepository(Ref ref) {
  final datasource = ref.watch(widgetLocalDatasourceProvider);
  return WidgetRepositoryImpl(datasource);
}

/// Notifier untuk mengelola data widget
///
/// Responsibility:
/// - Update widget data setelah transaksi berubah
/// - Menyediakan data untuk widget (ringkasan bulanan + transaksi terakhir)
/// - Trigger update widget native
///
/// Uses AsyncNotifier untuk proper async handling
@riverpod
class WidgetNotifier extends _$WidgetNotifier {
  @override
  Future<void> build() async {
    // Initialize on first build
    // Widget data akan diupdate secara otomatis saat transaksi berubah
    AppLogger.d('WidgetNotifier initialized');
    return;
  }

  /// Update widget data dengan data terbaru
  ///
  /// Dipanggil setelah ada perubahan transaksi (add/edit/delete)
  /// Mengambil data dari providers lain dan menyimpannya ke widget storage
  Future<void> updateWidget() async {
    AppLogger.d('Updating widget data...');

    try {
      // Get current currency
      final currencyState = ref.read(currencyProvider);
      final currencyCode = currencyState.currencyOption.name;

      // Get current year-month
      final now = DateTime.now();
      final yearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      // Get transactions for current month (limit to 100 for widget)
      final transactionListState = ref.read(transactionListPaginatedProvider);

      // Filter transactions for current month
      final currentMonthTransactions = (transactionListState.transactions)
          .where((t) {
        final txYearMonth =
            '${t.dateTime.year}-${t.dateTime.month.toString().padLeft(2, '0')}';
        return txYearMonth == yearMonth;
      }).toList();

      // Calculate summary
      double totalExpense = 0;
      double totalIncome = 0;

      for (final tx in currentMonthTransactions) {
        if (tx.type == TransactionType.expense) {
          totalExpense += tx.amount;
        } else {
          totalIncome += tx.amount;
        }
      }

      // Get recent transactions (last 3)
      final recentTransactions = currentMonthTransactions
          .take(3)
          .map((tx) => _toPreviewEntity(tx))
          .toList();

      // Create widget data
      final widgetData = WidgetDataEntity(
        currentMonthExpenses: totalExpense,
        currentMonthIncome: totalIncome,
        transactionCount: currentMonthTransactions.length,
        recentTransactions: recentTransactions,
        lastUpdated: DateTime.now(),
        currency: currencyCode,
      );

      // Save to repository
      final repository = ref.read(widgetRepositoryProvider);
      final result = await repository.updateWidgetData(widgetData);

      if (result.isFailure) {
        AppLogger.e('Failed to update widget: ${result.failure?.message}');
      } else {
        AppLogger.i('Widget data updated successfully');
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error updating widget', e, stackTrace);
    }
  }

  /// Convert TransactionEntity ke TransactionPreviewEntity untuk widget
  TransactionPreviewEntity _toPreviewEntity(TransactionEntity tx) {
    // Get category info - for now just use basic info
    // In production, you'd want to get the actual category
    return TransactionPreviewEntity(
      id: tx.id ?? 0,
      title: tx.note ?? 'Transaksi',
      amount: tx.amount,
      category: _getCategoryName(tx.categoryId),
      categoryColor: '#FF6B35', // Default orange
      date: tx.dateTime,
      isExpense: tx.type == TransactionType.expense,
    );
  }

  /// Get category name by ID
  /// TODO: Implement proper category lookup from cache
  String _getCategoryName(int categoryId) {
    // For now, return a default name
    // In production, you'd want to maintain a category cache
    return 'Umum';
  }

  /// Refresh widget tanpa mengubah data
  ///
  /// Berguna untuk force refresh widget setelah konfigurasi berubah
  Future<void> refreshWidget() async {
    AppLogger.d('Refreshing widget...');

    try {
      final repository = ref.read(widgetRepositoryProvider);
      final result = await repository.refreshWidget();

      if (result.isFailure) {
        AppLogger.e('Failed to refresh widget: ${result.failure?.message}');
      } else {
        AppLogger.i('Widget refreshed successfully');
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error refreshing widget', e, stackTrace);
    }
  }

  /// Clear widget data
  ///
  /// Berguna untuk logout atau reset
  Future<void> clearWidget() async {
    AppLogger.d('Clearing widget data...');

    try {
      final datasource = ref.read(widgetLocalDatasourceProvider);
      await datasource.clearWidgetData();
      await datasource.triggerWidgetUpdate();

      AppLogger.i('Widget data cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.e('Error clearing widget', e, stackTrace);
    }
  }
}
