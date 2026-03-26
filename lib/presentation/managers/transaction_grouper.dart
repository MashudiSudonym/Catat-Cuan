import 'package:intl/intl.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Manager untuk mengelola pengelompokan transaksi berdasarkan tanggal
///
/// Following SRP: Hanya bertanggung jawab untuk logika pengelompokan transaksi
/// Memisahkan business logic grouping dari UI layer
class TransactionGrouper {
  /// Group transactions by date
  ///
  /// - [transactions]: List transaksi yang akan dikelompokkan
  ///
  /// Mengembalikan list of maps dengan struktur:
  /// ```dart
  /// {
  ///   'date': DateTime,
  ///   'transactions': List<TransactionEntity>,
  ///   'total': double (income - expense)
  /// }
  /// ```
  /// List sudah di-sort by date descending (terbaru di atas)
  static List<Map<String, dynamic>> groupByDate(List<TransactionEntity> transactions) {
    final Map<String, Map<String, dynamic>> grouped = {};

    for (var transaction in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.dateTime);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = {
          'date': DateTime(
            transaction.dateTime.year,
            transaction.dateTime.month,
            transaction.dateTime.day,
          ),
          'transactions': <TransactionEntity>[],
          'total': 0.0,
        };
      }

      grouped[dateKey]!['transactions'].add(transaction);

      // Calculate total (income - expense)
      final amount = transaction.type == TransactionType.income
          ? transaction.amount
          : -transaction.amount;
      grouped[dateKey]!['total'] =
          (grouped[dateKey]!['total'] as double) + amount;
    }

    // Convert to list and sort by date descending
    final sortedList = grouped.values.toList()
      ..sort((a, b) => (b['date'] as DateTime)
          .compareTo(a['date'] as DateTime));

    return sortedList;
  }

  /// Get date key untuk pengelompokan transaksi
  ///
  /// - [dateTime]: Tanggal transaksi
  ///
  /// Mengembalikan string date key dalam format 'yyyy-MM-dd'
  static String getDateKey(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  /// Calculate daily total from transactions
  ///
  /// - [transactions]: List transaksi dalam satu hari
  ///
  /// Mengembalikan total netto (income - expense)
  static double calculateDailyTotal(List<TransactionEntity> transactions) {
    return transactions.fold(0.0, (sum, transaction) {
      final amount = transaction.type == TransactionType.income
          ? transaction.amount
          : -transaction.amount;
      return sum + amount;
    });
  }
}
