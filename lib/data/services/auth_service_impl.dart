/// Google Sign-In implementation of AuthService
///
/// Uses the google_sign_in package with drive.appdata scope
/// for OAuth 2.0 authentication and secure token storage.
library;

import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/backup/auth_user.dart';
import 'package:catat_cuan/domain/failures/auth_failure.dart';
import 'package:catat_cuan/domain/services/auth_service.dart';
import 'package:catat_cuan/data/services/backup_token_storage.dart';

/// Implementation of AuthService using Google Sign-In
///
/// Follows the Dependency Inversion Principle: the domain layer
/// depends on AuthService (abstraction), not this concrete class.
class AuthServiceImpl implements AuthService {
  final GoogleSignIn _googleSignIn;
  final BackupTokenStorage _tokenStorage;

  static const _driveAppDataScope =
      'https://www.googleapis.com/auth/drive.appdata';

  AuthServiceImpl(this._googleSignIn, this._tokenStorage);

  @override
  Future<Result<AuthUser>> signIn() async {
    try {
      // Trigger interactive sign-in
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Result.failure(
          AuthCancelledFailure('Pengguna membatalkan masuk'),
        );
      }

      // Request drive.appdata scope if not already granted
      final hasScope = await _googleSignIn.canAccessScopes(
        [_driveAppDataScope],
      );
      if (!hasScope) {
        final granted = await _googleSignIn.requestScopes(
          [_driveAppDataScope],
        );
        if (!granted) {
          return Result.failure(
            AuthCancelledFailure('Izin Drive ditolak oleh pengguna'),
          );
        }
      }

      return _buildAuthUser(googleUser);
    } on PlatformException catch (e) {
      return Result.failure(_mapPlatformException(e));
    } catch (e) {
      return Result.failure(
        AuthUnknownFailure('Gagal masuk: $e'),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _tokenStorage.clearAuthHeaders();
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        AuthUnknownFailure('Gagal keluar: $e'),
      );
    }
  }

  @override
  Future<Result<AuthUser?>> getSignedInUser() async {
    try {
      final googleUser = _googleSignIn.currentUser;
      if (googleUser == null) {
        return Result.success(null);
      }
      return _buildAuthUser(googleUser);
    } catch (e) {
      return Result.failure(
        AuthUnknownFailure('Gagal mendapatkan pengguna: $e'),
      );
    }
  }

  @override
  Future<Result<AuthUser>> refreshToken() async {
    try {
      // Try silent sign-in first (refreshes tokens if possible)
      final googleUser = await _googleSignIn.signInSilently();
      if (googleUser == null) {
        return Result.failure(
          AuthExpiredFailure(
            'Sesi telah berakhir. Silakan masuk kembali.',
          ),
        );
      }
      return _buildAuthUser(googleUser);
    } on PlatformException catch (e) {
      return Result.failure(_mapPlatformException(e));
    } catch (e) {
      return Result.failure(
        AuthExpiredFailure(
          'Sesi telah berakhir. Silakan masuk kembali.',
        ),
      );
    }
  }

  /// Builds an AuthUser from a GoogleSignInAccount
  Future<Result<AuthUser>> _buildAuthUser(
    GoogleSignInAccount googleUser,
  ) async {
    try {
      // Get auth headers (includes access token)
      final authHeaders = await googleUser.authHeaders;

      // Store headers securely
      await _tokenStorage.saveAuthHeaders(authHeaders);
      _tokenStorage.updateCachedHeaders(authHeaders);

      return Result.success(
        AuthUser(
          email: googleUser.email,
          displayName: googleUser.displayName,
          photoUrl: googleUser.photoUrl,
          authHeaders: authHeaders,
        ),
      );
    } catch (e) {
      return Result.failure(
        AuthUnknownFailure('Gagal mendapatkan otorisasi: $e'),
      );
    }
  }

  /// Maps PlatformException to appropriate AuthFailure
  AuthFailure _mapPlatformException(PlatformException e) {
    switch (e.code) {
      case GoogleSignIn.kSignInCanceledError:
        return AuthCancelledFailure('Pengguna membatalkan masuk');
      case GoogleSignIn.kNetworkError:
        return AuthNetworkFailure('Koneksi gagal. Periksa internet Anda.');
      case GoogleSignIn.kSignInRequiredError:
        return AuthExpiredFailure(
          'Sesi telah berakhir. Silakan masuk kembali.',
        );
      case GoogleSignIn.kSignInFailedError:
        return AuthUnknownFailure('Gagal masuk: ${e.message}');
      default:
        return AuthUnknownFailure('Gagal masuk: ${e.message}');
    }
  }
}
