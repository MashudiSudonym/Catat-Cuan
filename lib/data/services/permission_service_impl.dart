import 'package:permission_handler/permission_handler.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/services/permission_service.dart';

/// Implementation of permission service
///
/// This service handles app permissions for camera and storage access.
/// It follows the Dependency Inversion Principle by implementing
/// the domain-layer PermissionService interface.
class PermissionServiceImpl implements PermissionService {
  /// Requests camera permission from the user
  ///
  /// Returns success with true if permission is granted.
  /// Returns success with false if permission is denied (not permanently).
  /// Returns failure if permission is permanently denied.
  @override
  Future<Result<bool>> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();

      if (status.isGranted) {
        return Result.success(true);
      } else if (status.isPermanentlyDenied) {
        return Result.failure(
          const PermissionFailure(
            'Izin kamera diperlukan. Silakan aktifkan di Pengaturan.',
          ),
        );
      } else {
        return Result.success(false);
      }
    } catch (e) {
      return Result.failure(
        UnknownFailure('Gagal meminta izin: ${e.toString()}'),
      );
    }
  }

  /// Requests storage/photos permission from the user
  ///
  /// Uses the photos permission for Android 13+.
  /// Returns success with true if permission is granted.
  /// Returns success with false if permission is denied (not permanently).
  /// Returns failure if permission is permanently denied.
  @override
  Future<Result<bool>> requestStoragePermission() async {
    try {
      // For Android 13+ use photos permission
      final status = await Permission.photos.request();

      if (status.isGranted) {
        return Result.success(true);
      } else if (status.isPermanentlyDenied) {
        return Result.failure(
          const PermissionFailure(
            'Izin galeri diperlukan. Silakan aktifkan di Pengaturan.',
          ),
        );
      } else {
        return Result.success(false);
      }
    } catch (e) {
      return Result.failure(
        UnknownFailure('Gagal meminta izin: ${e.toString()}'),
      );
    }
  }

  /// Checks if camera permission is currently granted
  @override
  Future<bool> checkCameraPermission() async {
    return await Permission.camera.status.isGranted;
  }

  /// Checks if storage/photos permission is currently granted
  @override
  Future<bool> checkStoragePermission() async {
    return await Permission.photos.status.isGranted;
  }

  /// Opens the app settings page
  ///
  /// Useful when permissions are permanently denied and the user
  /// needs to manually enable them.
  @override
  Future<Result<bool>> openSettings() async {
    try {
      final opened = await openAppSettings();
      if (opened) {
        return Result.success(true);
      }
      return Result.failure(
        const UnknownFailure('Gagal membuka pengaturan'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('Gagal membuka pengaturan: ${e.toString()}'),
      );
    }
  }
}
