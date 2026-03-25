import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt_data_entity.freezed.dart';

/// Entity untuk merepresentasikan data hasil scan struk
@freezed
abstract class ReceiptDataEntity with _$ReceiptDataEntity {
  const ReceiptDataEntity._();

  const factory ReceiptDataEntity({
    /// Raw text extracted from the receipt
    String? rawText,

    /// Amount extracted from the receipt
    double? extractedAmount,

    /// Date extracted from the receipt
    DateTime? extractedDate,

    /// Merchant/shop name
    String? merchantName,

    /// List of items detected
    @Default([]) List<String> items,

    /// Confidence score (0.0 - 1.0)
    required double confidenceScore,

    /// When the receipt was scanned
    required DateTime scannedAt,
  }) = _ReceiptDataEntity;
}
