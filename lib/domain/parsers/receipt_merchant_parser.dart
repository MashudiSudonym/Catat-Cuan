import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/merchant_pattern_entity.dart';
import 'package:catat_cuan/domain/services/merchant_pattern_service.dart';

/// Parser for extracting merchant names from receipt text
///
/// This parser uses various strategies to recognize merchants:
/// 1. Header matching (first line of receipt) - highest priority
/// 2. Keyword matching (entire text) - medium priority
/// 3. Pattern matching (line by line) - low priority
class ReceiptMerchantParser {
  final MerchantPatternService _patternService;

  /// Minimum confidence threshold to consider merchant found
  static const double _confidenceThreshold = 0.6;

  ReceiptMerchantParser(this._patternService);

  /// Parse merchant name from receipt text
  ///
  /// Parameters:
  /// - [receiptText]: Full text from OCR receipt scan
  ///
  /// Returns Result with MerchantParseResult containing:
  /// - merchantName: Recognized merchant name (null if not found)
  /// - confidence: Confidence score 0.0 - 1.0
  /// - matchedPattern: Matched merchant pattern (null if not found)
  Result<MerchantParseResult> parseMerchant(String receiptText) {
    if (receiptText.trim().isEmpty) {
      return Result.success(const MerchantParseResult(
        merchantName: null,
        confidence: 0.0,
        matchedPattern: null,
      ));
    }

    final lines = receiptText.split('\n');

    // Strategy 1: Header matching (first 5 lines) - highest confidence
    final headerMatch = _matchInHeader(lines.take(7).toList());
    if (headerMatch != null && headerMatch.confidence >= 0.9) {
      return Result.success(headerMatch);
    }

    // Strategy 2: Full text keyword matching - medium confidence
    final keywordMatch = _matchByKeywords(receiptText);
    if (keywordMatch != null && keywordMatch.confidence >= 0.7) {
      return Result.success(keywordMatch);
    }

    // Strategy 3: Pattern-based matching line by line - low confidence
    final patternMatch = _matchByPattern(lines);
    if (patternMatch != null && patternMatch.confidence >= _confidenceThreshold) {
      return Result.success(patternMatch);
    }

    // No merchant found
    return Result.success(const MerchantParseResult(
      merchantName: null,
      confidence: 0.0,
      matchedPattern: null,
    ));
  }

  /// Match merchant in receipt header (first line)
  ///
  /// First line of receipt usually contains clearest merchant name.
  /// This method gives highest confidence (0.95+).
  MerchantParseResult? _matchInHeader(List<String> headerLines) {
    if (headerLines.isEmpty) return null;

    final headerText = headerLines.join('\n').toUpperCase();

    // Find all matching patterns in header
    final matches = <MerchantPatternEntity>[];
    for (final pattern in _patternService.getPatterns()) {
      for (final namePattern in pattern.namePatterns) {
        if (headerText.contains(namePattern)) {
          matches.add(pattern);
          break; // Already got this pattern, continue to next pattern
        }
      }
    }

    if (matches.isEmpty) return null;

    // Sort by highest priority
    matches.sort((a, b) => b.priority.compareTo(a.priority));
    final bestMatch = matches.first;

    return MerchantParseResult(
      merchantName: bestMatch.merchantName,
      confidence: 0.95, // Header match is highest confidence
      matchedPattern: bestMatch,
    );
  }

