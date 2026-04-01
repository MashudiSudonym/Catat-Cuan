/// File Save Service interface for domain layer
///
/// This abstraction follows the Dependency Inversion Principle (DIP)
/// by defining an interface for file save operations using Storage Access Framework.
library;

import 'package:catat_cuan/domain/core/result.dart';

/// Service for saving files using Storage Access Framework (SAF)
///
/// This interface abstracts file save operations, allowing the system
/// file picker to handle location selection and permissions.
/// On Android, this uses ACTION_CREATE_DOCUMENT intent.
/// On iOS, this uses UIDocumentPickerViewController.
abstract class FileSaveService {
  /// Saves a file using Storage Access Framework
  ///
  /// Shows the system file picker dialog allowing the user to choose
  /// the save location and filename. This handles all permissions automatically.
  ///
  /// Parameters:
  /// - [content]: The file content as bytes
  /// - [fileName]: Suggested filename (user can change in picker)
  /// - [mimeType]: The MIME type of the file (e.g., 'text/csv')
  ///
  /// Returns:
  /// - Result.success(String) with the file path where the file was saved
  /// - Result.failure(UserCancelledFailure) if user cancelled the operation
  /// - Result.failure(UnknownFailure) if the save operation failed
  Future<Result<String>> saveFile({
    required List<int> content,
    required String fileName,
    required String mimeType,
  });
}
