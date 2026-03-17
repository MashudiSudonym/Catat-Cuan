import 'package:catat_cuan/domain/entities/receipt_data_entity.dart';
import 'package:catat_cuan/domain/parsers/receipt_amount_parser.dart';
import 'package:catat_cuan/domain/parsers/receipt_date_parser.dart';
import 'package:catat_cuan/domain/services/ocr_service.dart';

/// Use case untuk melakukan scan struk dan ekstrak nominal & tanggal
class ScanReceiptUseCase {
  final OcrService _ocrService;

  ScanReceiptUseCase(this._ocrService);

  /// Execute use case untuk scan struk
  /// Mengembalikan ReceiptDataEntity jika sukses
  /// Melempar exception jika gagal
  Future<ReceiptDataEntity> execute(String imagePath) async {
    // 1. Lakukan OCR untuk mendapatkan teks dari gambar
    final ocrResult = await _ocrService.extractText(imagePath);

    if (ocrResult.isFailure) {
      throw OcrException(ocrResult.failure?.message ?? 'Gagal membaca struk');
    }

    final rawText = ocrResult.dataOrThrow;

    // 2. Parse nominal dari teks
    final amountParseResult = ReceiptAmountParser.parseAmount(rawText);

    // 3. Parse tanggal dan waktu dari teks
    final dateTimeParseResult = ReceiptDateParser.parseDateTime(rawText);

    // 4. Hitung confidence score (rata-rata dari amount dan datetime)
    final avgConfidence = (amountParseResult.confidence + dateTimeParseResult.confidence) / 2;

    // 5. Buat ReceiptDataEntity
    return ReceiptDataEntity(
      rawText: rawText,
      extractedAmount: amountParseResult.amount,
      extractedDate: dateTimeParseResult.dateTime,
      confidenceScore: avgConfidence,
      scannedAt: DateTime.now(),
      items: [], // TODO: Implementasi item extraction di masa depan
      merchantName: null, // TODO: Implementasi merchant name extraction di masa depan
    );
  }
}

/// Exception untuk error OCR
class OcrException implements Exception {
  final String message;

  OcrException(this.message);

  @override
  String toString() => message;
}
