import 'package:intl/intl.dart';

/// Parser untuk mengekstrak tanggal dari teks struk
///
/// Focused hanya pada parsing tanggal, bukan waktu.
/// Untuk parsing datetime lengkap, gunakan [ReceiptDateTimeComposer].
class ReceiptDateParser {
  /// Keyword yang biasanya ada di struk untuk menandai tanggal
  static const List<String> dateKeywords = [
    'tanggal',
    'date',
    'tgl',
    'dt',
    'tanggal transaksi',
    'transaction date',
    'trx date',
  ];

  /// Format tanggal yang didukung untuk Indonesia
  static const List<String> supportedFormats = [
    // Format dengan pemisah slash
    'dd/MM/yyyy',
    'd/M/yyyy',
    'dd/M/yyyy',
    'd/MM/yyyy',
    // Format dengan pemisah dash
    'dd-MM-yyyy',
    'd-M-yyyy',
    'dd-M-yyyy',
    'd-MM-yyyy',
    // Format dengan pemisah dot
    'dd.MM.yyyy',
    'd.M.yyyy',
    'dd.M.yyyy',
    'd.MM.yyyy',
    // Format nama bulan (Indonesia & Inggris)
    'dd MMM yyyy',
    'd MMM yyyy',
    'dd MMMM yyyy',
    'd MMMM yyyy',
    // Format tanpa tahun (asumsi tahun saat ini)
    'dd/MM',
    'dd-MM',
    'dd MMM',
    'dd MMMM',
  ];

  /// Nama bulan dalam bahasa Indonesia
  static const List<String> indonesianMonths = [
    'jan', 'feb', 'mar', 'apr', 'mei', 'jun',
    'jul', 'agu', 'sep', 'okt', 'nov', 'des',
    'januari', 'februari', 'maret', 'april', 'mei', 'juni',
    'juli', 'agustus', 'september', 'oktober', 'november', 'desember',
  ];

  /// Nama bulan dalam bahasa Inggris
  static const List<String> englishMonths = [
    'jan', 'feb', 'mar', 'apr', 'may', 'jun',
    'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
    'january', 'february', 'march', 'april', 'may', 'june',
    'july', 'august', 'september', 'october', 'november', 'december',
  ];

  /// Batas tahun minimum (2000)
  static const int minYear = 2000;

  /// Batas tahun maksimum (tahun saat ini + 1)
  static int get maxYear => DateTime.now().year + 1;

  /// Parse tanggal dari teks struk
  ///
  /// Mengembalikan [DateParseResult] dengan tanggal yang ditemukan
  /// dan confidence score. Jika tidak ditemukan, kembalikan null
  /// dengan confidence 0.
  static DateParseResult parseDate(String text) {
    final lines = text.toLowerCase().split('\n');

    // 1. Cari baris yang mengandung keyword tanggal
    for (final keyword in dateKeywords) {
      for (final line in lines) {
        if (line.contains(keyword)) {
          final date = _extractDateFromLine(line);
          if (date != null) {
            return DateParseResult(
              date: date,
              confidence: 0.9,
              source: 'keyword: $keyword',
            );
          }
        }
      }
    }

    // 2. Cari semua tanggal dalam teks tanpa keyword
    final allDates = _extractAllDates(text);
    if (allDates.isNotEmpty) {
      // Kembalikan tanggal pertama yang ditemukan
      return DateParseResult(
        date: allDates.first,
        confidence: 0.5,
        source: 'fallback: first date found',
      );
    }

    return DateParseResult(
      date: null,
      confidence: 0,
      source: 'no date found',
    );
  }

  /// Ekstrak tanggal dari satu baris teks
  static DateTime? _extractDateFromLine(String line) {
    // Bersihkan baris dari keyword
    var cleanedLine = line.toLowerCase();
    for (final keyword in dateKeywords) {
      cleanedLine = cleanedLine.replaceAll(keyword, '');
    }

    // Coba parse dengan berbagai format
    for (final format in supportedFormats) {
      try {
        // Handle format tanpa tahun
        if (format == 'dd/MM' || format == 'dd-MM') {
          final match = RegExp(r'(\d{1,2})[/\-](\d{1,2})').firstMatch(cleanedLine);
          if (match != null) {
            final day = int.parse(match.group(1)!);
            final month = int.parse(match.group(2)!);
            final year = DateTime.now().year;
            return _tryCreateDate(year, month, day);
          }
        } else if (format == 'dd MMM' || format == 'dd MMMM') {
          final match = RegExp(r'(\d{1,2})\s+([a-zA-Z]+)').firstMatch(cleanedLine);
          if (match != null) {
            final day = int.parse(match.group(1)!);
            final monthStr = match.group(2)!;
            final month = _parseMonthName(monthStr);
            if (month != null) {
              final year = DateTime.now().year;
              return _tryCreateDate(year, month, day);
            }
          }
        } else {
          // Gunakan DateFormat untuk format lengkap
          final dateFormat = DateFormat(format);
          final date = dateFormat.parseStrict(cleanedLine.trim());
          if (_isValidDate(date)) {
            return date;
          }
        }
      } catch (_) {
        // Continue ke format berikutnya
      }
    }

    return null;
  }

