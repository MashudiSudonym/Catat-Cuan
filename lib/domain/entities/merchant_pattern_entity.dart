import 'package:freezed_annotation/freezed_annotation.dart';

part 'merchant_pattern_entity.freezed.dart';

/// Entity representing merchant patterns on receipts
///
/// This entity is used to recognize merchants based on
/// text patterns on receipts (e.g., "INDOMARET", "ALFAMART")
@freezed
abstract class MerchantPatternEntity with _$MerchantPatternEntity {
  const MerchantPatternEntity._();

  const factory MerchantPatternEntity({
    /// Unique ID for merchant pattern
    required String id,

    /// Merchant name to display to user
    required String merchantName,

    /// List of name patterns to search for in receipts
    /// Example: ['INDOMARET', 'INdicart', 'Point']
    required List<String> namePatterns,

    /// List of address patterns to search for (optional)
    /// Example: ['Jl.', 'Jalan', 'KAB', 'KOTA']
    required List<String> addressPatterns,

    /// List of header patterns to search for (optional)
    /// Example: ['TOKO', 'MINIMARKET', 'SUPERMARKET']
    required List<String> headerPatterns,

    /// Default category name for this merchant
    /// This is the *category name* that must match CategoryEntity.name
    /// Example: 'Belanja Harian', 'Makanan & Minuman', 'Transportasi'
    required String defaultCategoryName,

    /// Alternative names/aliases for merchant
    /// Example: ['Indo', 'Indomaret Point'] for Indomaret
    required List<String> aliases,

    /// Matching priority (higher values are prioritized)
    /// Used when multiple merchants match
    required int priority,
  }) = _MerchantPatternEntity;

  /// Check if text matches this merchant's name pattern
  bool matchesName(String text) {
    final upperText = text.toUpperCase();
    return namePatterns.any((pattern) => upperText.contains(pattern));
  }

  /// Check if text matches this merchant's address pattern
  bool matchesAddress(String text) {
    final upperText = text.toUpperCase();
    return addressPatterns.any((pattern) => upperText.contains(pattern));
  }

  /// Check if text matches this merchant's header pattern
  bool matchesHeader(String text) {
    final upperText = text.toUpperCase();
    return headerPatterns.any((pattern) => upperText.contains(pattern));
  }
}

/// Entity for merchant parsing result from receipt
@freezed
abstract class MerchantParseResult with _$MerchantParseResult {
  const factory MerchantParseResult({
    /// Detected merchant name (null if not found)
    String? merchantName,

    /// Confidence score (0.0 - 1.0)
    required double confidence,

    /// Matched merchant pattern (null if not found)
    MerchantPatternEntity? matchedPattern,
  }) = _MerchantParseResult;

  const MerchantParseResult._();

  /// Check if result is confident enough
  bool get isConfident => confidence >= 0.7;

  /// Check if merchant was found
  bool get hasMerchant => merchantName != null && merchantName!.isNotEmpty;
}
