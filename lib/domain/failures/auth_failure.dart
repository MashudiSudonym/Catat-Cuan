/// Authentication failure types
///
/// Represents various authentication errors that can occur during
/// Google Sign-In, token refresh, and auth state management.
library;

import 'package:catat_cuan/domain/failures/failure.dart';

/// Base class for authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure._(super.message);

  /// Token has expired and needs refresh
  factory AuthFailure.expired(String message) = AuthExpiredFailure;

  /// User has revoked access — needs re-authentication
  factory AuthFailure.revoked(String message) = AuthRevokedFailure;

  /// Network error during authentication
  factory AuthFailure.network(String message) = AuthNetworkFailure;

  /// User cancelled the sign-in flow
  factory AuthFailure.cancelled(String message) = AuthCancelledFailure;

  /// Unknown authentication error
  factory AuthFailure.unknown(String message) = AuthUnknownFailure;
}

/// Token expired failure
class AuthExpiredFailure extends AuthFailure {
  const AuthExpiredFailure(super.message) : super._();
}

/// Access revoked failure
class AuthRevokedFailure extends AuthFailure {
  const AuthRevokedFailure(super.message) : super._();
}

/// Network error during auth
class AuthNetworkFailure extends AuthFailure {
  const AuthNetworkFailure(super.message) : super._();
}

/// User cancelled sign-in
class AuthCancelledFailure extends AuthFailure {
  const AuthCancelledFailure(super.message) : super._();
}

/// Unknown auth error
class AuthUnknownFailure extends AuthFailure {
  const AuthUnknownFailure(super.message) : super._();
}
