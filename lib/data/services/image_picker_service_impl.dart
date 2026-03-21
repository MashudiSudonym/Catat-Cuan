import 'package:image_picker/image_picker.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/services/image_picker_service.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementation of image picker service
///
/// This service handles image selection from camera and gallery.
/// It follows the Dependency Inversion Principle by implementing
/// the domain-layer ImagePickerService interface.
class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Opens the camera and captures a new image
  ///
  /// Returns the file path of the captured image.
  /// Returns a failure if the user cancels or permission is denied.
  @override
  Future<Result<String>> pickImageFromCamera() async {
    AppLogger.d('Opening camera for image capture');

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo == null) {
        AppLogger.i('User cancelled camera capture');
        return Result.failure(
          PermissionFailure('Tidak ada gambar yang dipilih'),
        );
      }

      AppLogger.i('Image captured successfully: ${photo.path}');
      return Result.success(photo.path);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to capture image from camera', e, stackTrace);
      return Result.failure(
        UnknownFailure('Gagal mengambil gambar'),
      );
    }
  }

  /// Opens the gallery and allows image selection
  ///
  /// Returns the file path of the selected image.
  /// Returns a failure if the user cancels or permission is denied.
  @override
  Future<Result<String>> pickImageFromGallery() async {
    AppLogger.d('Opening gallery for image selection');

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
      );

      if (image == null) {
        AppLogger.i('User cancelled gallery selection');
        return Result.failure(
          PermissionFailure('Tidak ada gambar yang dipilih'),
        );
      }

      AppLogger.i('Image selected successfully: ${image.path}');
      return Result.success(image.path);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to pick image from gallery', e, stackTrace);
      return Result.failure(
        UnknownFailure('Gagal memilih gambar'),
      );
    }
  }
}
