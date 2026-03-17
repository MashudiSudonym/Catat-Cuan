/// OCR Service interface for domain layer
///
/// This abstraction follows the Dependency Inversion Principle (DIP)
/// by defining an interface that the domain layer depends on,
/// rather than depending on concrete implementations.
library;

import 'package:catat_cuan/domain/core/result.dart';

/// Service for extracting text from images using OCR
///
/// This interface abstracts the OCR implementation, allowing
/// different providers (Google ML Kit, Tesseract, etc.) to be
/// used interchangeably.
abstract class OcrService {
  /// Extracts text from an image file
  ///
  /// Parameters:
  /// - [imagePath]: The absolute path to the image file
  ///
  /// Returns:
  /// - Result.success(String) with the extracted text if successful
  /// - Result.failure(OcrFailure) if text extraction fails
  Future<Result<String>> extractText(String imagePath);

  /// Releases resources used by the OCR service
  ///
  /// This should be called when the service is no longer needed
  /// to prevent memory leaks (e.g., closing ML Kit recognizers).
  void dispose();
}
