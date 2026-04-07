import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/merchant_pattern_entity.dart';
import 'package:catat_cuan/domain/services/merchant_pattern_service.dart';

/// Parser untuk mengekstrak nama merchant dari teks struk
///
/// Parser ini menggunakan berbagai strategi untuk mengenali merchant:
/// 1. Header matching (baris pertama struk) - prioritas tertinggi
/// 2. Keyword matching (seluruh teks) - prioritas sedang
/// 3. Pattern matching (baris per baris) - prioritas rendah
class ReceiptMerchantParser {
  final MerchantPatternService _patternService;

  /// Threshold keyakinan minimum untuk menganggap merchant ditemukan
  static const double _confidenceThreshold = 0.6;

  ReceiptMerchantParser(this._patternService);

  /// Parse merchant name dari teks struk
  ///
  /// Parameters:
  /// - [receiptText]: Teks penuh dari hasil OCR struk
  ///
  /// Returns Result dengan MerchantParseResult berisi:
  /// - merchantName: Nama merchant yang dikenali (null jika tidak ditemukan)
  /// - confidence: Skor keyakinan 0.0 - 1.0
  /// - matchedPattern: Pola merchant yang cocok (null jika tidak ditemukan)
  Result<MerchantParseResult> parseMerchant(String receiptText) {
    if (receiptText.trim().isEmpty) {
      return Result.success(const MerchantParseResult(
        merchantName: null,
        confidence: 0.0,
        matchedPattern: null,
      ));
    }

    final lines = receiptText.split('\n');

    // Strategi 1: Header matching (5 baris pertama) - keyakinan tertinggi
    final headerMatch = _matchInHeader(lines.take(7).toList());
    if (headerMatch != null && headerMatch.confidence >= 0.9) {
      return Result.success(headerMatch);
    }

    // Strategi 2: Full text keyword matching - keyakinan sedang
    final keywordMatch = _matchByKeywords(receiptText);
    if (keywordMatch != null && keywordMatch.confidence >= 0.7) {
      return Result.success(keywordMatch);
    }

    // Strategi 3: Pattern-based matching baris per baris - keyakinan rendah
    final patternMatch = _matchByPattern(lines);
    if (patternMatch != null && patternMatch.confidence >= _confidenceThreshold) {
      return Result.success(patternMatch);
    }

    // Tidak ada merchant yang ditemukan
    return Result.success(const MerchantParseResult(
      merchantName: null,
      confidence: 0.0,
      matchedPattern: null,
    ));
  }

  /// Mencocokkan merchant di header struk (baris pertama)
  ///
  /// Baris pertama struk biasanya berisi nama merchant paling jelas.
  /// Metode ini memberikan keyakinan tertinggi (0.95+).
  MerchantParseResult? _matchInHeader(List<String> headerLines) {
    if (headerLines.isEmpty) return null;

    final headerText = headerLines.join('\n').toUpperCase();

    // Cari semua pola yang cocok di header
    final matches = <MerchantPatternEntity>[];
    for (final pattern in _patternService.getPatterns()) {
      for (final namePattern in pattern.namePatterns) {
        if (headerText.contains(namePattern)) {
          matches.add(pattern);
          break; // Sudah dapat pattern ini, lanjut ke pattern lain
        }
      }
    }

    if (matches.isEmpty) return null;

    // Sort berdasarkan priority tertinggi
    matches.sort((a, b) => b.priority.compareTo(a.priority));
    final bestMatch = matches.first;

    return MerchantParseResult(
      merchantName: bestMatch.merchantName,
      confidence: 0.95, // Header match adalah keyakinan tertinggi
      matchedPattern: bestMatch,
    );
  }

