import 'package:sqflite/sqflite.dart';

/// Utility class for converting technical errors to user-friendly
/// Indonesian messages.
///
/// This ensures that users never see technical details like stack traces,
/// while developers can still access full error information through logs.
///
/// Usage:
/// ```dart
/// try {
///   await riskyOperation();
/// } catch (e, stackTrace) {
///   AppLogger.e('Operation failed', e, stackTrace);
///   showSnackBar(ErrorMessageMapper.getUserMessage(e));
/// }
/// ```
class ErrorMessageMapper {
  ErrorMessageMapper._();

  /// Convert any error to a user-friendly Indonesian message.
  ///
  /// This method inspects the error type and returns an appropriate
  /// message suitable for display in UI (snackbars, dialogs, etc.).
  ///
  /// Technical details are logged separately using [AppLogger].
  static String getUserMessage(dynamic error) {
    // Handle null errors
    if (error == null) {
      return 'Terjadi kesalahan yang tidak terduga';
    }

    // Handle database errors
    if (error is DatabaseException) {
      return _mapDatabaseError(error);
    }

    // Handle Failure types from the domain layer
    final errorString = error.toString();

    // OCR failures
    if (errorString.contains('OcrFailure') ||
        errorString.contains('OCR') ||
        errorString.contains('ML Kit') ||
        errorString.contains('text recognition')) {
      return 'Gagal memproses gambar. Pastikan struk jelas dan terbaca dengan baik.';
    }

    // Permission errors
    if (errorString.contains('Permission') ||
        errorString.contains('PermissionDenied') ||
        errorString.contains('PermanentlyDenied')) {
      return 'Izin diperlukan untuk menggunakan fitur ini. Silakan aktifkan di pengaturan.';
    }

    // Network errors
    if (errorString.contains('Network') ||
        errorString.contains('Socket') ||
        errorString.contains('Connection') ||
        errorString.contains('Timeout')) {
      return 'Gagal terhubung ke internet. Periksa koneksi Anda dan coba lagi.';
    }

    // Image picker errors
    if (errorString.contains('ImagePicker') ||
        errorString.contains('Image') ||
        errorString.contains('Photo') ||
        errorString.contains('Camera')) {
      return 'Gagal mengambil gambar. Silakan coba lagi.';
    }

    // File/storage errors
    if (errorString.contains('FileSystem') ||
        errorString.contains('File') ||
        errorString.contains('Storage') ||
        errorString.contains('Path')) {
      return 'Gagal mengakses file. Pastikan penyimpanan tersedia.';
    }

    // Validation errors (already user-friendly)
    if (errorString.contains('Validation') ||
        errorString.contains('valid') ||
        errorString.contains('required') ||
        errorString.contains('wajib')) {
      return errorString; // Return as-is, should already be Indonesian
    }

    // Format errors (CSV, JSON, etc.)
    if (errorString.contains('Format') ||
        errorString.contains('Parse') ||
        errorString.contains('CSV') ||
        errorString.contains('Invalid')) {
      return 'Format data tidak valid. Periksa kembali file Anda.';
    }

    // Generic database/storage errors
    if (errorString.contains('Database') ||
        errorString.contains('Storage') ||
        errorString.contains('Query') ||
        errorString.contains('Table')) {
      return 'Gagal menyimpan data. Silakan coba lagi.';
    }

    // Export errors
    if (errorString.contains('Export') ||
        errorString.contains('Share') ||
        errorString.contains('Save')) {
      return 'Gagal mengekspor data. Silakan coba lagi.';
    }

    // Default fallback message
    return 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.';
  }

  /// Map database exceptions to specific user messages.
  static String _mapDatabaseError(DatabaseException error) {
    final message = error.toString().toLowerCase();

    // Unique constraint violation
    if (message.contains('unique')) {
      return 'Data sudah ada. Gunakan data lain yang unik.';
    }

    // Not null constraint
    if (message.contains('not null')) {
      return 'Data tidak lengkap. Mohon lengkapi semua field wajib.';
    }

    // Foreign key constraint
    if (message.contains('foreign key')) {
      return 'Gagal menyimpan data. Pastikan data terkait valid.';
    }

    // Database is locked
    if (message.contains('locked')) {
      return 'Aplikasi sedang sibuk. Silakan tunggu sebentar dan coba lagi.';
    }

    // Database is full
    if (message.contains('full') || message.contains('no space')) {
      return 'Memori penuh. Hapus beberapa data untuk melanjutkan.';
    }

    // Generic database error
    return 'Gagal menyimpan data ke database. Silakan coba lagi.';
  }

  /// Get a debug-friendly message for logging purposes.
  ///
  /// This returns the full technical error information for debugging.
  static String getDebugMessage(dynamic error) {
    if (error == null) {
      return 'Null error';
    }

    if (error is Exception) {
      return error.toString();
    }

    return error.toString();
  }

