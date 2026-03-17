import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// State untuk transaction form
/// Following SRP: Only manages form data and validation state
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

  /// Empty form state
  const TransactionFormState.empty()
      : nominal = null,
        type = null,
        date = null,
        time = null,
        categoryId = null,
        note = null,
        validationErrors = const {},
        isSubmitting = false,
        submitError = null,
        isEditMode = false,
        editingTransaction = null;
}
