import 'failure.dart';

/// Failure for permission-related errors (e.g., camera, storage access denied)
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}
