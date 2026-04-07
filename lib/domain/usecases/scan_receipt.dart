import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/receipt_data_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/parsers/receipt_amount_parser.dart';
import 'package:catat_cuan/domain/parsers/receipt_date_time_composer.dart';
import 'package:catat_cuan/domain/parsers/receipt_merchant_parser.dart';
import 'package:catat_cuan/domain/services/ocr_service.dart';

/// Use case untuk melakukan scan struk dan ekstrak nominal, tanggal, & merchant
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles receipt scanning
/// - Dependency Inversion: Depends on OcrService abstraction
class ScanReceiptUseCase extends UseCase<ReceiptDataEntity, String> {
  final OcrService _ocrService;
  final ReceiptMerchantParser _merchantParser;

  ScanReceiptUseCase(
    this._ocrService,
    this._merchantParser,
  );

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

    // 4. Parse merchant name dari teks (NEW!)
    final merchantParseResult = _merchantParser.parseMerchant(rawText);

    // 5. Hitung confidence score dengan pembobotan:
    //    - Amount: 40%
    //    - DateTime: 30%
    //    - Merchant: 30%
    final amountConfidence = amountParseResult.confidence;
    final dateTimeConfidence = dateTimeParseResult.confidence;
    final merchantConfidence = merchantParseResult.isFailure
        ? 0.0
        : (merchantParseResult.data?.confidence ?? 0.0);

    final combinedConfidence = (amountConfidence * 0.4) +
        (dateTimeConfidence * 0.3) +
        (merchantConfidence * 0.3);

    // 6. Ambil data merchant
    final merchantName = merchantParseResult.isSuccess
        ? merchantParseResult.data?.merchantName
        : null;

    // 7. Buat ReceiptDataEntity
    return Result.success(
      ReceiptDataEntity(
        rawText: rawText,
        extractedAmount: amountParseResult.amount,
        extractedDate: dateTimeParseResult.dateTime,
        confidenceScore: combinedConfidence,
        scannedAt: DateTime.now(),
        items: [], // TODO: Implementasi item extraction di masa depan
        merchantName: merchantName,
      ),
    );
  }
}