  /// Mencocokkan merchant menggunakan keyword di seluruh teks
  ///
  /// Metode ini memberikan skor berdasarkan jumlah keyword yang cocok:
  /// - Nama pattern: 0.5 poin
  /// - Header pattern: 0.2 poin
  /// - Address pattern: 0.1 poin
  /// Total minimum 0.6 untuk dianggap cocok.
  MerchantParseResult? _matchByKeywords(String fullText) {
    final upperText = fullText.toUpperCase();
    MerchantPatternEntity? bestMatch;
    double bestScore = 0.0;

    for (final pattern in _patternService.getPatterns()) {
      double score = 0.0;

      // Cek nama pattern (bobot tertinggi)
      for (final namePattern in pattern.namePatterns) {
        if (upperText.contains(namePattern)) {
          score += 0.5;
          break; // Cukup satu nama pattern yang cocok
        }
      }

      // Cek header pattern (bobot sedang)
      for (final headerPattern in pattern.headerPatterns) {
        if (upperText.contains(headerPattern)) {
          score += 0.2;
          // Tidak break karena bisa ada multiple header patterns
        }
      }

      // Cek address pattern (bobot rendah)
      for (final addressPattern in pattern.addressPatterns) {
        if (upperText.contains(addressPattern)) {
          score += 0.1;
          // Tidak break karena bisa ada multiple address patterns
        }
      }

      // Update best match jika score lebih tinggi
      if (score > bestScore && score >= _confidenceThreshold) {
        bestScore = score;
        bestMatch = pattern;
      }
    }

    if (bestMatch == null) return null;

    // Normalize score ke 0.0 - 1.0 range
    final normalizedScore = (bestScore * 1.5).clamp(0.0, 1.0);

    return MerchantParseResult(
      merchantName: bestMatch.merchantName,
      confidence: normalizedScore,
      matchedPattern: bestMatch,
    );
  }

  /// Mencocokkan merchant baris per baris
  ///
  /// Metode ini memeriksa setiap baris dan mencari pola merchant.
  /// Memberikan keyakinan rendah (0.6) cocok untuk fallback.
  MerchantParseResult? _matchByPattern(List<String> lines) {
    for (final line in lines) {
      final trimmedLine = line.trim();

      // Skip baris kosong atau baris yang terlihat seperti amount
      if (trimmedLine.isEmpty || _isAmountLine(trimmedLine)) {
        continue;
      }

      final upperLine = trimmedLine.toUpperCase();

      // Cek semua merchant patterns
      for (final pattern in _patternService.getPatterns()) {
        for (final namePattern in pattern.namePatterns) {
          // Gunakan contains match tapi pasti itu kata lengkap
          if (_containsWholeWord(upperLine, namePattern)) {
            return MerchantParseResult(
              merchantName: pattern.merchantName,
              confidence: 0.6, // Pattern matching keyakinan rendah
              matchedPattern: pattern,
            );
          }
        }
      }
    }

    return null;
  }

  /// Cek apakah baris terlihat seperti baris amount
  ///
  /// Baris amount biasanya memiliki banyak digit (minimal 4 digit)
  /// untuk menunjukkan nominal uang.
  bool _isAmountLine(String line) {
    // Hapus semua non-digit
    final digitCount = line.replaceAll(RegExp(r'[^\d]'), '').length;
    return digitCount >= 4;
  }

  /// Cek apakah teks mengandung kata lengkap (bukan substring)
  ///
  /// Contoh:
  /// - "ALFAMART" mengandung "ALFA" → true (kata lengkap "ALFA")
  /// - "KUALIFIKASI" mengandung "ALFA" → false (hanya substring)
  bool _containsWholeWord(String text, String word) {
    // Jika word mengandung spasi, gunakan contains langsung
    if (word.contains(' ')) {
      return text.contains(word);
    }

    // Gunakan word boundary regex
    final pattern = RegExp(r'\b' + RegExp.escape(word) + r'\b');
    return pattern.hasMatch(text);
  }

  /// Parse merchant name dan kategori default dari receipt text
  ///
  /// Metode helper untuk mendapatkan nama merchant dan kategori default
  /// dalam satu pemanggilan.
  ///
  /// Returns Map dengan:
  /// - 'merchantName': String? nama merchant
  /// - 'categoryName': String? nama kategori default
  /// - 'confidence': double skor keyakinan
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
