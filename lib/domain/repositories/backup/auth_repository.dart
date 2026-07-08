/// Authentication repository interface
///
/// Wraps AuthService for domain layer access following the
/// repository pattern used throughout the codebase.
library;

import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/backup/auth_user.dart';

/// Repository for authentication operations
///
/// Provides a domain-layer abstraction over the AuthService,
/// following the same repository pattern used for transactions
/// and categories.
abstract class AuthRepository {
  /// Triggers Google Sign-In flow
  Future<Result<AuthUser>> signIn();

  /// Signs out the current user
  Future<Result<void>> signOut();

  /// Gets the currently signed-in user
  Future<Result<AuthUser?>> getSignedInUser();

  /// Silently refreshes the signed-in session (signInSilently).
  ///
  /// Used on cold start to restore a previously-connected Google account
  /// without prompting the user again. Returns:
  /// - Result.success(AuthUser) if the silent refresh succeeds
  /// - Result.failure(AuthFailure.expired) if the session is no longer valid
  Future<Result<AuthUser>> refreshToken();
}
