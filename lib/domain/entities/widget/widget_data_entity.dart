import 'package:freezed_annotation/freezed_annotation.dart';

part 'widget_data_entity.freezed.dart';

/// Entity untuk data yang ditampilkan di Home Screen Widget
///
/// Berisi ringkasan pengeluaran bulan ini dan transaksi terakhir
/// yang akan ditampilkan di widget Android/iOS.
///
/// Use [WidgetDataSerializer] for JSON serialization
@freezed
abstract class WidgetDataEntity with _$WidgetDataEntity {
  const WidgetDataEntity._();

  const factory WidgetDataEntity({
    /// Total pengeluaran bulan ini
    required double currentMonthExpenses,

    /// Total pemasukan bulan ini
    required double currentMonthIncome,

    /// Jumlah transaksi bulan ini
    required int transactionCount,

    /// Transaksi terakhir untuk ditampilkan di widget (max 3 items)
    required List<TransactionPreviewEntity> recentTransactions,

    /// Waktu terakhir data diupdate
    required DateTime lastUpdated,

    /// Kode mata uang (IDR, USD, etc)
    required String currency,
  }) = _WidgetDataEntity;
}

/// Entity ringkasan transaksi untuk ditampilkan di widget
///
/// Berisi data minimal yang diperlukan untuk menampilkan
/// transaksi di widget dengan ukuran terbatas.
///
/// Use [TransactionPreviewSerializer] for JSON serialization
@freezed
abstract class TransactionPreviewEntity with _$TransactionPreviewEntity {
  const TransactionPreviewEntity._();

  const factory TransactionPreviewEntity({
    /// ID transaksi untuk deep linking
    required int id,

    /// Judul/nama transaksi
    required String title,

    /// Nominal transaksi
    required double amount,

    /// Nama kategori
    required String category,

    /// Warna kategori (hex code)
    required String categoryColor,

    /// Tanggal transaksi
    required DateTime date,

    /// Apakah ini pengeluaran (true) atau pemasukan (false)
    required bool isExpense,
  }) = _TransactionPreviewEntity;
}
