/// Authentication service interface for domain layer
///
/// Defines the contract for Google Sign-In authentication with
/// drive.appdata scope. Follows the Dependency Inversion Principle
/// (DIP) by providing an abstraction that the domain layer depends on.
library;

import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/backup/auth_user.dart';

/// Service for handling Google authentication
///
/// Manages the OAuth 2.0 flow with the drive.appdata scope,
/// token refresh, and user session state.
abstract class AuthService {
  /// Triggers Google Sign-In with drive.appdata scope
  ///
  /// Returns:
  /// - Result.success(AuthUser) with user info and auth headers
  /// - Result.failure(AuthFailure) if sign-in fails or is cancelled
  Future<Result<AuthUser>> signIn();

  /// Signs out the current user and clears stored tokens
  ///
  /// Returns:
  /// - Result.success(null) on successful sign-out
  /// - Result.failure(AuthFailure) if sign-out fails
  Future<Result<void>> signOut();

  /// Gets the currently signed-in user, if any
  ///
  /// Returns:
  /// - Result.success(AuthUser) if user is signed in
  /// - Result.success(null) if no user is signed in
  /// - Result.failure(AuthFailure) if checking state fails
  Future<Result<AuthUser?>> getSignedInUser();

  /// Refreshes the authentication token
  ///
  /// Attempts silent refresh first. If that fails (e.g., access revoked),
  /// returns an expired failure prompting re-authentication.
  ///
  /// Returns:
  /// - Result.success(AuthUser) with refreshed auth headers
  /// - Result.failure(AuthFailure.expired) if refresh fails
  Future<Result<AuthUser>> refreshToken();
}
