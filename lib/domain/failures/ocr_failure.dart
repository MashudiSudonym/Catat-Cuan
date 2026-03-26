import 'failure.dart';

/// Failure for OCR operation errors (e.g., text extraction failed)
class OcrFailure extends Failure {
  const OcrFailure(super.message);
}
