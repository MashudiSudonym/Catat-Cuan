import 'package:permission_handler/permission_handler.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/services/permission_service.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

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
    AppLogger.d('Requesting camera permission');

    try {
      final status = await Permission.camera.request();
      AppLogger.d('Camera permission status: ${status.name}');

      if (status.isGranted) {
        AppLogger.i('Camera permission granted');
        return Result.success(true);
      } else if (status.isPermanentlyDenied) {
        AppLogger.w('Camera permission permanently denied');
        return Result.failure(
          const PermissionFailure(
            'Izin kamera diperlukan. Silakan aktifkan di Pengaturan.',
          ),
        );
      } else {
        AppLogger.i('Camera permission denied (not permanent)');
        return Result.success(false);
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed to request camera permission', e, stackTrace);
      return Result.failure(
        UnknownFailure('Gagal meminta izin kamera'),
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
    AppLogger.d('Requesting storage/photos permission');

    try {
      // For Android 13+ use photos permission
      final status = await Permission.photos.request();
      AppLogger.d('Storage permission status: ${status.name}');

      if (status.isGranted) {
        AppLogger.i('Storage permission granted');
        return Result.success(true);
      } else if (status.isPermanentlyDenied) {
        AppLogger.w('Storage permission permanently denied');
        return Result.failure(
          const PermissionFailure(
            'Izin galeri diperlukan. Silakan aktifkan di Pengaturan.',
          ),
        );
      } else {
        AppLogger.i('Storage permission denied (not permanent)');
        return Result.success(false);
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed to request storage permission', e, stackTrace);
      return Result.failure(
        UnknownFailure('Gagal meminta izin galeri'),
      );
    }
  }

  /// Checks if camera permission is currently granted
  @override
  Future<bool> checkCameraPermission() async {
    final isGranted = await Permission.camera.status.isGranted;
    AppLogger.d('Camera permission check: $isGranted');
    return isGranted;
  }

  /// Checks if storage/photos permission is currently granted
  @override
  Future<bool> checkStoragePermission() async {
    final isGranted = await Permission.photos.status.isGranted;
    AppLogger.d('Storage permission check: $isGranted');
    return isGranted;
  }

  /// Requests manage external storage permission from the user
  ///
  /// This permission is required for writing to public folders like Downloads
  /// on Android 11+ (API 30+). This is a special permission that requires
  /// user manual approval in system settings.
  ///
  /// Returns success with true if permission is granted.
  /// Returns success with false if permission is denied (not permanently).
  /// Returns failure if permission is permanently denied.
  @override
  Future<Result<bool>> requestManageExternalStoragePermission() async {
    AppLogger.d('Requesting manage external storage permission');

    try {
      final status = await Permission.manageExternalStorage.request();
      AppLogger.d('Manage external storage permission status: ${status.name}');

      if (status.isGranted) {
        AppLogger.i('Manage external storage permission granted');
        return Result.success(true);
      } else if (status.isPermanentlyDenied) {
        AppLogger.w('Manage external storage permission permanently denied');
        return Result.failure(
          const PermissionFailure(
            'Izin penyimpanan penuh diperlukan. Silakan aktifkan di Pengaturan.',
          ),
        );
      } else {
        AppLogger.i('Manage external storage permission denied (not permanent)');
        return Result.success(false);
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed to request manage external storage permission', e, stackTrace);
      return Result.failure(
        UnknownFailure('Gagal meminta izin penyimpanan penuh'),
      );
    }
  }

  /// Checks if manage external storage permission is currently granted
  @override
  Future<bool> checkManageExternalStoragePermission() async {
    final isGranted = await Permission.manageExternalStorage.status.isGranted;
    AppLogger.d('Manage external storage permission check: $isGranted');
    return isGranted;
  }

  /// Opens the app settings page
  ///
  /// Useful when permissions are permanently denied and the user
  /// needs to manually enable them.
  @override
  Future<Result<bool>> openSettings() async {
    AppLogger.d('Opening app settings');

    try {
      final opened = await openAppSettings();
      if (opened) {
        AppLogger.i('App settings opened successfully');
        return Result.success(true);
      }
      AppLogger.w('Failed to open app settings');
      return Result.failure(
        UnknownFailure('Gagal membuka pengaturan'),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error opening app settings', e, stackTrace);
      return Result.failure(
        UnknownFailure('Gagal membuka pengaturan'),
      );
    }
  }
}
