/// Parser untuk mengekstrak waktu dari teks struk
///
/// Focused hanya pada parsing waktu, bukan tanggal.
/// Untuk parsing datetime lengkap, gunakan [ReceiptDateTimeComposer].
class ReceiptTimeParser {
  /// Keyword yang biasanya ada di struk untuk menandai waktu
  static const List<String> timeKeywords = [
    'jam',
    'waktu',
    'time',
    'pukul',
    'jk',
  ];

  /// Parse waktu dari teks struk
  ///
  /// Mengembalikan [TimeParseResult] dengan waktu yang ditemukan
  /// dan confidence score. Jika tidak ditemukan, kembalikan null
  /// dengan confidence 0.
  static TimeParseResult parseTime(String text) {
    final lines = text.toLowerCase().split('\n');

    // 1. Cari baris yang mengandung keyword waktu
    for (final keyword in timeKeywords) {
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

  /// Ekstrak waktu dari satu baris teks
  static DateTime? _extractTimeFromLine(String line) {
    // Bersihkan baris dari keyword
    var cleanedLine = line.toLowerCase();
    for (final keyword in timeKeywords) {
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
