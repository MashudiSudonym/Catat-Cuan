import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/usecases/add_transaction.dart';
import 'package:catat_cuan/domain/usecases/update_transaction.dart';
import 'package:catat_cuan/presentation/states/transaction_form_state.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';

/// Strategy interface for transaction submission operations
///
/// Following OCP: New submission types can be added without modifying existing code
abstract class TransactionSubmissionStrategy {
  /// Execute the submission operation
  Future<TransactionEntity?> execute(TransactionEntity transaction);
}

/// Strategy for adding new transactions
class AddTransactionStrategy implements TransactionSubmissionStrategy {
  final AddTransactionUseCase _addUseCase;

  AddTransactionStrategy(this._addUseCase);

  @override
  Future<TransactionEntity?> execute(TransactionEntity transaction) async {
    final result = await _addUseCase(transaction);
    if (result.isFailure) {
      throw Exception(result.failure?.message ?? 'Gagal menambah transaksi');
    }
    AppLogger.i('Transaction added successfully');
    return result.data;
  }
}

/// Strategy for updating existing transactions
class UpdateTransactionStrategy implements TransactionSubmissionStrategy {
  final UpdateTransactionUseCase _updateUseCase;

  UpdateTransactionStrategy(this._updateUseCase);

  @override
  Future<TransactionEntity?> execute(TransactionEntity transaction) async {
    final result = await _updateUseCase(transaction);
    if (result.isFailure) {
      throw Exception(result.failure?.message ?? 'Gagal mengupdate transaksi');
    }
    AppLogger.i('Transaction updated successfully');
    return result.data;
  }
}

/// Controller for transaction form submission logic
///
/// Following SRP: Only handles form submission operations
/// Following OCP: Uses strategy pattern for add/update operations
/// Following DIP: Depends on use case abstractions via strategies
class TransactionFormSubmissionController {
  final Map<bool, TransactionSubmissionStrategy> _strategies;

  TransactionFormSubmissionController({
    required TransactionSubmissionStrategy addStrategy,
    required TransactionSubmissionStrategy updateStrategy,
  }) : _strategies = {
        false: addStrategy, // Add mode
        true: updateStrategy, // Edit mode
      };

  /// Submit form using appropriate strategy
  ///
  /// Returns true if successful, false otherwise
  /// Throws Exception with user-friendly message on failure
  Future<bool> submit(
    TransactionFormState state,
    void Function(String) onError,
  ) async {
    AppLogger.d('Submitting transaction form: ${state.isEditMode ? "edit" : "add"} mode');

    // Validate form
    if (!state.isValid) {
      AppLogger.w('Form validation failed');
      onError('Mohon lengkapi semua field yang wajib diisi');
      return false;
    }

    try {
      // Combine date and time
      final dateTime = DateTime(
        state.date!.year,
        state.date!.month,
        state.date!.day,
        state.time!.hour,
        state.time!.minute,
      );

      // Create transaction entity
      final transaction = TransactionEntity(
        id: state.editingTransaction?.id,
        amount: state.nominal!,
        type: state.type!,
        dateTime: dateTime,
        categoryId: state.categoryId!,
        note: state.note,
        createdAt: state.editingTransaction?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      AppLogger.i('Executing transaction use case: ${state.type!.value} - ${state.nominal}');

      // Execute using appropriate strategy
      final strategy = _strategies[state.isEditMode]!;
      await strategy.execute(transaction);

      return true;
    } catch (e, stackTrace) {
      AppLogger.e('Transaction form submit failed', e, stackTrace);
      final userMessage = ErrorMessageMapper.getUserMessage(e);
      onError(userMessage);
      return false;
    }
  }
}
