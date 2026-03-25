import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/entities/export_action_entity.dart';
import 'package:catat_cuan/domain/usecases/export_transactions_usecase.dart';
import 'package:catat_cuan/presentation/providers/repositories/repository_providers.dart';
import 'package:catat_cuan/data/services/csv_export_service_impl.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';

part 'export_provider.g.dart';

/// Export state following SRP
class ExportState {
  final bool isLoading;
  final String? filePath;
  final String? errorMessage;
  final ExportAction? lastAction;

  const ExportState({
    this.isLoading = false,
    this.filePath,
    this.errorMessage,
    this.lastAction,
  });

  factory ExportState.idle() => const ExportState();
  factory ExportState.loading() => const ExportState(isLoading: true);
  factory ExportState.success(String filePath, [ExportAction? action]) =>
      ExportState(filePath: filePath, lastAction: action);
  factory ExportState.error(String message) => ExportState(errorMessage: message);

  bool get isIdle => !isLoading && filePath == null && errorMessage == null;
  bool get isSuccess => filePath != null;
  bool get isError => errorMessage != null;
}

/// Provider untuk export service
@riverpod
CsvExportServiceImpl exportService(Ref ref) {
  return CsvExportServiceImpl();
}

/// Provider untuk ExportTransactionsUseCase
@riverpod
ExportTransactionsUseCase exportTransactionsUseCase(Ref ref) {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  final exportService = ref.watch(exportServiceProvider);
  return ExportTransactionsUseCase(transactionRepository, exportService);
}

/// Provider untuk export state management
/// Following SRP: Only manages export state and operations
/// Following DIP: Depends on UseCase abstraction, not concrete implementation
@riverpod
class ExportNotifier extends _$ExportNotifier {
  @override
  ExportState build() {
    return ExportState.idle();
  }

  /// Export transactions with optional filters
  Future<void> exportTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
    String? fileNameSuffix,
  }) async {
    AppLogger.d('Starting export with filters');
    state = ExportState.loading();

    final exportUseCase = ref.read(exportTransactionsUseCaseProvider);

    final result = await exportUseCase.execute(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      type: type,
      fileNameSuffix: fileNameSuffix,
    );

    if (result.isSuccess) {
      AppLogger.i('Export successful: ${result.data}');
      state = ExportState.success(result.data!);
    } else {
      AppLogger.w('Export failed: ${result.failure?.message}');
      state = ExportState.error(result.failure!.message);
    }
  }

  /// Save transactions to CSV file on device storage
  Future<void> saveTransactionsToCsv({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
    String? fileNameSuffix,
  }) async {
    AppLogger.d('Starting CSV save to device');
    state = ExportState.loading();

    final exportService = ref.read(exportServiceProvider);
    final transactionRepository = ref.read(transactionRepositoryProvider);

    try {
      // Get transactions with filters (returns List<Map<String, dynamic>>)
      final transactionsResult = await transactionRepository.getTransactionsWithCategoryNames(
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
        type: type,
      );

      if (transactionsResult.isFailure) {
        AppLogger.w('Failed to load transactions for export');
        state = ExportState.error(transactionsResult.error ?? 'Gagal memuat transaksi');
        return;
      }

      final transactions = transactionsResult.data ?? [];

      if (transactions.isEmpty) {
        AppLogger.i('No transactions to export');
        state = ExportState.error('Tidak ada transaksi untuk diekspor');
        return;
      }

      // Generate file name
      final fileName = fileNameSuffix ?? _generateFileNameSuffix();

      // Save to CSV
      final result = await exportService.saveTransactionsToCsv(
        transactions: transactions,
        fileName: fileName,
      );

      if (result.isSuccess) {
        AppLogger.i('CSV saved successfully: ${result.data}');
        state = ExportState.success(result.data!, ExportAction.saveToDevice);
      } else {
        AppLogger.w('CSV save failed: ${result.failure?.message}');
        state = ExportState.error(result.failure!.message);
      }
    } catch (e, stackTrace) {
      AppLogger.e('CSV save operation failed', e, stackTrace);
      state = ExportState.error(ErrorMessageMapper.getUserMessage(e));
    }
  }

  /// Share transactions via share_plus
  Future<void> shareTransactionsToCsv({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
    String? fileNameSuffix,
  }) async {
    AppLogger.d('Starting CSV share');
    state = ExportState.loading();

    final exportService = ref.read(exportServiceProvider);
    final transactionRepository = ref.read(transactionRepositoryProvider);

    try {
      // Get transactions with filters (returns List<Map<String, dynamic>>)
      final transactionsResult = await transactionRepository.getTransactionsWithCategoryNames(
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
        type: type,
      );

      if (transactionsResult.isFailure) {
        AppLogger.w('Failed to load transactions for share');
        state = ExportState.error(transactionsResult.error ?? 'Gagal memuat transaksi');
        return;
      }

      final transactions = transactionsResult.data ?? [];

      if (transactions.isEmpty) {
        AppLogger.i('No transactions to share');
        state = ExportState.error('Tidak ada transaksi untuk diekspor');
        return;
      }

      // Generate file name
      final fileName = fileNameSuffix ?? _generateFileNameSuffix();

      // Share CSV
      final result = await exportService.shareTransactionsToCsv(
        transactions: transactions,
        fileName: fileName,
      );

      if (result.isSuccess) {
        AppLogger.i('CSV shared successfully');
        state = ExportState.success(result.data!, ExportAction.share);
      } else {
        AppLogger.w('CSV share failed: ${result.failure?.message}');
        state = ExportState.error(result.failure!.message);
      }
    } catch (e, stackTrace) {
      AppLogger.e('CSV share operation failed', e, stackTrace);
      state = ExportState.error(ErrorMessageMapper.getUserMessage(e));
    }
  }

  /// Generate filename suffix from current date
  /// Format: DD_MM_YYYY (e.g., 15_03_2024)
  String _generateFileNameSuffix() {
    final now = DateTime.now();
    return '${now.day}_${now.month}_${now.year}';
  }

  /// Reset export state to idle
  void reset() {
    state = ExportState.idle();
  }
}
