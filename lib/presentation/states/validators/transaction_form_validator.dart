import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Validator untuk transaction form
/// Following SRP: Only handles validation logic
/// Following OCP: Can be extended with new validation rules without modifying existing code
class TransactionFormValidator {
  const TransactionFormValidator();

  /// Validate nominal
  String? validateNominal(double? value) {
    if (value == null) {
      return 'Nominal wajib diisi';
    }
    if (value <= 0) {
      return 'Nominal harus lebih dari 0';
    }
    return null;
  }

  /// Validate category
  String? validateCategory(int? categoryId) {
    if (categoryId == null || categoryId <= 0) {
      return 'Kategori wajib dipilih';
    }
    return null;
  }

  /// Validate date
  String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Tanggal wajib dipilih';
    }
    return null;
  }

  /// Validate time
  String? validateTime(DateTime? time) {
    if (time == null) {
      return 'Waktu wajib dipilih';
    }
    return null;
  }

  /// Validate type
  String? validateType(TransactionType? type) {
    if (type == null) {
      return 'Tipe transaksi wajib dipilih';
    }
    return null;
  }

  /// Validate entire form and return all errors
  Map<String, String> validate({
    double? nominal,
    int? categoryId,
    DateTime? date,
    DateTime? time,
    TransactionType? type,
  }) {
    final errors = <String, String>{};

    final nominalError = validateNominal(nominal);
    if (nominalError != null) {
      errors['nominal'] = nominalError;
    }

    final categoryError = validateCategory(categoryId);
    if (categoryError != null) {
      errors['categoryId'] = categoryError;
    }

    final dateError = validateDate(date);
    if (dateError != null) {
      errors['date'] = dateError;
    }

    final timeError = validateTime(time);
    if (timeError != null) {
      errors['time'] = timeError;
    }

    final typeError = validateType(type);
    if (typeError != null) {
      errors['type'] = typeError;
    }

    return errors;
  }

  /// Check if form is valid
  bool isValid({
    required double? nominal,
    required int? categoryId,
    required DateTime? date,
    required DateTime? time,
    required TransactionType? type,
  }) {
    return validate(
      nominal: nominal,
      categoryId: categoryId,
      date: date,
      time: time,
      type: type,
    ).isEmpty;
  }
}
