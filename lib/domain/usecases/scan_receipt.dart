import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/receipt_data_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/parsers/receipt_amount_parser.dart';
import 'package:catat_cuan/domain/parsers/receipt_date_time_composer.dart';
import 'package:catat_cuan/domain/services/ocr_service.dart';

/// Use case untuk melakukan scan struk dan ekstrak nominal & tanggal
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles receipt scanning
/// - Dependency Inversion: Depends on OcrService abstraction
class ScanReceiptUseCase extends UseCase<ReceiptDataEntity, String> {
  final OcrService _ocrService;

  ScanReceiptUseCase(this._ocrService);

  @override
  Future<Result<ReceiptDataEntity>> call(String imagePath) async {
    // 1. Lakukan OCR untuk mendapatkan teks dari gambar
    final ocrResult = await _ocrService.extractText(imagePath);

    if (ocrResult.isFailure) {
      return Result.failure(
        OcrFailure(ocrResult.failure?.message ?? 'Gagal membaca struk'),
      );
    }

    final rawText = ocrResult.data!;

    // 2. Parse nominal dari teks
    final amountParseResult = ReceiptAmountParser.parseAmount(rawText);

    // 3. Parse tanggal dan waktu dari teks
    final dateTimeParseResult = ReceiptDateTimeComposer.parseDateTime(rawText);

    // 4. Hitung confidence score (rata-rata dari amount dan datetime)
    final avgConfidence = (amountParseResult.confidence + dateTimeParseResult.confidence) / 2;

    // 5. Buat ReceiptDataEntity
    return Result.success(
      ReceiptDataEntity(
        rawText: rawText,
        extractedAmount: amountParseResult.amount,
        extractedDate: dateTimeParseResult.dateTime,
        confidenceScore: avgConfidence,
        scannedAt: DateTime.now(),
        items: [], // TODO: Implementasi item extraction di masa depan
        merchantName: null, // TODO: Implementasi merchant name extraction di masa depan
      ),
    );
  }
}
