/// Entity untuk merepresentasikan data hasil scan struk
class ReceiptDataEntity {
  final String? rawText;
  final double? extractedAmount;
  final DateTime? extractedDate;
  final String? merchantName;
  final List<String> items;
  final double confidenceScore;
  final DateTime scannedAt;

  const ReceiptDataEntity({
    this.rawText,
    this.extractedAmount,
    this.extractedDate,
    this.merchantName,
    this.items = const [],
    required this.confidenceScore,
    required this.scannedAt,
  });

  /// CopyWith method untuk immutable updates
  ReceiptDataEntity copyWith({
    String? rawText,
    double? extractedAmount,
    DateTime? extractedDate,
    String? merchantName,
    List<String>? items,
    double? confidenceScore,
    DateTime? scannedAt,
  }) {
    return ReceiptDataEntity(
      rawText: rawText ?? this.rawText,
      extractedAmount: extractedAmount ?? this.extractedAmount,
      extractedDate: extractedDate ?? this.extractedDate,
      merchantName: merchantName ?? this.merchantName,
      items: items ?? this.items,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptDataEntity &&
          runtimeType == other.runtimeType &&
          rawText == other.rawText &&
          extractedAmount == other.extractedAmount &&
          extractedDate == other.extractedDate &&
          merchantName == other.merchantName &&
          items == other.items &&
          confidenceScore == other.confidenceScore &&
          scannedAt == other.scannedAt;

  @override
  int get hashCode =>
      rawText.hashCode ^
      extractedAmount.hashCode ^
      extractedDate.hashCode ^
      merchantName.hashCode ^
      items.hashCode ^
      confidenceScore.hashCode ^
      scannedAt.hashCode;

  @override
  String toString() {
    return 'ReceiptDataEntity{rawText: $rawText, extractedAmount: $extractedAmount, extractedDate: $extractedDate, merchantName: $merchantName, items: $items, confidenceScore: $confidenceScore, scannedAt: $scannedAt}';
  }
}
