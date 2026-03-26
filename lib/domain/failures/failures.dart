/// Domain failures following Clean Architecture
///
/// Base failure class for all error types in the domain layer.
/// Failures represent error states that can occur during business operations.
///
/// This approach follows SOLID principles:
/// - Open/Closed: New failure types can be added without modifying existing code
/// - Single Responsibility: Each failure type represents one specific error category
library;

/// Base failure class for all error types
abstract class Failure {
  /// Human-readable error message
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

/// Failure for validation errors (e.g., invalid input, missing required fields)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Failure for database operation errors (e.g., SQLite errors, constraint violations)
class DatabaseFailure extends Failure {
  /// Optional underlying exception for debugging
  final Object? exception;

  const DatabaseFailure(super.message, {this.exception});
}

/// Failure for network-related errors (e.g., no internet, timeout)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure for permission-related errors (e.g., camera, storage access denied)
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Failure for OCR operation errors (e.g., text extraction failed)
class OcrFailure extends Failure {
  const OcrFailure(super.message);
}

/// Failure for general/unknown errors
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

/// Failure for resource not found errors (e.g., transaction with given ID not found)
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Failure for export operation errors (e.g., CSV generation, file sharing)
class ExportFailure extends Failure {
  const ExportFailure(super.message);
}
