import 'failure.dart';

/// Failure for resource not found errors (e.g., transaction with given ID not found)
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
