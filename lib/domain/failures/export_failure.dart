import 'failure.dart';

/// Failure for export operation errors (e.g., CSV generation, file sharing)
class ExportFailure extends Failure {
  const ExportFailure(super.message);
}
