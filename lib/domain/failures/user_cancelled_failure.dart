/// User cancelled failure
///
/// Represents a scenario where the user voluntarily cancelled an operation,
/// such as dismissing a dialog or picker. This is not an error condition,
/// but rather an expected user action that should be handled gracefully.
library;

import 'package:catat_cuan/domain/failures/failure.dart';

/// Failure representing user cancellation of an operation
///
/// This should be used when:
/// - User cancels a file picker dialog
/// - User dismisses a permission request
/// - User cancels any user-initiated operation
class UserCancelledFailure extends Failure {
  const UserCancelledFailure(super.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserCancelledFailure && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}
