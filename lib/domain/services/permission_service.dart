/// Permission Service interface for domain layer
///
/// This abstraction follows the Dependency Inversion Principle (DIP)
/// by defining an interface for permission-related operations.
library;

import 'package:catat_cuan/domain/core/result.dart';

/// Service for managing app permissions
///
/// This interface abstracts permission handling, allowing different
/// permission packages or platform-specific implementations to be used.
abstract class PermissionService {
  /// Requests camera permission from the user
  ///
  /// Returns:
  /// - Result.success(true) if permission is granted
  /// - Result.success(false) if permission is denied (but not permanently)
  /// - Result.failure(PermissionFailure) with message to open settings if permanently denied
  Future<Result<bool>> requestCameraPermission();

  /// Requests storage/photos permission from the user
  ///
  /// Returns:
  /// - Result.success(true) if permission is granted
  /// - Result.success(false) if permission is denied (but not permanently)
  /// - Result.failure(PermissionFailure) with message to opens settings if permanently denied
  Future<Result<bool>> requestStoragePermission();

  /// Checks if camera permission is currently granted
  ///
  /// Returns true if permission is granted, false otherwise
  Future<bool> checkCameraPermission();

  /// Checks if storage/photos permission is currently granted
  ///
  /// Returns true if permission is granted, false otherwise
  Future<bool> checkStoragePermission();

  /// Requests manage external storage permission from the user
  ///
  /// This permission is required for writing to public folders like Downloads
  /// on Android 11+ (API 30+). This is a special permission that requires
  /// user manual approval in system settings.
  ///
  /// Returns:
  /// - Result.success(true) if permission is granted
  /// - Result.success(false) if permission is denied (but not permanently)
  /// - Result.failure(PermissionFailure) with message to open settings if permanently denied
  Future<Result<bool>> requestManageExternalStoragePermission();

  /// Checks if manage external storage permission is currently granted
  ///
  /// Returns true if permission is granted, false otherwise
  Future<bool> checkManageExternalStoragePermission();

  /// Opens the app settings page
  ///
  /// This is useful when permissions are permanently denied
  /// and the user needs to manually enable them.
  ///
  /// Returns:
  /// - Result.success(true) if settings page was opened
  /// - Result.failure(UnknownFailure) if opening settings failed
  Future<Result<bool>> openSettings();
}
