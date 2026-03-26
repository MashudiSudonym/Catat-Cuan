/// Service untuk konfigurasi insight - thresholds dan pesan motivasi
///
/// Following SRP: Hanya bertanggung jawab untuk menyimpan konfigurasi
/// seperti thresholds dan pesan motivasi untuk insights
class InsightConfigurationService {
  /// Pesan motivasi untuk pengguna baru Indonesia tentang ekonomi/keuangan
  static const List<InsightMessage> motivationalMessages = [
    InsightMessage(
      title: 'Mulai Perjalanan Finansial Anda',
      message:
          'Setiap perjalanan dimulai dengan satu langkah. Catat transaksi pertama Anda dan bangun kebiasaan finansial yang sehat.',
    ),
    InsightMessage(
      title: 'Konsistensi adalah Kunci',
      message:
          'Konsistensi dalam mencatat pengeluaran adalah langkah awal menuju kebebasan finansial. Teruslah mencatat!',
    ),
    InsightMessage(
      title: 'Setiap Rupiah Berharga',
      message:
          'Memahami kemana uang Anda pergi adalah langkah pertama untuk mencapai tujuan finansial Anda.',
    ),
    InsightMessage(
      title: 'Bangun Kebiasaan Finansial',
      message:
          'Kebiasaan kecil seperti mencatat pengeluaran dapat memberikan dampak besar pada kesehatan finansial Anda jangka panjang.',
    ),
    InsightMessage(
      title: 'Waktu untuk Mulai',
      message:
          'Tidak ada waktu yang lebih baik dari sekarang untuk mulai mengelola keuangan Anda. Setiap transaksi tercatat membawa Anda lebih dekat ke tujuan.',
    ),
  ];

  /// Minimal jumlah transaksi sebelum menampilkan rekomendasi finansial
  /// Di bawah jumlah ini akan menampilkan pesan motivasi
  static const int minTransactionCount = 5;

  /// Batas persentase kategori yang dianggap berlebihan
  static const double excessiveCategoryThreshold = 40.0;

  /// Batas persentase untuk dianggap berpotensi menabung
  static const double savingsPotentialThreshold = 20.0;

  /// Batas persentase saldo untuk dianggap sehat
  static const double healthyBalanceThreshold = 20.0;

  /// Batas persentase pengeluaran untuk dianggap "hampir habis"
  static const double nearEmptyThreshold = 90.0;

  /// Batas persentase pengeluaran untuk dianggap "cukup tinggi"
  static const double highExpenseThreshold = 70.0;

  /// Batas persentase kategori untuk ditampilkan di top kategori
  static const double topCategoryThreshold = 30.0;

  /// Mendapatkan pesan motivasi berdasarkan jumlah transaksi
  ///
  /// - [transactionCount]: Jumlah transaksi saat ini
  ///
  /// Mengembalikan pesan yang sesuai dengan fase perjalanan pengguna
  static InsightMessage getMotivationalMessage(int transactionCount) {
    final messageIndex = transactionCount.clamp(0, motivationalMessages.length - 1);
    return motivationalMessages[messageIndex];
  }
}

/// Data class untuk pesan insight
class InsightMessage {
  final String title;
  final String message;

  const InsightMessage({
    required this.title,
    required this.message,
  });
}
