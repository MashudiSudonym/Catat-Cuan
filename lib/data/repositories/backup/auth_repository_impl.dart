/// Authentication repository implementation
///
/// Wraps AuthService for domain layer access following the
/// repository pattern used throughout the codebase.
library;

import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/backup/auth_user.dart';
import 'package:catat_cuan/domain/repositories/backup/auth_repository.dart';
import 'package:catat_cuan/domain/services/auth_service.dart';

/// Concrete implementation of AuthRepository
///
/// Delegates to AuthService (following the existing repository
/// pattern where repositories delegate to data sources/services).
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<Result<AuthUser>> signIn() => _authService.signIn();

  @override
  Future<Result<void>> signOut() => _authService.signOut();

  @override
  Future<Result<AuthUser?>> getSignedInUser() =>
      _authService.getSignedInUser();
}
