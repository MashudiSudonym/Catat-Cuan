import 'package:image_picker/image_picker.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/services/image_picker_service.dart';

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
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo == null) {
        return Result.failure(
          const PermissionFailure('Tidak ada gambar yang dipilih'),
        );
      }

      return Result.success(photo.path);
    } catch (e) {
      return Result.failure(
        UnknownFailure('Gagal mengambil gambar: ${e.toString()}'),
      );
    }
  }

  /// Opens the gallery and allows image selection
  ///
  /// Returns the file path of the selected image.
  /// Returns a failure if the user cancels or permission is denied.
  @override
  Future<Result<String>> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
      );

      if (image == null) {
        return Result.failure(
          const PermissionFailure('Tidak ada gambar yang dipilih'),
        );
      }

      return Result.success(image.path);
    } catch (e) {
      return Result.failure(
        UnknownFailure('Gagal memilih gambar: ${e.toString()}'),
      );
    }
  }
}
