/// Parser untuk mengekstrak nominal dari teks struk
class ReceiptAmountParser {
  /// Keyword yang biasanya ada di struk untuk menandai total
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

  /// Prefix mata uang yang mungkin ada
  static const List<String> _currencyPrefixes = [
    'rp',
    'rupiah',
    'idr',
    '\$',
    'rb', // ribuan
  ];

  /// Minimum reasonable amount (1000 rupiah)
  static const double _minAmount = 1000;

  /// Maximum reasonable amount (100 juta rupiah)
  static const double _maxAmount = 100000000;

  /// Hasil parsing nominal
  static const double _confidenceThreshold = 0.7;

  /// Parse nominal dari teks struk
  ///
  /// Mengembalikan [ParseResult] dengan nominal yang ditemukan
  /// dan confidence score. Jika tidak ditemukan, kembalikan null
  /// dengan confidence 0.
  static ParseResult parseAmount(String text) {
    final lines = text.toLowerCase().split('\n');

    // Cari baris yang mengandung keyword total
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

    // Fallback: cari angka terbesar yang wajar
    final allAmounts = _extractAllAmounts(text);
    if (allAmounts.isNotEmpty) {
      // Sort descending dan ambil yang pertama (terbesar)
      allAmounts.sort((a, b) => b.compareTo(a));
      final largest = allAmounts.first;

      return ParseResult(
        amount: largest,
        confidence: 0.5, // Lower confidence karena pakai fallback
        source: 'fallback: largest amount',
      );
    }

    return ParseResult(
      amount: null,
      confidence: 0,
      source: 'no amount found',
    );
  }

  /// Ekstrak angka dari satu baris teks
  static double? _extractAmountFromLine(String line) {
    // Hapus prefix mata uang
    var cleanedLine = line.toLowerCase();
    for (final prefix in _currencyPrefixes) {
      cleanedLine = cleanedLine.replaceAll(prefix, '');
    }

    // Cari pola angka dengan format Indonesia
    // Format yang didukung:
    // - 1.000.000
    // - 1,000.000 (kadang ada koma sebagai pemisah ribuan)
    // - 1000000
    // - 1.000.000,00 (dengan desimal)
    // - 1,000,000.00 (format internasional)

    // Regex untuk menangkap berbagai format angka
    final patterns = [
      // Format Indonesia: 1.000.000 atau 1.000.000,00
      RegExp(r'(\d{1,3}(?:\.\d{3})*(?:,\d{2})?)'),
      // Format internasional: 1,000,000 atau 1,000,000.00
      RegExp(r'(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)'),
      // Format sederhana tanpa pemisah: 1000000
      RegExp(r'(\d{5,})'), // Minimal 5 digit
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

  /// Parse string mata uang Indonesia ke double
  ///
  /// Mendukung format:
  /// - "Rp 1.000.000" → 1000000.0
  /// - "1.000.000" → 1000000.0
  /// - "1.000.000,50" → 1000000.5
  /// - "1000000" → 1000000.0
  static double? parseCurrency(String currencyStr) {
    return _parseIndonesianCurrency(currencyStr);
  }

  /// Internal method untuk parse format mata uang Indonesia
  static double? _parseIndonesianCurrency(String str) {
    try {
      // Hapus semua spasi
      str = str.replaceAll(' ', '');

      // Cek apakah ada desimal (koma Indonesia)
      final hasDecimal = str.contains(',');

      if (hasDecimal) {
        // Format: 1.000.000,00 atau 1,000,000.00
        final parts = str.split(',');
        if (parts.length == 2) {
          // Bagian depan koma adalah angka utama
          final mainPart = parts[0];
          // Bagian belakang koma adalah desimal (max 2 digit)
          final decimalPart = parts[1].padRight(2, '0').substring(0, 2);

          // Hapus titik dan koma dari bagian utama
          final cleanedMain = mainPart.replaceAll('.', '').replaceAll(',', '');

          // Gabungkan dengan desimal
          final combined = '$cleanedMain.$decimalPart';
          return double.tryParse(combined);
        }
      } else {
        // Tidak ada desimal, hapus semua pemisah ribuan
        final cleaned = str.replaceAll('.', '').replaceAll(',', '');
        return double.tryParse(cleaned);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Ekstrak semua angka dari teks
  static List<double> _extractAllAmounts(String text) {
    final amounts = <double>[];

    // Gunakan regex untuk mencari semua pola angka
    final patterns = [
      RegExp(r'(\d{1,3}(?:\.\d{3})+)'), // 1.000.000
      RegExp(r'(\d{1,3}(?:,\d{3})+)'), // 1,000,000
      RegExp(r'(\d{5,})'), // 1000000 (minimal 5 digit)
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

  /// Cek apakah angka berada dalam range yang wajar untuk transaksi
  static bool _isReasonableAmount(double amount) {
    return amount >= _minAmount && amount <= _maxAmount;
  }

  /// Fallback: cari angka terbesar yang wajar dari teks
  static double? findLargestReasonableAmount(String text) {
    final amounts = _extractAllAmounts(text);
    if (amounts.isEmpty) return null;

    amounts.sort((a, b) => b.compareTo(a));
    return amounts.first;
  }

  /// Cek apakah confidence score cukup tinggi
  static bool isConfidentEnough(double confidence) {
    return confidence >= _confidenceThreshold;
  }
}

/// Hasil parsing nominal
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
