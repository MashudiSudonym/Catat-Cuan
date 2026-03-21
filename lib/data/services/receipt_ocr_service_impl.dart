import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/services/ocr_service.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementation of OCR service using Google ML Kit
///
/// This service processes images to extract text using Google ML Kit
/// Text Recognition v2. It follows the Dependency Inversion Principle
/// by implementing the domain-layer OcrService interface.
class ReceiptOcrServiceImpl implements OcrService {
  final TextRecognizer _textRecognizer;

  ReceiptOcrServiceImpl() : _textRecognizer = TextRecognizer() {
    AppLogger.d('ReceiptOcrService initialized');
  }

  /// Extracts text from an image file
  ///
  /// Processes the image using Google ML Kit and returns the recognized text.
  /// Returns a failure result if text extraction fails.
  @override
  Future<Result<String>> extractText(String imagePath) async {
    AppLogger.d('Starting OCR extraction for: $imagePath');

    try {
      // Create InputImage from file path
      final inputImage = InputImage.fromFilePath(imagePath);
      AppLogger.d('InputImage created successfully');

      // Process OCR
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      final extractedText = recognizedText.text;
      AppLogger.i('OCR extraction successful, text length: ${extractedText.length}');

      // Return the extracted text
      return Result.success(extractedText);
    } catch (e, stackTrace) {
      AppLogger.e('OCR extraction failed', e, stackTrace);
      return Result.failure(const OcrFailure('Gagal membaca struk'));
    }
  }

  /// Closes the text recognizer to release resources
  ///
  /// This should be called when the service is no longer needed
  /// to prevent memory leaks.
  @override
  void dispose() {
    AppLogger.d('Disposing ReceiptOcrService');
    _textRecognizer.close();
  }
}
