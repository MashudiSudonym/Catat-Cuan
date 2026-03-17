import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/usecases/add_transaction.dart';
import 'package:catat_cuan/domain/usecases/update_transaction.dart';
import 'package:catat_cuan/presentation/states/transaction_form_state.dart';
import 'package:catat_cuan/presentation/states/validators/transaction_form_validator.dart';

/// Notifier untuk transaction form
/// Following SRP: Only manages form state and submission
/// Following DIP: Depends on UseCase abstractions and Validator abstraction
class TransactionFormNotifier extends StateNotifier<TransactionFormState> {
  final AddTransactionUseCase _addTransactionUseCase;
  final UpdateTransactionUseCase _updateTransactionUseCase;
  final TransactionFormValidator _validator;

  TransactionFormNotifier(
    this._addTransactionUseCase,
    this._updateTransactionUseCase, [
    TransactionFormValidator? validator,
  ])  : _validator = validator ?? const TransactionFormValidator(),
        super(const TransactionFormState.empty()) {
    _initializeDefaults();
  }

  /// Initialize default values (AC-LOG-001.2)
  void _initializeDefaults() {
    final now = DateTime.now();
    state = state.copyWith(
      type: TransactionType.expense, // Default: Pengeluaran
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

  /// Reset form ke default (AC-LOG-004.1)
  void resetForm() {
    _initializeDefaults();
    state = const TransactionFormState.empty();
  }

  /// Submit form
  Future<bool> submit() async {
    // Validasi form (AC-LOG-002.3)
    if (!state.isValid) {
      state = state.copyWith(
        submitError: 'Mohon lengkapi semua field yang wajib diisi',
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      submitError: null,
    );

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

      // Execute use case
      if (state.isEditMode) {
        await _updateTransactionUseCase.execute(transaction);
      } else {
        await _addTransactionUseCase.execute(transaction);
      }

      // Reset form setelah sukses (AC-LOG-004.1)
      resetForm();
      return true;
    } catch (e) {
      state = state.copyWith(
        submitError: e.toString(),
        isSubmitting: false,
      );
      return false;
    } finally {
      if (state.submitError == null) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }
}
