/// Transaction validation logic
///
/// This validator follows the Single Responsibility Principle (SRP)
/// by only handling transaction validation operations.
///
/// Centralized validation logic eliminates code duplication across
/// add_transaction and update_transaction use cases.
library;

import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Result of a validation operation
class ValidationResult {
  /// Error message if validation failed, null if successful
  final String? error;

  /// Whether the validation passed
  final bool isValid;

  const ValidationResult({
    this.error,
    required this.isValid,
  });

  /// Creates a successful validation result
  const ValidationResult.success() : error = null, isValid = true;

  /// Creates a failed validation result with an error message
  const ValidationResult.error(this.error) : isValid = false;

  @override
  String toString() => isValid ? 'ValidationResult.success()' : 'ValidationResult.error($error)';
}

/// Validator for transaction entities
///
/// This class provides centralized validation for transaction entities,
/// ensuring consistent validation rules across the application.
class TransactionValidator {
  TransactionValidator._(); // Private constructor for static class

  /// Validates a transaction entity
  ///
  /// Checks:
  /// - Amount must be greater than 0
  /// - Category ID must be greater than 0
  /// - For updates: ID must be present
  ///
  /// Parameters:
  /// - [transaction]: The transaction to validate
  /// - [requireId]: Whether the transaction must have an ID (for updates)
  ///
  /// Returns [ValidationResult.success()] if valid, [ValidationResult.error()] otherwise
  static ValidationResult validate(
    TransactionEntity transaction, {
    bool requireId = false,
  }) {
    // For updates, ID is required
    if (requireId && transaction.id == null) {
      return const ValidationResult.error('ID transaksi wajib ada untuk update');
    }

    // Validate amount (AC-LOG-002.1)
    if (transaction.amount <= 0) {
      return const ValidationResult.error('Nominal harus lebih dari 0');
    }

    // Validate category (AC-LOG-002.1)
    if (transaction.categoryId <= 0) {
      return const ValidationResult.error('Kategori wajib dipilih');
    }

    // All validations passed
    return const ValidationResult.success();
  }

  /// Validates a transaction for creation (no ID required)
  static ValidationResult validateForCreation(TransactionEntity transaction) {
    return validate(transaction, requireId: false);
  }

  /// Validates a transaction for update (ID required)
  static ValidationResult validateForUpdate(TransactionEntity transaction) {
    return validate(transaction, requireId: true);
  }

  /// Validates transaction amount
  ///
  /// Returns error message if invalid, null if valid
  static String? validateAmount(double amount) {
    if (amount <= 0) {
      return 'Nominal harus lebih dari 0';
    }
    return null;
  }

  /// Validates transaction category ID
  ///
  /// Returns error message if invalid, null if valid
  static String? validateCategoryId(int categoryId) {
    if (categoryId <= 0) {
      return 'Kategori wajib dipilih';
    }
    return null;
  }

  /// Validates transaction note (optional)
  ///
  /// Returns error message if invalid, null if valid
  static String? validateNote(String? note) {
    // Note is optional, but if provided, limit its length
    if (note != null && note.length > 500) {
      return 'Catatan tidak boleh lebih dari 500 karakter';
    }
    return null;
  }
}
