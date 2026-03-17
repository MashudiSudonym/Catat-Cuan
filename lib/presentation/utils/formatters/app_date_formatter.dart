import 'package:intl/intl.dart';

/// Centralized date formatting utilities
/// All date formatting should use this class for consistency
class AppDateFormatter {
  AppDateFormatter._();

  // Locale
  static const String locale = 'id_ID';

  // Common date formats
  static const String formatDayMonthYear = 'dd MMM yyyy'; // 13 Jan 2024
  static const String formatDayMonth = 'dd MMM';          // 13 Jan
  static const String formatMonthYear = 'MMMM yyyy';      // Januari 2024
  static const String formatYearMonth = 'yyyy-MM';        // 2024-01
  static const String formatFullDateTime = 'dd MMM yyyy, HH:mm'; // 13 Jan 2024, 14:30
  static const String formatTime = 'HH:mm';               // 14:30
  static const String formatDayName = 'EEEE';             // Sabtu
  static const String formatDayNameShort = 'EEE';         // Sab

  /// Format date as "13 Jan 2024"
  static String formatDayMonthYearDate(DateTime date) {
    return DateFormat(formatDayMonthYear, locale).format(date);
  }

  /// Format date as "13 Jan"
  static String formatDayMonthDate(DateTime date) {
    return DateFormat(formatDayMonth, locale).format(date);
  }

  /// Format date as "Januari 2024"
  static String formatMonthYearDate(DateTime date) {
    return DateFormat(formatMonthYear, locale).format(date);
  }

  /// Format date as "2024-01" (for database queries)
  static String formatYearMonthDate(DateTime date) {
    return DateFormat(formatYearMonth, locale).format(date);
  }

  /// Format date as "13 Jan 2024, 14:30"
  static String formatFullDateTimeDate(DateTime date) {
    return DateFormat(formatFullDateTime, locale).format(date);
  }

  /// Format time as "14:30"
  static String formatTimeOnly(DateTime date) {
    return DateFormat(formatTime, locale).format(date);
  }

  /// Format day name as "Sabtu"
  static String formatDayNameOnly(DateTime date) {
    return DateFormat(formatDayName, locale).format(date);
  }

  /// Format day name as "Sab"
  static String formatDayNameShortOnly(DateTime date) {
    return DateFormat(formatDayNameShort, locale).format(date);
  }

  /// Format relative date (Hari ini, Kemarin, or formatted date)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) return 'Hari ini';
    final yesterday = today.subtract(const Duration(days: 1));
    if (targetDate == yesterday) return 'Kemarin';

    final tomorrow = today.add(const Duration(days: 1));
    if (targetDate == tomorrow) return 'Besok';

    return DateFormat(formatDayMonthYear, locale).format(date);
  }

  /// Format relative date with time (Hari ini, 14:30)
  static String formatRelativeDateTime(DateTime date) {
    final relative = formatRelativeDate(date);
    final time = formatTimeOnly(date);
    return '$relative, $time';
  }

  /// Format date with day name (Sabtu, 13 Jan 2024)
  static String formatDayNameDate(DateTime date) {
    final dayName = formatDayNameOnly(date);
    final formatted = formatDayMonthYearDate(date);
    return '$dayName, $formatted';
  }

  /// Format date range (13 - 15 Jan 2024)
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      // Same month: "13 - 15 Jan 2024"
      return '${start.day} - ${end.day} ${DateFormat('MMM yyyy', locale).format(start)}';
    } else if (start.year == end.year) {
      // Same year: "13 Jan - 15 Feb 2024"
      return '${DateFormat('dd MMM', locale).format(start)} - ${DateFormat('dd MMM yyyy', locale).format(end)}';
    } else {
      // Different years: "13 Jan 2023 - 15 Feb 2024"
      return '${formatDayMonthYearDate(start)} - ${formatDayMonthYearDate(end)}';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
           date.month == tomorrow.month &&
           date.day == tomorrow.day;
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    final nextMonth = date.month == 12
        ? DateTime(date.year + 1, 1, 1)
        : DateTime(date.year, date.month + 1, 1);
    return nextMonth.subtract(const Duration(microseconds: 1));
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.add(Duration(days: 7 - weekday));
  }

  /// Parse date string (handles various formats)
  static DateTime? parse(String dateString) {
    try {
      return DateFormat(formatYearMonth, locale).parse(dateString);
    } catch (e) {
      try {
        return DateFormat(formatDayMonthYear, locale).parse(dateString);
      } catch (e) {
        return DateTime.tryParse(dateString);
      }
    }
  }

  /// Format duration (e.g., "2 hari 3 jam")
  static String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    final parts = <String>[];
    if (days > 0) parts.add('$days hari');
    if (hours > 0) parts.add('$hours jam');
    if (minutes > 0) parts.add('$minutes menit');

    if (parts.isEmpty) return '0 menit';
    return parts.join(' ');
  }

  /// Get age from birth date
  static String getAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;

    if (months < 0 || (months == 0 && now.day < birthDate.day)) {
      years--;
      months += 12;
    }

    if (years < 1) {
      return '$months bulan';
    }
    return '$years tahun';
  }
}
