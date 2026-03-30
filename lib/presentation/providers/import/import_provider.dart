import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:catat_cuan/domain/entities/import_result_entity.dart';
import 'package:catat_cuan/domain/usecases/import_transactions_usecase.dart';
import 'package:catat_cuan/presentation/providers/repositories/repository_providers.dart';
import 'package:catat_cuan/data/services/csv_import_service_impl.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';

part 'import_provider.g.dart';

/// Import state following SRP
class ImportState {
  final bool isLoading;
  final ImportResult? result;
  final String? errorMessage;

  const ImportState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  factory ImportState.idle() => const ImportState();
  factory ImportState.loading() => const ImportState(isLoading: true);
  factory ImportState.success(ImportResult result) => ImportState(result: result);
  factory ImportState.error(String message) => ImportState(errorMessage: message);

  bool get isIdle => !isLoading && result == null && errorMessage == null;
  bool get isSuccess => result != null;
  bool get isError => errorMessage != null;
}

/// Provider untuk import service
@riverpod
CsvImportServiceImpl importService(Ref ref) {
  return CsvImportServiceImpl();
}

/// Provider untuk ImportTransactionsUseCase
@riverpod
ImportTransactionsUseCase importTransactionsUseCase(Ref ref) {
  final importService = ref.watch(importServiceProvider);
  final categoryReadRepo = ref.watch(categoryReadRepositoryProvider);
  final categoryWriteRepo = ref.watch(categoryWriteRepositoryProvider);
  final categoryManagementRepo = ref.watch(categoryManagementRepositoryProvider);
  final transactionWriteRepo = ref.watch(transactionWriteRepositoryProvider);
  final transactionQueryRepo = ref.watch(transactionQueryRepositoryProvider);
  return ImportTransactionsUseCase(
    importService,
    categoryReadRepo,
    categoryWriteRepo,
    categoryManagementRepo,
    transactionWriteRepo,
    transactionQueryRepo,
  );
}

/// Provider untuk import state management
/// Following SRP: Only manages import state and operations
/// Following DIP: Depends on UseCase abstraction, not concrete implementation
@Riverpod(keepAlive: true)
class ImportNotifier extends _$ImportNotifier {
  @override
  ImportState build() {
    return ImportState.idle();
  }

  /// Import transactions from a CSV file
  Future<void> importTransactions(String filePath) async {
    AppLogger.d('Starting import from: $filePath');
    state = ImportState.loading();

    final importUseCase = ref.read(importTransactionsUseCaseProvider);

    try {
      final result = await importUseCase(ImportTransactionsParams(filePath: filePath));

      if (!ref.mounted) return;

      if (result.isSuccess) {
        AppLogger.i('Import successful: ${result.data!.imported} rows imported');
        state = ImportState.success(result.data!);
      } else {
        AppLogger.w('Import failed: ${result.failure?.message}');
        state = ImportState.error(result.failure!.message);
      }
    } catch (e, stackTrace) {
      AppLogger.e('Import operation failed', e, stackTrace);
      if (!ref.mounted) return;
      state = ImportState.error(ErrorMessageMapper.getUserMessage(e));
    }
  }

  /// Reset import state to idle
  void reset() {
    state = ImportState.idle();
  }
}