  /// Ekstrak semua tanggal dari teks
  static List<DateTime> _extractAllDates(String text) {
    final dates = <DateTime>[];

    // Pola regex untuk berbagai format tanggal
    final patterns = [
      // dd/mm/yyyy atau dd-mm-yyyy
      RegExp(r'\b(\d{1,2})[/\-\.](\d{1,2})[/\-\.](\d{2,4})\b'),
      // dd MMM yyyy (dengan nama bulan)
      RegExp(r'\b(\d{1,2})\s+([a-zA-Z]{3,9})\s+(\d{2,4})\b'),
      // yyyy-mm-dd (ISO format)
      RegExp(r'\b(\d{4})[/\-](\d{1,2})[/\-](\d{1,2})\b'),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        DateTime? date;

        if (match.groupCount >= 3) {
          // Coba parse berdasarkan format yang terdeteksi
          final g1 = match.group(1);
          final g2 = match.group(2);
          final g3 = match.group(3);

          if (g1 != null && g2 != null && g3 != null) {
            // Cek apakah format dd/mm/yyyy atau yyyy/mm/dd
            final n1 = int.tryParse(g1);
            final n2 = int.tryParse(g2);
            final n3 = int.tryParse(g3);

            if (n1 != null && n2 != null && n3 != null) {
              // Jika group 1 adalah hari (1-31)
              if (n1 <= 31 && n2 <= 12 && n3 >= 100) {
                // Format: dd/mm/yyyy atau dd-mm-yyyy
                date = _tryCreateDate(n3, n2, n1);
              } else if (n1 >= 100 && n2 <= 12 && n3 <= 31) {
                // Format: yyyy/mm/dd atau yyyy-mm-dd
                date = _tryCreateDate(n1, n2, n3);
              } else if (n1 <= 31) {
                // Mungkin format: dd MMM yyyy
                final month = _parseMonthName(g2);
                if (month != null) {
                  date = _tryCreateDate(n3, month, n1);
                }
              }
            }
          }
        }

        if (date != null && _isValidDate(date)) {
          // Hindari duplikasi
          if (!dates.any((d) => _isSameDay(d, date!))) {
            dates.add(date);
          }
        }
      }
    }

    // Sort tanggal, yang terbaru di awal
    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }

  /// Parse nama bulan ke nomor bulan (1-12)
  static int? _parseMonthName(String monthStr) {
    final lower = monthStr.toLowerCase();

    // Cek bulan Indonesia
    for (int i = 0; i < indonesianMonths.length; i++) {
      if (indonesianMonths[i].toLowerCase() == lower) {
        return (i % 12) + 1;
      }
    }

    // Cek bulan Inggris
    for (int i = 0; i < englishMonths.length; i++) {
      if (englishMonths[i].toLowerCase() == lower) {
        return (i % 12) + 1;
      }
    }

    return null;
  }

  /// Coba membuat tanggal dengan validasi
  static DateTime? _tryCreateDate(int year, int month, int day) {
    try {
      // Handle 2 digit year
      if (year < 100) {
        year += year >= 50 ? 1900 : 2000;
      }

      final date = DateTime(year, month, day);

      // Validasi tanggal
      if (_isValidDate(date)) {
        return date;
      }
    } catch (_) {
      // Invalid date
    }
    return null;
  }

  /// Cek apakah tanggal valid
  static bool _isValidDate(DateTime date) {
    // Tidak di masa depan (kecuali hari ini)
    if (date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return false;
    }

    // Tidak terlalu jauh di masa lalu (max 5 tahun)
    if (date.year < minYear) {
      return false;
    }

    // Tidak melebihi tahun maksimum
    if (date.year > maxYear) {
      return false;
    }

    return true;
  }

  /// Cek apakah dua tanggal adalah hari yang sama
  static bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year &&
        d1.month == d2.month &&
        d1.day == d2.day;
  }
}

/// Hasil parsing tanggal
class DateParseResult {
  final DateTime? date;
  final double confidence;
  final String source;

  const DateParseResult({
    required this.date,
    required this.confidence,
    required this.source,
  });

  @override
  String toString() {
    return 'DateParseResult{date: $date, confidence: $confidence, source: $source}';
  }
}
