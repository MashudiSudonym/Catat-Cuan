import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_form_state.freezed.dart';

/// State untuk transaction form
/// Following SRP: Only manages form data and validation state
@freezed
abstract class TransactionFormState with _$TransactionFormState {
  const TransactionFormState._();

  const factory TransactionFormState({
    /// Nominal transaksi
    double? nominal,

    /// Tipe transaksi
    TransactionType? type,

    /// Tanggal transaksi
    DateTime? date,

    /// Waktu transaksi
    DateTime? time,

    /// ID kategori
    int? categoryId,

    /// Catatan tambahan
    String? note,

    /// Validation errors map
    @Default({}) Map<String, String> validationErrors,

    /// Sedang mengirim data
    @Default(false) bool isSubmitting,

    /// Error message dari submit
    String? submitError,

    /// Mode edit
    @Default(false) bool isEditMode,

    /// Transaksi yang sedang diedit
    TransactionEntity? editingTransaction,
  }) = _TransactionFormState;

  /// Empty form state
  static const empty = TransactionFormState();

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
