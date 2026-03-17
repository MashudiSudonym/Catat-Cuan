import 'package:intl/intl.dart';

/// Parser untuk mengekstrak tanggal dari teks struk
class ReceiptDateParser {
  /// Keyword yang biasanya ada di struk untuk menandai tanggal
  static const List<String> _dateKeywords = [
    'tanggal',
    'date',
    'tgl',
    'dt',
    'tanggal transaksi',
    'transaction date',
    'trx date',
    'waktu',
    'time',
  ];

  /// Keyword yang biasanya ada di struk untuk menandai waktu
  static const List<String> _timeKeywords = [
    'jam',
    'waktu',
    'time',
    'pukul',
    'jk',
  ];

  /// Format tanggal yang didukung untuk Indonesia
  static const List<String> _supportedFormats = [
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
  static const List<String> _indonesianMonths = [
    'jan', 'feb', 'mar', 'apr', 'mei', 'jun',
    'jul', 'agu', 'sep', 'okt', 'nov', 'des',
    'januari', 'februari', 'maret', 'april', 'mei', 'juni',
    'juli', 'agustus', 'september', 'oktober', 'november', 'desember',
  ];

  /// Nama bulan dalam bahasa Inggris
  static const List<String> _englishMonths = [
    'jan', 'feb', 'mar', 'apr', 'may', 'jun',
    'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
    'january', 'february', 'march', 'april', 'may', 'june',
    'july', 'august', 'september', 'october', 'november', 'december',
  ];

  /// Batas tahun minimum (2000)
  static const int _minYear = 2000;

  /// Batas tahun maksimum (tahun saat ini + 1)
  static int get _maxYear => DateTime.now().year + 1;

  /// Confidence threshold untuk deteksi tanggal
  static const double _confidenceThreshold = 0.6;

  /// Parse tanggal dari teks struk
  ///
  /// Mengembalikan [DateParseResult] dengan tanggal yang ditemukan
  /// dan confidence score. Jika tidak ditemukan, kembalikan null
  /// dengan confidence 0.
  static DateParseResult parseDate(String text) {
    final lines = text.toLowerCase().split('\n');

    // 1. Cari baris yang mengandung keyword tanggal
    for (final keyword in _dateKeywords) {
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
    for (final keyword in _dateKeywords) {
      cleanedLine = cleanedLine.replaceAll(keyword, '');
    }

    // Coba parse dengan berbagai format
    for (final format in _supportedFormats) {
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
    for (int i = 0; i < _indonesianMonths.length; i++) {
      if (_indonesianMonths[i].toLowerCase() == lower) {
        return (i % 12) + 1;
      }
    }

    // Cek bulan Inggris
    for (int i = 0; i < _englishMonths.length; i++) {
      if (_englishMonths[i].toLowerCase() == lower) {
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
    if (date.year < _minYear) {
      return false;
    }

    // Tidak melebihi tahun maksimum
    if (date.year > _maxYear) {
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

  /// Parse waktu dari teks struk
  ///
  /// Mengembalikan [TimeParseResult] dengan waktu yang ditemukan
  /// dan confidence score. Jika tidak ditemukan, kembalikan null
  /// dengan confidence 0.
  static TimeParseResult parseTime(String text) {
    final lines = text.toLowerCase().split('\n');

    // 1. Cari baris yang mengandung keyword waktu
    for (final keyword in _timeKeywords) {
      for (final line in lines) {
        if (line.contains(keyword)) {
          final time = _extractTimeFromLine(line);
          if (time != null) {
            return TimeParseResult(
              hour: time.hour,
              minute: time.minute,
              second: time.second,
              confidence: 0.8,
              source: 'keyword: $keyword',
            );
          }
        }
      }
    }

    // 2. Cari semua waktu dalam teks tanpa keyword
    final allTimes = _extractAllTimes(text);
    if (allTimes.isNotEmpty) {
      // Kembalikan waktu pertama yang ditemukan
      final time = allTimes.first;
      return TimeParseResult(
        hour: time.hour,
        minute: time.minute,
        second: time.second,
        confidence: 0.4,
        source: 'fallback: first time found',
      );
    }

    return TimeParseResult(
      hour: null,
      minute: null,
      second: null,
      confidence: 0,
      source: 'no time found',
    );
  }

  /// Parse tanggal dan waktu dari teks struk
  ///
  /// Mengembalikan [DateTimeParseResult] dengan DateTime yang ditemukan
  /// dan confidence score. Jika waktu tidak ditemukan, gunakan waktu saat ini.
  static DateTimeParseResult parseDateTime(String text) {
    // 1. Parse tanggal
    final dateParseResult = parseDate(text);

    // 2. Parse waktu
    final timeParseResult = parseTime(text);

    // 3. Gabungkan tanggal dan waktu
    DateTime? dateTime;

    if (dateParseResult.date != null) {
      final date = dateParseResult.date!;

      if (timeParseResult.hour != null && timeParseResult.minute != null) {
        // Gunakan waktu yang diekstrak
        dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          timeParseResult.hour!,
          timeParseResult.minute!,
          timeParseResult.second ?? 0,
        );
      } else {
        // Gunakan waktu saat ini
        dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          DateTime.now().hour,
          DateTime.now().minute,
          DateTime.now().second,
        );
      }
    }

    // 4. Hitung confidence score (tanggal 70%, waktu 30%)
    final combinedConfidence = (dateParseResult.confidence * 0.7) +
        (timeParseResult.confidence * 0.3);

    return DateTimeParseResult(
      dateTime: dateTime,
      confidence: combinedConfidence,
      dateSource: dateParseResult.source,
      timeSource: timeParseResult.source,
    );
  }

  /// Ekstrak waktu dari satu baris teks
  static DateTime? _extractTimeFromLine(String line) {
    // Bersihkan baris dari keyword
    var cleanedLine = line.toLowerCase();
    for (final keyword in _timeKeywords) {
      cleanedLine = cleanedLine.replaceAll(keyword, '');
    }
    // Bersihkan separator dan spasi ekstra
    cleanedLine = cleanedLine.replaceAll(RegExp(r'^\s*[:.]?\s*'), '');
    cleanedLine = cleanedLine.trim();

    // Coba format dengan AM/PM terlebih dahulu (karena lebih spesifik)
    final amPmMatch = RegExp(r'\b(0?[1-9]|1[0-2]):([0-5][0-9])\s*([AP]M)\b', caseSensitive: false)
        .firstMatch(cleanedLine);
    if (amPmMatch != null) {
      var hour = int.parse(amPmMatch.group(1)!);
      final minute = int.parse(amPmMatch.group(2)!);
      final period = amPmMatch.group(3)!.toUpperCase();

      // Konversi ke format 24 jam
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      if (_isValidTime(hour, minute, 0)) {
        return DateTime(2024, 1, 1, hour, minute);
      }
    }

    // Coba ekstrak waktu dengan regex (format 24 jam)
    final patterns = [
      // HH:mm:ss (14:30:45)
      RegExp(r'\b([01]?[0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])\b'),
      // HH.mm.ss (14.30.45)
      RegExp(r'\b([01]?[0-9]|2[0-3])\.([0-5][0-9])\.([0-5][0-9])\b'),
      // HH:mm (14:30) - support single digit minutes
      RegExp(r'\b([01]?[0-9]|2[0-3]):([0-9]|[0-5][0-9])\b'),
      // HH.mm (14.30) - support single digit minutes
      RegExp(r'\b([01]?[0-9]|2[0-3])\.([0-9]|[0-5][0-9])\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(cleanedLine);
      if (match != null) {
        final hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        // Hanya ambil detik jika pattern memiliki 3 groups
        final second = match.groupCount >= 3 ? int.parse(match.group(3)!) : 0;

        if (_isValidTime(hour, minute, second)) {
          return DateTime(2024, 1, 1, hour, minute, second);
        }
      }
    }

    return null;
  }

  /// Ekstrak semua waktu dari teks
  static List<DateTime> _extractAllTimes(String text) {
    final times = <DateTime>[];

    // Prioritaskan pattern AM/PM karena lebih spesifik
    final amPmPattern = RegExp(r'\b(0?[1-9]|1[0-2]):([0-5][0-9])\s*([AP]M)\b', caseSensitive: false);
    final amPmMatches = amPmPattern.allMatches(text);

    for (final match in amPmMatches) {
      if (match.groupCount >= 3) {
        var hour = int.tryParse(match.group(1)!);
        final minute = int.tryParse(match.group(2)!);
        final period = match.group(3)!.toUpperCase();

        if (hour != null && minute != null) {
          // Konversi ke format 24 jam
          if (period == 'PM' && hour != 12) {
            hour += 12;
          } else if (period == 'AM' && hour == 12) {
            hour = 0;
          }

          if (_isValidTime(hour, minute, 0)) {
            final time = DateTime(2024, 1, 1, hour, minute);
            // Hindari duplikasi
            if (!times.any((t) => t.hour == time.hour && t.minute == time.minute)) {
              times.add(time);
            }
          }
        }
      }
    }

    // Pattern untuk format 24 jam
    final patterns = [
      // HH:mm:ss atau HH.mm.ss
      RegExp(r'\b([01]?[0-9]|2[0-3])[:.]([0-5][0-9])[:.]([0-5][0-9])\b'),
      // HH:mm atau HH.mm
      RegExp(r'\b([01]?[0-9]|2[0-3])[:.]([0-5][0-9])\b'),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        int? hour;
        int? minute;
        int? second = 0;

        hour = int.tryParse(match.group(1)!);
        minute = int.tryParse(match.group(2)!);
        // Hanya ambil detik jika pattern memiliki 3 groups
        if (match.groupCount >= 3) {
          second = int.tryParse(match.group(3)!);
        }

        if (hour != null && minute != null && _isValidTime(hour, minute, second ?? 0)) {
          final time = DateTime(2024, 1, 1, hour, minute, second ?? 0);
          // Hindari duplikasi
          if (!times.any((t) => t.hour == time.hour && t.minute == time.minute)) {
            times.add(time);
          }
        }
      }
    }

    return times;
  }

  /// Cek apakah waktu valid
  static bool _isValidTime(int hour, int minute, int second) {
    return hour >= 0 && hour <= 23 &&
        minute >= 0 && minute <= 59 &&
        second >= 0 && second <= 59;
  }

  /// Cek apakah confidence score cukup tinggi
  static bool isConfidentEnough(double confidence) {
    return confidence >= _confidenceThreshold;
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

/// Hasil parsing waktu
class TimeParseResult {
  final int? hour;
  final int? minute;
  final int? second;
  final double confidence;
  final String source;

  const TimeParseResult({
    required this.hour,
    required this.minute,
    required this.second,
    required this.confidence,
    required this.source,
  });

  @override
  String toString() {
    return 'TimeParseResult{hour: $hour, minute: $minute, second: $second, confidence: $confidence, source: $source}';
  }
}

/// Hasil parsing datetime (tanggal dan waktu)
class DateTimeParseResult {
  final DateTime? dateTime;
  final double confidence;
  final String dateSource;
  final String timeSource;

  const DateTimeParseResult({
    required this.dateTime,
    required this.confidence,
    required this.dateSource,
    required this.timeSource,
  });

  @override
  String toString() {
    return 'DateTimeParseResult{dateTime: $dateTime, confidence: $confidence, dateSource: $dateSource, timeSource: $timeSource}';
  }
}
