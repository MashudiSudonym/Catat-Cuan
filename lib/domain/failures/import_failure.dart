import 'failure.dart';

/// Failure for import operation errors (e.g., CSV parsing, data validation)
class ImportFailure extends Failure {
  const ImportFailure(super.message);
}
