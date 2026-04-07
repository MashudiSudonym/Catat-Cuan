/// Parser for extracting amounts from receipt text
class ReceiptAmountParser {
  /// Keywords commonly found in receipts to indicate total
  static const List<String> _amountKeywords = [
    'total',
    'jumlah',
    'subtotal',
    'grand total',
    'total bayar',
    'tagihan',
    'amount',
    'sum',
    'bill',
    ' pembayaran',
  ];

  /// Currency prefixes that may be present
  static const List<String> _currencyPrefixes = [
    'rp',
    'rupiah',
    'idr',
    '\$',
    'rb', // thousands (ribuan)
  ];

  /// Minimum reasonable amount (1000 rupiah)
  static const double _minAmount = 1000;

  /// Maximum reasonable amount (100 million rupiah)
  static const double _maxAmount = 100000000;

  /// Amount parsing result
  static const double _confidenceThreshold = 0.7;

  /// Parse amount from receipt text
  ///
  /// Returns [ParseResult] with the found amount
  /// and confidence score. If not found, returns null
  /// with confidence 0.
  static ParseResult parseAmount(String text) {
    final lines = text.toLowerCase().split('\n');

    // Find lines containing total keyword
    for (final keyword in _amountKeywords) {
      for (final line in lines) {
        if (line.contains(keyword)) {
          final amount = _extractAmountFromLine(line);
          if (amount != null && _isReasonableAmount(amount)) {
            return ParseResult(
              amount: amount,
              confidence: 0.9,
              source: 'keyword: $keyword',
            );
          }
        }
      }
    }

    // Fallback: find largest reasonable number
    final allAmounts = _extractAllAmounts(text);
    if (allAmounts.isNotEmpty) {
      // Sort descending and take first (largest)
      allAmounts.sort((a, b) => b.compareTo(a));
      final largest = allAmounts.first;

      return ParseResult(
        amount: largest,
        confidence: 0.5, // Lower confidence because using fallback
        source: 'fallback: largest amount',
      );
    }

    return ParseResult(
      amount: null,
      confidence: 0,
      source: 'no amount found',
    );
  }

  /// Extract number from a single line of text
  static double? _extractAmountFromLine(String line) {
    // Remove currency prefix
    var cleanedLine = line.toLowerCase();
    for (final prefix in _currencyPrefixes) {
      cleanedLine = cleanedLine.replaceAll(prefix, '');
    }

    // Find number patterns with Indonesian format
    // Supported formats:
    // - 1.000.000
    // - 1,000.000 (sometimes comma as thousand separator)
    // - 1000000
    // - 1.000.000,00 (with decimal)
    // - 1,000,000.00 (international format)

    // Regex to capture various number formats
    final patterns = [
      // Indonesian format: 1.000.000 or 1.000.000,00
      RegExp(r'(\d{1,3}(?:\.\d{3})*(?:,\d{2})?)'),
      // International format: 1,000,000 or 1,000,000.00
      RegExp(r'(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)'),
      // Simple format without separator: 1000000
      RegExp(r'(\d{5,})'), // Minimum 5 digits
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(cleanedLine);
      if (match != null) {
        final numberStr = match.group(1)!;
        return _parseIndonesianCurrency(numberStr);
      }
    }

    return null;
  }

  /// Parse Indonesian currency string to double
  ///
  /// Supports formats:
  /// - "Rp 1.000.000" → 1000000.0
  /// - "1.000.000" → 1000000.0
  /// - "1.000.000,50" → 1000000.5
  /// - "1000000" → 1000000.0
  static double? parseCurrency(String currencyStr) {
    return _parseIndonesianCurrency(currencyStr);
  }

  /// Internal method to parse Indonesian currency format
  static double? _parseIndonesianCurrency(String str) {
    try {
      // Remove all spaces
      str = str.replaceAll(' ', '');

      // Check if there's decimal (Indonesian comma)
      final hasDecimal = str.contains(',');

      if (hasDecimal) {
        // Format: 1.000.000,00 or 1,000,000.00
        final parts = str.split(',');
        if (parts.length == 2) {
          // Part before comma is main number
          final mainPart = parts[0];
          // Part after comma is decimal (max 2 digits)
          final decimalPart = parts[1].padRight(2, '0').substring(0, 2);

          // Remove dots and commas from main part
          final cleanedMain = mainPart.replaceAll('.', '').replaceAll(',', '');

          // Combine with decimal
          final combined = '$cleanedMain.$decimalPart';
          return double.tryParse(combined);
        }
      } else {
        // No decimal, remove all thousand separators
        final cleaned = str.replaceAll('.', '').replaceAll(',', '');
        return double.tryParse(cleaned);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Extract all numbers from text
  static List<double> _extractAllAmounts(String text) {
    final amounts = <double>[];

    // Use regex to find all number patterns
    final patterns = [
      RegExp(r'(\d{1,3}(?:\.\d{3})+)'), // 1.000.000
      RegExp(r'(\d{1,3}(?:,\d{3})+)'), // 1,000,000
      RegExp(r'(\d{5,})'), // 1000000 (minimum 5 digits)
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final numberStr = match.group(1)!;
        final amount = _parseIndonesianCurrency(numberStr);
        if (amount != null && _isReasonableAmount(amount)) {
          amounts.add(amount);
        }
      }
    }

    return amounts;
  }

  /// Check if number is within reasonable range for transactions
  static bool _isReasonableAmount(double amount) {
    return amount >= _minAmount && amount <= _maxAmount;
  }

  /// Fallback: find largest reasonable number from text
  static double? findLargestReasonableAmount(String text) {
    final amounts = _extractAllAmounts(text);
    if (amounts.isEmpty) return null;

    amounts.sort((a, b) => b.compareTo(a));
    return amounts.first;
  }

  /// Check if confidence score is high enough
  static bool isConfidentEnough(double confidence) {
    return confidence >= _confidenceThreshold;
  }
}

/// Amount parsing result
class ParseResult {
  final double? amount;
  final double confidence;
  final String source;

  const ParseResult({
    required this.amount,
    required this.confidence,
    required this.source,
  });

  @override
  String toString() {
    return 'ParseResult{amount: $amount, confidence: $confidence, source: $source}';
  }
}
