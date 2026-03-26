import 'receipt_date_parser.dart';
import 'receipt_time_parser.dart';

/// Composer untuk menggabungkan tanggal dan waktu dari parsing struk
///
/// Menggunakan [ReceiptDateParser] untuk tanggal dan [ReceiptTimeParser] untuk waktu,
/// kemudian menggabungkannya menjadi DateTime lengkap dengan confidence score.
class ReceiptDateTimeComposer {
  /// Confidence threshold untuk deteksi datetime
  static const double confidenceThreshold = 0.6;

  /// Parse tanggal dan waktu dari teks struk
  ///
  /// Mengembalikan [DateTimeParseResult] dengan DateTime yang ditemukan
  /// dan confidence score. Jika waktu tidak ditemukan, gunakan waktu saat ini.
  static DateTimeParseResult parseDateTime(String text) {
    // 1. Parse tanggal menggunakan ReceiptDateParser
    final dateParseResult = ReceiptDateParser.parseDate(text);

    // 2. Parse waktu menggunakan ReceiptTimeParser
    final timeParseResult = ReceiptTimeParser.parseTime(text);

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

  /// Cek apakah confidence score cukup tinggi
  static bool isConfidentEnough(double confidence) {
    return confidence >= confidenceThreshold;
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
