import 'failure.dart';

/// Failure for database operation errors (e.g., SQLite errors, constraint violations)
class DatabaseFailure extends Failure {
  /// Optional underlying exception for debugging
  final Object? exception;

  const DatabaseFailure(super.message, {this.exception});
}
