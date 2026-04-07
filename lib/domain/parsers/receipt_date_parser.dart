import 'package:intl/intl.dart';

/// Parser for extracting dates from receipt text
///
/// Focused only on parsing dates, not time.
/// For complete datetime parsing, use [ReceiptDateTimeComposer].
class ReceiptDateParser {
  /// Keywords commonly found in receipts to indicate dates
  static const List<String> dateKeywords = [
    'tanggal',
    'date',
    'tgl',
    'dt',
    'tanggal transaksi',
    'transaction date',
    'trx date',
  ];

  /// Supported date formats for Indonesia
  static const List<String> supportedFormats = [
    // Formats with slash separator
    'dd/MM/yyyy',
    'd/M/yyyy',
    'dd/M/yyyy',
    'd/MM/yyyy',
    // Formats with dash separator
    'dd-MM-yyyy',
    'd-M-yyyy',
    'dd-M-yyyy',
    'd-MM-yyyy',
    // Formats with dot separator
    'dd.MM.yyyy',
    'd.M.yyyy',
    'dd.M.yyyy',
    'd.MM.yyyy',
    // Month name formats (Indonesian & English)
    'dd MMM yyyy',
    'd MMM yyyy',
    'dd MMMM yyyy',
    'd MMMM yyyy',
    // Formats without year (assumes current year)
    'dd/MM',
    'dd-MM',
    'dd MMM',
    'dd MMMM',
  ];

  /// Month names in Indonesian
  static const List<String> indonesianMonths = [
    'jan', 'feb', 'mar', 'apr', 'mei', 'jun',
    'jul', 'agu', 'sep', 'okt', 'nov', 'des',
    'januari', 'februari', 'maret', 'april', 'mei', 'juni',
    'juli', 'agustus', 'september', 'oktober', 'november', 'desember',
  ];

  /// Month names in English
  static const List<String> englishMonths = [
    'jan', 'feb', 'mar', 'apr', 'may', 'jun',
    'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
    'january', 'february', 'march', 'april', 'may', 'june',
    'july', 'august', 'september', 'october', 'november', 'december',
  ];

  /// Minimum year limit (2000)
  static const int minYear = 2000;

  /// Maximum year limit (current year + 1)
  static int get maxYear => DateTime.now().year + 1;

  /// Parse date from receipt text
  ///
  /// Returns [DateParseResult] with the found date
  /// and confidence score. If not found, returns null
  /// with confidence 0.
  static DateParseResult parseDate(String text) {
    final lines = text.toLowerCase().split('\n');

    // 1. Find lines containing date keywords
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

    // 2. Find all dates in text without keywords
    final allDates = _extractAllDates(text);
    if (allDates.isNotEmpty) {
      // Return first date found
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

  /// Extract date from a single line of text
  static DateTime? _extractDateFromLine(String line) {
    // Clean line from keywords
    var cleanedLine = line.toLowerCase();
    for (final keyword in dateKeywords) {
      cleanedLine = cleanedLine.replaceAll(keyword, '');
    }

    // Try parsing with various formats
    for (final format in supportedFormats) {
      try {
        // Handle format without year
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
          // Use DateFormat for complete format
          final dateFormat = DateFormat(format);
          final date = dateFormat.parseStrict(cleanedLine.trim());
          if (_isValidDate(date)) {
            return date;
          }
        }
      } catch (_) {
        // Continue to next format
      }
    }

    return null;
  }

  /// Extract all dates from text
  static List<DateTime> _extractAllDates(String text) {
    final dates = <DateTime>[];

    // Regex patterns for various date formats
    final patterns = [
      // dd/mm/yyyy or dd-mm-yyyy
      RegExp(r'\b(\d{1,2})[/\-\.](\d{1,2})[/\-\.](\d{2,4})\b'),
      // dd MMM yyyy (with month name)
      RegExp(r'\b(\d{1,2})\s+([a-zA-Z]{3,9})\s+(\d{2,4})\b'),
      // yyyy-mm-dd (ISO format)
      RegExp(r'\b(\d{4})[/\-](\d{1,2})[/\-](\d{1,2})\b'),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        DateTime? date;

        if (match.groupCount >= 3) {
          // Try parsing based on detected format
          final g1 = match.group(1);
          final g2 = match.group(2);
          final g3 = match.group(3);

          if (g1 != null && g2 != null && g3 != null) {
            // Check if format is dd/mm/yyyy or yyyy/mm/dd
            final n1 = int.tryParse(g1);
            final n2 = int.tryParse(g2);
            final n3 = int.tryParse(g3);

            if (n1 != null && n2 != null && n3 != null) {
              // If group 1 is day (1-31)
              if (n1 <= 31 && n2 <= 12 && n3 >= 100) {
                // Format: dd/mm/yyyy or dd-mm-yyyy
                date = _tryCreateDate(n3, n2, n1);
              } else if (n1 >= 100 && n2 <= 12 && n3 <= 31) {
                // Format: yyyy/mm/dd or yyyy-mm-dd
                date = _tryCreateDate(n1, n2, n3);
              } else if (n1 <= 31) {
                // Possibly format: dd MMM yyyy
                final month = _parseMonthName(g2);
                if (month != null) {
                  date = _tryCreateDate(n3, month, n1);
                }
              }
            }
          }
        }

        if (date != null && _isValidDate(date)) {
          // Avoid duplicates
          if (!dates.any((d) => _isSameDay(d, date!))) {
            dates.add(date);
          }
        }
      }
    }

    // Sort dates, newest first
    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }

  /// Parse month name to month number (1-12)
  static int? _parseMonthName(String monthStr) {
    final lower = monthStr.toLowerCase();

    // Check Indonesian month
    for (int i = 0; i < indonesianMonths.length; i++) {
      if (indonesianMonths[i].toLowerCase() == lower) {
        return (i % 12) + 1;
      }
    }

    // Check English month
    for (int i = 0; i < englishMonths.length; i++) {
      if (englishMonths[i].toLowerCase() == lower) {
        return (i % 12) + 1;
      }
    }

    return null;
  }

  /// Try creating date with validation
  static DateTime? _tryCreateDate(int year, int month, int day) {
    try {
      // Handle 2-digit year
      if (year < 100) {
        year += year >= 50 ? 1900 : 2000;
      }

      final date = DateTime(year, month, day);

      // Validate date
      if (_isValidDate(date)) {
        return date;
      }
    } catch (_) {
      // Invalid date
    }
    return null;
  }

  /// Check if date is valid
  static bool _isValidDate(DateTime date) {
    // Not in the future (except today)
    if (date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return false;
    }

    // Not too far in the past (max 5 years)
    if (date.year < minYear) {
      return false;
    }

    // Not exceeding maximum year
    if (date.year > maxYear) {
      return false;
    }

    return true;
  }

  /// Check if two dates are the same day
  static bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year &&
        d1.month == d2.month &&
        d1.day == d2.day;
  }
}

/// Date parsing result
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
