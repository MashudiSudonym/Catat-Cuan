/// Parser for extracting time from receipt text
///
/// Focused only on parsing time, not date.
/// For complete datetime parsing, use [ReceiptDateTimeComposer].
class ReceiptTimeParser {
  /// Keywords commonly found in receipts to indicate time
  static const List<String> timeKeywords = [
    'jam',
    'waktu',
    'time',
    'pukul',
    'jk',
  ];

  /// Parse time from receipt text
  ///
  /// Returns [TimeParseResult] with the found time
  /// and confidence score. If not found, returns null
  /// with confidence 0.
  static TimeParseResult parseTime(String text) {
    final lines = text.toLowerCase().split('\n');

    // 1. Find lines containing time keywords
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

    // 2. Find all times in text without keywords
    final allTimes = _extractAllTimes(text);
    if (allTimes.isNotEmpty) {
      // Return first time found
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

  /// Extract time from a single line of text
  static DateTime? _extractTimeFromLine(String line) {
    // Clean line from keywords
    var cleanedLine = line.toLowerCase();
    for (final keyword in timeKeywords) {
      cleanedLine = cleanedLine.replaceAll(keyword, '');
    }
    // Clean separators and extra spaces
    cleanedLine = cleanedLine.replaceAll(RegExp(r'^\s*[:.]?\s*'), '');
    cleanedLine = cleanedLine.trim();

    // Try AM/PM format first (more specific)
    final amPmMatch = RegExp(r'\b(0?[1-9]|1[0-2]):([0-5][0-9])\s*([AP]M)\b', caseSensitive: false)
        .firstMatch(cleanedLine);
    if (amPmMatch != null) {
      var hour = int.parse(amPmMatch.group(1)!);
      final minute = int.parse(amPmMatch.group(2)!);
      final period = amPmMatch.group(3)!.toUpperCase();

      // Convert to 24-hour format
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      if (_isValidTime(hour, minute, 0)) {
        return DateTime(2024, 1, 1, hour, minute);
      }
    }

    // Try extracting time with regex (24-hour format)
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
        // Only get seconds if pattern has 3 groups
        final second = match.groupCount >= 3 ? int.parse(match.group(3)!) : 0;

        if (_isValidTime(hour, minute, second)) {
          return DateTime(2024, 1, 1, hour, minute, second);
        }
      }
    }

    return null;
  }

  /// Extract all times from text
  static List<DateTime> _extractAllTimes(String text) {
    final times = <DateTime>[];

    // Prioritize AM/PM pattern as it's more specific
    final amPmPattern = RegExp(r'\b(0?[1-9]|1[0-2]):([0-5][0-9])\s*([AP]M)\b', caseSensitive: false);
    final amPmMatches = amPmPattern.allMatches(text);

    for (final match in amPmMatches) {
      if (match.groupCount >= 3) {
        var hour = int.tryParse(match.group(1)!);
        final minute = int.tryParse(match.group(2)!);
        final period = match.group(3)!.toUpperCase();

        if (hour != null && minute != null) {
          // Convert to 24-hour format
          if (period == 'PM' && hour != 12) {
            hour += 12;
          } else if (period == 'AM' && hour == 12) {
            hour = 0;
          }

          if (_isValidTime(hour, minute, 0)) {
            final time = DateTime(2024, 1, 1, hour, minute);
            // Avoid duplicates
            if (!times.any((t) => t.hour == time.hour && t.minute == time.minute)) {
              times.add(time);
            }
          }
        }
      }
    }

    // Patterns for 24-hour format
    final patterns = [
      // HH:mm:ss or HH.mm.ss
      RegExp(r'\b([01]?[0-9]|2[0-3])[:.]([0-5][0-9])[:.]([0-5][0-9])\b'),
      // HH:mm or HH.mm
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
        // Only get seconds if pattern has 3 groups
        if (match.groupCount >= 3) {
          second = int.tryParse(match.group(3)!);
        }

        if (hour != null && minute != null && _isValidTime(hour, minute, second ?? 0)) {
          final time = DateTime(2024, 1, 1, hour, minute, second ?? 0);
          // Avoid duplicates
          if (!times.any((t) => t.hour == time.hour && t.minute == time.minute)) {
            times.add(time);
          }
        }
      }
    }

    return times;
  }

  /// Check if time is valid
  static bool _isValidTime(int hour, int minute, int second) {
    return hour >= 0 && hour <= 23 &&
        minute >= 0 && minute <= 59 &&
        second >= 0 && second <= 59;
  }
}

/// Time parsing result
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
