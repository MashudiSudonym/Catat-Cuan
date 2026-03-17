import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/usecases/export_transactions_usecase.dart';
import 'package:catat_cuan/presentation/providers/repositories/repository_providers.dart';
import 'package:catat_cuan/data/services/csv_export_service_impl.dart';

part 'export_provider.g.dart';

/// Export state following SRP
class ExportState {
  final bool isLoading;
  final String? filePath;
  final String? errorMessage;

  const ExportState({
    this.isLoading = false,
    this.filePath,
    this.errorMessage,
  });

  factory ExportState.idle() => const ExportState();
  factory ExportState.loading() => const ExportState(isLoading: true);
  factory ExportState.success(String filePath) => ExportState(filePath: filePath);
  factory ExportState.error(String message) => ExportState(errorMessage: message);

  bool get isIdle => !isLoading && filePath == null && errorMessage == null;
  bool get isSuccess => filePath != null;
  bool get isError => errorMessage != null;
}

/// Provider untuk export service
@riverpod
CsvExportServiceImpl exportService(ExportServiceRef ref) {
  return CsvExportServiceImpl();
}

/// Provider untuk ExportTransactionsUseCase
@riverpod
ExportTransactionsUseCase exportTransactionsUseCase(
  ExportTransactionsUseCaseRef ref,
) {
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
      state = ExportState.success(result.data!);
    } else {
      state = ExportState.error(result.failure!.message);
    }
  }

  /// Reset export state to idle
  void reset() {
    state = ExportState.idle();
  }
}
