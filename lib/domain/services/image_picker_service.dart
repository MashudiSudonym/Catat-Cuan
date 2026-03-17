/// Image Picker Service interface for domain layer
///
/// This abstraction follows the Dependency Inversion Principle (DIP)
/// by defining an interface for image selection operations.
library;

import 'package:catat_cuan/domain/core/result.dart';

/// Service for selecting images from camera or gallery
///
/// This interface abstracts the image picker implementation,
/// allowing different packages or custom implementations to be used.
abstract class ImagePickerService {
  /// Opens the camera and captures a new image
  ///
  /// Returns:
  /// - Result.success(String) with the file path if successful
  /// - Result.failure(PermissionFailure) if camera permission is denied
  /// - Result.failure(UnknownFailure) if image capture fails or user cancels
  Future<Result<String>> pickImageFromCamera();

  /// Opens the gallery and allows image selection
  ///
  /// Returns:
  /// - Result.success(String) with the file path if successful
  /// - Result.failure(PermissionFailure) if storage permission is denied
  /// - Result.failure(UnknownFailure) if image selection fails or user cancels
  Future<Result<String>> pickImageFromGallery();
}
