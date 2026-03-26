import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/presentation/controllers/transaction_form_submission_controller.dart';
import 'package:catat_cuan/presentation/providers/transaction/transaction_list_provider.dart';
import 'package:catat_cuan/presentation/providers/transaction/transaction_list_paginated_provider.dart';
import 'package:catat_cuan/presentation/providers/summary/monthly_summary_provider.dart';
import 'package:catat_cuan/presentation/providers/usecases/transaction_usecase_providers.dart';
import 'package:catat_cuan/presentation/states/transaction_form_state.dart';
import 'package:catat_cuan/presentation/states/validators/transaction_form_validator.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_form_provider.g.dart';

/// Provider untuk transaction form state management
///
/// Following SRP: Only manages form state and delegates submission to controller
/// Following DIP: Depends on UseCase abstractions and Controller abstraction
/// Uses @riverpod annotation for modern Riverpod patterns without constructor side effects
@riverpod
class TransactionFormNotifier extends _$TransactionFormNotifier {
  final TransactionFormValidator _validator = const TransactionFormValidator();

  @override
  TransactionFormState build() {
    // No constructor side effects - initialize state in build()
    return _getInitialState();
  }

  TransactionFormState _getInitialState() {
    final now = DateTime.now();
    return TransactionFormState(
      type: TransactionType.expense, // Default: Pengeluaran (AC-LOG-001.2)
      date: DateTime(now.year, now.month, now.day),
      time: now,
    );
  }

  /// Get submission controller with strategies injected
  TransactionFormSubmissionController _getSubmissionController() {
    final addUseCase = ref.read(addTransactionUseCaseProvider);
    final updateUseCase = ref.read(updateTransactionUseCaseProvider);

    return TransactionFormSubmissionController(
      addStrategy: AddTransactionStrategy(addUseCase),
      updateStrategy: UpdateTransactionStrategy(updateUseCase),
    );
  }

  /// Set nominal dengan validasi
  void setNominal(double value) {
    final errors = Map<String, String>.from(state.validationErrors);
    final error = _validator.validateNominal(value);

    if (error != null) {
      errors['nominal'] = error;
    } else {
      errors.remove('nominal');
    }

    state = state.copyWith(
      nominal: value,
      validationErrors: errors,
    );
  }

  /// Set tipe transaksi
  void setType(TransactionType type) {
    state = state.copyWith(type: type);
  }

  /// Set tanggal dengan validasi
  void setDate(DateTime date) {
    final errors = Map<String, String>.from(state.validationErrors);
    final error = _validator.validateDate(date);

    if (error != null) {
      errors['date'] = error;
    } else {
      errors.remove('date');
    }

    state = state.copyWith(
      date: date,
      validationErrors: errors,
    );
  }

  /// Set waktu dengan validasi
  void setTime(DateTime time) {
    final errors = Map<String, String>.from(state.validationErrors);
    final error = _validator.validateTime(time);

    if (error != null) {
      errors['time'] = error;
    } else {
      errors.remove('time');
    }

    state = state.copyWith(
      time: time,
      validationErrors: errors,
    );
  }

  /// Set kategori dengan validasi
  void setCategory(int? categoryId) {
    final errors = Map<String, String>.from(state.validationErrors);
    final error = _validator.validateCategory(categoryId);

    if (error != null) {
      errors['categoryId'] = error;
    } else {
      errors.remove('categoryId');
    }

    state = state.copyWith(
      categoryId: categoryId,
      validationErrors: errors,
    );
  }

  /// Set catatan
  void setNote(String note) {
    state = state.copyWith(note: note.isEmpty ? null : note);
  }

  /// Load transaksi untuk edit (AC-LOG-006.1)
  void loadForEdit(TransactionEntity transaction) {
    state = TransactionFormState(
      nominal: transaction.amount,
      type: transaction.type,
      date: DateTime(transaction.dateTime.year, transaction.dateTime.month, transaction.dateTime.day),
      time: transaction.dateTime,
      categoryId: transaction.categoryId,
      note: transaction.note,
      isEditMode: true,
      editingTransaction: transaction,
    );
  }

  /// Load transaksi untuk edit berdasarkan ID
  Future<void> loadById(int transactionId) async {
    final getTransactionByIdUseCase = ref.read(getTransactionByIdUseCaseProvider);
    final result = await getTransactionByIdUseCase(transactionId);

    if (result.isFailure || result.data == null) {
      AppLogger.e('Failed to load transaction by ID: $transactionId - ${result.failure?.message}');
      throw Exception(result.failure?.message ?? 'Transaksi tidak ditemukan');
    }

    loadForEdit(result.data!);
  }

  /// Reset form ke default (AC-LOG-004.1)
  void resetForm() {
    ref.invalidateSelf();
  }

  /// Submit form using submission controller
  Future<bool> submit() async {
    state = state.copyWith(
      isSubmitting: true,
      submitError: null,
    );

    final controller = _getSubmissionController();
    final success = await controller.submit(
      state,
      (error) {
        state = state.copyWith(
          submitError: error,
          isSubmitting: false,
        );
      },
    );

    if (success) {
      // Invalidate dependent providers to trigger refresh
      ref.invalidate(transactionListProvider);
      ref.invalidate(transactionListPaginatedProvider);
      ref.invalidate(monthlySummaryProvider);

      // Reset form setelah sukses (AC-LOG-004.1)
      state = _getInitialState();
    }

    return success;
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(submitError: null);
  }
}
