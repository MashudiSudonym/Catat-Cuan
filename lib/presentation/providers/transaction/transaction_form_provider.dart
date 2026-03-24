import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/presentation/states/transaction_form_state.dart';
import 'package:catat_cuan/presentation/states/validators/transaction_form_validator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';

import 'package:catat_cuan/presentation/providers/usecases/transaction_usecase_providers.dart';
import 'package:catat_cuan/presentation/providers/transaction/transaction_list_provider.dart';
import 'package:catat_cuan/presentation/providers/transaction/transaction_list_paginated_provider.dart';
import 'package:catat_cuan/presentation/providers/summary/monthly_summary_provider.dart';

part 'transaction_form_provider.g.dart';

/// Provider untuk transaction form
/// Following SRP: Only manages form state and submission
/// Following DIP: Depends on UseCase abstractions and Validator abstraction
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
    final getTransactionsUseCase = ref.read(getTransactionsUseCaseProvider);
    try {
      final transaction = await getTransactionsUseCase.executeById(transactionId);
      if (transaction != null) {
        loadForEdit(transaction);
      } else {
        throw Exception('Transaksi tidak ditemukan');
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed to load transaction by ID: $transactionId', e, stackTrace);
      rethrow;
    }
  }

  /// Reset form ke default (AC-LOG-004.1)
  void resetForm() {
    ref.invalidateSelf();
  }

  /// Submit form
  Future<bool> submit() async {
    AppLogger.d('Submitting transaction form: ${state.isEditMode ? "edit" : "add"} mode');

    // Validasi form (AC-LOG-002.3)
    if (!state.isValid) {
      AppLogger.w('Form validation failed');
      state = state.copyWith(
        submitError: 'Mohon lengkapi semua field yang wajib diisi',
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      submitError: null,
    );

    final addTransactionUseCase = ref.read(addTransactionUseCaseProvider);
    final updateTransactionUseCase = ref.read(updateTransactionUseCaseProvider);

    try {
      // Combine date dan time
      final dateTime = DateTime(
        state.date!.year,
        state.date!.month,
        state.date!.day,
        state.time!.hour,
        state.time!.minute,
      );

      // Buat entity transaksi
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

      AppLogger.i('Executing transaction use case: '
          '${state.type!.value} - ${state.nominal}');

      // Execute use case
      if (state.isEditMode) {
        await updateTransactionUseCase.execute(transaction);
        AppLogger.i('Transaction updated successfully');
      } else {
        await addTransactionUseCase.execute(transaction);
        AppLogger.i('Transaction added successfully');
      }

      // Invalidate transaction list providers to trigger refresh
      ref.invalidate(transactionListNotifierProvider);
      ref.invalidate(transactionListPaginatedNotifierProvider);

      // Invalidate monthly summary to trigger refresh
      ref.invalidate(monthlySummaryNotifierProvider);

      // Reset form setelah sukses (AC-LOG-004.1)
      state = _getInitialState();
      return true;
    } catch (e, stackTrace) {
      final userMessage = ErrorMessageMapper.getUserMessage(e);
      AppLogger.e('Transaction form submit failed', e, stackTrace);
      state = state.copyWith(
        submitError: userMessage,
        isSubmitting: false,
      );
      return false;
    } finally {
      if (state.submitError == null) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(submitError: null);
  }
}
