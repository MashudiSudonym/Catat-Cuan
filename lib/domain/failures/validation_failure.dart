import 'failure.dart';

/// Failure for validation errors (e.g., invalid input, missing required fields)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
