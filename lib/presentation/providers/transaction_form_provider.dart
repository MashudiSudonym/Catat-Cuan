import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/usecases/add_transaction.dart';
import 'package:catat_cuan/domain/usecases/update_transaction.dart';

// Export state class for use in UI
export 'transaction_form_provider.dart' show TransactionFormState;

/// State untuk transaction form
class TransactionFormState {
  final double? nominal;
  final TransactionType? type;
  final DateTime? date;
  final DateTime? time;
  final int? categoryId;
  final String? note;
  final Map<String, String> validationErrors;
  final bool isSubmitting;
  final String? submitError;
  final bool isEditMode;
  final TransactionEntity? editingTransaction;

  const TransactionFormState({
    this.nominal,
    this.type,
    this.date,
    this.time,
    this.categoryId,
    this.note,
    this.validationErrors = const {},
    this.isSubmitting = false,
    this.submitError,
    this.isEditMode = false,
    this.editingTransaction,
  });

  TransactionFormState copyWith({
    double? nominal,
    TransactionType? type,
    DateTime? date,
    DateTime? time,
    int? categoryId,
    String? note,
    Map<String, String>? validationErrors,
    bool? isSubmitting,
    String? submitError,
    bool? isEditMode,
    TransactionEntity? editingTransaction,
  }) {
    return TransactionFormState(
      nominal: nominal ?? this.nominal,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      validationErrors: validationErrors ?? this.validationErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError ?? this.submitError,
      isEditMode: isEditMode ?? this.isEditMode,
      editingTransaction: editingTransaction ?? this.editingTransaction,
    );
  }

  /// Check apakah form valid
  bool get isValid {
    return nominal != null &&
        nominal! > 0 &&
        type != null &&
        date != null &&
        time != null &&
        categoryId != null &&
        categoryId! > 0 &&
        validationErrors.isEmpty;
  }
}

/// Notifier untuk transaction form
class TransactionFormNotifier extends StateNotifier<TransactionFormState> {
  final AddTransactionUseCase _addTransactionUseCase;
  final UpdateTransactionUseCase _updateTransactionUseCase;

  TransactionFormNotifier(
    this._addTransactionUseCase,
    this._updateTransactionUseCase,
  ) : super(const TransactionFormState()) {
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

  /// Set nominal
  void setNominal(double value) {
    final errors = Map<String, String>.from(state.validationErrors);

    // Validasi nominal (AC-LOG-002.1)
    if (value <= 0) {
      errors['nominal'] = 'Nominal harus lebih dari 0';
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

  /// Set tanggal
  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  /// Set waktu
  void setTime(DateTime time) {
    state = state.copyWith(time: time);
  }

  /// Set kategori
  void setCategory(int? categoryId) {
    final errors = Map<String, String>.from(state.validationErrors);

    // Validasi kategori (AC-LOG-002.1)
    if (categoryId == null || categoryId <= 0) {
      errors['categoryId'] = 'Kategori wajib dipilih';
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
    state = state.copyWith(
      nominal: null,
      categoryId: null,
      note: null,
      validationErrors: {},
      submitError: null,
      isEditMode: false,
      editingTransaction: null,
    );
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

/// Provider untuk TransactionFormNotifier
/// Note: Will be properly initialized with dependency injection in main.dart
final transactionFormProvider =
    StateNotifierProvider<TransactionFormNotifier, TransactionFormState>((ref) {
  // TODO: Initialize with proper use case dependency
  throw UnimplementedError('TransactionFormProvider not initialized - add DI setup');
});