  /// Match merchant using keywords in entire text
  ///
  /// This method gives score based on number of matching keywords:
  /// - Name pattern: 0.5 points
  /// - Header pattern: 0.2 points
  /// - Address pattern: 0.1 points
  /// Minimum total 0.6 to be considered a match.
  MerchantParseResult? _matchByKeywords(String fullText) {
    final upperText = fullText.toUpperCase();
    MerchantPatternEntity? bestMatch;
    double bestScore = 0.0;

    for (final pattern in _patternService.getPatterns()) {
      double score = 0.0;

      // Check name pattern (highest weight)
      for (final namePattern in pattern.namePatterns) {
        if (upperText.contains(namePattern)) {
          score += 0.5;
          break; // One matching name pattern is enough
        }
      }

      // Check header pattern (medium weight)
      for (final headerPattern in pattern.headerPatterns) {
        if (upperText.contains(headerPattern)) {
          score += 0.2;
          // Don't break as there can be multiple header patterns
        }
      }

      // Check address pattern (low weight)
      for (final addressPattern in pattern.addressPatterns) {
        if (upperText.contains(addressPattern)) {
          score += 0.1;
          // Don't break as there can be multiple address patterns
        }
      }

      // Update best match if score is higher
      if (score > bestScore && score >= _confidenceThreshold) {
        bestScore = score;
        bestMatch = pattern;
      }
    }

    if (bestMatch == null) return null;

    // Normalize score to 0.0 - 1.0 range
    final normalizedScore = (bestScore * 1.5).clamp(0.0, 1.0);

    return MerchantParseResult(
      merchantName: bestMatch.merchantName,
      confidence: normalizedScore,
      matchedPattern: bestMatch,
    );
  }

  /// Match merchant line by line
  ///
  /// This method checks each line and looks for merchant patterns.
  /// Gives low confidence (0.6) suitable for fallback.
  MerchantParseResult? _matchByPattern(List<String> lines) {
    for (final line in lines) {
      final trimmedLine = line.trim();

      // Skip empty lines or lines that look like amounts
      if (trimmedLine.isEmpty || _isAmountLine(trimmedLine)) {
        continue;
      }

      final upperLine = trimmedLine.toUpperCase();

      // Check all merchant patterns
      for (final pattern in _patternService.getPatterns()) {
        for (final namePattern in pattern.namePatterns) {
          // Use contains match but ensure it's a whole word
          if (_containsWholeWord(upperLine, namePattern)) {
            return MerchantParseResult(
              merchantName: pattern.merchantName,
              confidence: 0.6, // Pattern matching low confidence
              matchedPattern: pattern,
            );
          }
        }
      }
    }

    return null;
  }

  /// Check if line looks like an amount line
  ///
  /// Amount lines usually have many digits (minimum 4 digits)
  /// to indicate monetary value.
  bool _isAmountLine(String line) {
    // Remove all non-digits
    final digitCount = line.replaceAll(RegExp(r'[^\d]'), '').length;
    return digitCount >= 4;
  }

  /// Check if text contains a whole word (not substring)
  ///
  /// Examples:
  /// - "ALFAMART" contains "ALFA" → true (whole word "ALFA")
  /// - "KUALIFIKASI" contains "ALFA" → false (only substring)
  bool _containsWholeWord(String text, String word) {
    // If word contains space, use contains directly
    if (word.contains(' ')) {
      return text.contains(word);
    }

    // Use word boundary regex
    final pattern = RegExp(r'\b' + RegExp.escape(word) + r'\b');
    return pattern.hasMatch(text);
  }

  /// Parse merchant name and default category from receipt text
  ///
  /// Helper method to get merchant name and default category
  /// in a single call.
  ///
  /// Returns Map with:
  /// - 'merchantName': String? merchant name
  /// - 'categoryName': String? default category name
  /// - 'confidence': double confidence score
  Map<String, dynamic> parseMerchantWithCategory(String receiptText) {
    final result = parseMerchant(receiptText);

    if (result.isFailure || result.data == null || !result.data!.hasMerchant) {
      return {
        'merchantName': null,
        'categoryName': null,
        'confidence': 0.0,
      };
    }

    final merchantResult = result.data!;

    return {
      'merchantName': merchantResult.merchantName,
      'categoryName': merchantResult.matchedPattern?.defaultCategoryName,
      'confidence': merchantResult.confidence,
    };
  }
}