  /// Get the error type name for logging categorization.
  static String getErrorType(dynamic error) {
    if (error == null) {
      return 'NullError';
    }

    if (error is DatabaseException) {
      return 'DatabaseException';
    }

    final typeName = error.runtimeType.toString();

    // Remove generic type parameters for cleaner logs
    return typeName.split('<').first;
  }

  /// Convert a list of errors to user-friendly messages.
  static List<String> getUserMessages(List<dynamic> errors) {
    return errors.map(getUserMessage).toList();
  }

  /// Check if an error is user-friendly (already translated).
  ///
  /// This is useful for validation errors that should be shown as-is.
  static bool isUserFriendly(dynamic error) {
    if (error == null) return false;

    final errorString = error.toString().toLowerCase();

    // Check for common validation error patterns
    return errorString.contains('wajib') ||
        errorString.contains('tidak boleh kosong') ||
        errorString.contains('minimal') ||
        errorString.contains('maksimal') ||
        errorString.contains('harus');
  }

  /// Get a title for error dialogs based on error type.
  static String getErrorTitle(dynamic error) {
    if (error is DatabaseException) {
      return 'Kesalahan Database';
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('ocr') || errorString.contains('gambar')) {
      return 'Kesalahan Pemrosesan Gambar';
    }

    if (errorString.contains('permission') || errorString.contains('izin')) {
      return 'Kesalahan Izin';
    }

    if (errorString.contains('network') || errorString.contains('internet')) {
      return 'Kesalahan Jaringan';
    }

    if (errorString.contains('validation') || errorString.contains('valid')) {
      return 'Kesalahan Validasi';
    }

    if (errorString.contains('export') || errorString.contains('share')) {
      return 'Kesalahan Ekspor';
    }

    return 'Kesalahan';
  }

  /// Get recovery suggestion for common errors.
  static String? getRecoverySuggestion(dynamic error) {
    if (error == null) return null;

    final errorString = error.toString().toLowerCase();

    // Permission errors
    if (errorString.contains('permission') || errorString.contains('izin')) {
      return 'Buka Pengaturan > Izin aplikasi > Aktifkan izin yang diperlukan';
    }

    // Network errors
    if (errorString.contains('network') ||
        errorString.contains('internet') ||
        errorString.contains('connection')) {
      return 'Periksa koneksi internet Anda, lalu tap untuk coba lagi';
    }

    // Storage errors
    if (errorString.contains('storage') || errorString.contains('full')) {
      return 'Hapus beberapa file atau data yang tidak diperlukan';
    }

    // OCR errors
    if (errorString.contains('ocr') || errorString.contains('gambar')) {
      return 'Pastikan struk terang, jelas, dan teks terbaca dengan baik';
    }

    return null;
  }

  /// User-friendly error messages for common operations.
  ///
  /// These are pre-written messages for specific error scenarios.
  static const Map<String, String> commonMessages = {
    'transaction_add_failed': 'Gagal menambahkan transaksi',
    'transaction_update_failed': 'Gagal mengubah transaksi',
    'transaction_delete_failed': 'Gagal menghapus transaksi',
    'transaction_load_failed': 'Gagal memuat transaksi',
    'category_add_failed': 'Gagal menambahkan kategori',
    'category_update_failed': 'Gagal mengubah kategori',
    'category_delete_failed': 'Gagal menghapus kategori',
    'category_in_use': 'Kategori sedang digunakan oleh transaksi',
    'ocr_failed': 'Gagal memproses struk',
    'camera_failed': 'Gagal membuka kamera',
    'gallery_failed': 'Gagal membuka galeri',
    'export_failed': 'Gagal mengekspor data',
    'share_failed': 'Gagal membagikan file',
    'database_init_failed': 'Gagal menginisialisasi database',
    'insufficient_permissions': 'Izin tidak mencukupi',
    'invalid_amount': 'Jumlah tidak valid',
    'invalid_date': 'Tanggal tidak valid',
    'empty_note': 'Catatan tidak boleh kosong',
  };

  /// Get a pre-written user message for a common operation error.
  static String getCommonMessage(String key) {
    return commonMessages[key] ?? 'Terjadi kesalahan';
  }

  /// Get user message with operation context.
  ///
  /// Usage:
  /// ```dart
  /// ErrorMessageMapper.getUserMessageWithContext(
  ///   error,
  ///   operation: 'menambahkan',
  ///   entity: 'transaksi',
  /// )
  /// // Returns: "Gagal saat menambahkan transaksi. Silakan coba lagi."
  /// ```
  static String getUserMessageWithContext(
    dynamic error, {
    String? operation,
    String? entity,
  }) {
    final baseMessage = getUserMessage(error);

    if (operation != null && entity != null) {
      return 'Gagal saat $operation $entity. $baseMessage';
    }

    if (operation != null) {
      return 'Gagal saat $operation. $baseMessage';
    }

    return baseMessage;
  }
}
