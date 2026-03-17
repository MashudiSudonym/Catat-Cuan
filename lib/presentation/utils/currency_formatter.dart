import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// Currency input formatter untuk Indonesian Rupiah
/// Format: Rp 1.000.000 (dengan pemisah ribuan)
class CurrencyInputFormatter extends TextInputFormatter {
  static const String _prefix = 'Rp ';
  static const String _thousandSeparator = '.';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Jika user menghapus semua text, biarkan kosong
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Hapus karakter non-digit (termasuk prefix "Rp " yang mungkin ada)
    var rawValue = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Jika kosong setelah filter, return empty
    if (rawValue.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Parse ke integer
    var value = int.tryParse(rawValue) ?? 0;

    // Format hanya angka dengan pemisah ribuan (TANPA prefix)
    // Prefix akan ditambahkan oleh TextField's prefixText
    var formattedValue = _formatNumberWithSeparator(value);

    // Kembalikan dengan proper cursor position
    var selectionEnd = formattedValue.length;
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: selectionEnd),
    );
  }

  /// Format integer dengan pemisah ribuan (TANPA prefix)
  /// Contoh: 1000000 -> "1.000.000"
  static String _formatNumberWithSeparator(int value) {
    if (value == 0) return '0';

    // Format dengan pemisah ribuan
    var buffer = StringBuffer();
    var valueStr = value.toString();

    // Tambahkan pemisah ribuan dari kanan
    for (var i = 0; i < valueStr.length; i++) {
      var pos = valueStr.length - i;
      if (i > 0 && pos % 3 == 0) {
        buffer.write(_thousandSeparator);
      }
      buffer.write(valueStr[i]);
    }

    return buffer.toString();
  }

  /// Format integer ke format Rupiah TANPA prefix
  /// Prefix akan ditangani oleh TextField's prefixText
  /// Contoh: 1000000 -> "1.000.000"
  static String formatRupiah(int value) {
    if (value == 0) return '0';
    return _formatNumberWithSeparator(value);
  }

  /// Format double ke format Rupiah TANPA prefix
  /// Prefix akan ditangani oleh TextField's prefixText
  /// Contoh: 1000000.50 -> "1.000.000"
  /// Note: Untuk versi ini, kita bulatkan ke integer
  static String formatRupiahFromDouble(double value) {
    return formatRupiah(value.round());
  }

  /// Parse formatted string kembali ke integer
  /// Contoh: "1.000.000" -> 1000000
  static int? parseRupiah(String formatted) {
    // Hapus karakter non-digit (pemisah ribuan)
    var rawValue = formatted.replaceAll(RegExp(r'[^\d]'), '');
    if (rawValue.isEmpty) return null;
    return int.tryParse(rawValue);
  }

  /// Parse formatted string kembali ke double
  static double? parseRupiahToDouble(String formatted) {
    var parsed = parseRupiah(formatted);
    return parsed?.toDouble();
  }

  /// Helper untuk menampilkan format currency dalam text widget
  static Widget buildCurrencyText(double amount, {
    TextStyle? style,
    int? maxDecimals,
  }) {
    return Text(
      formatRupiahFromDouble(amount),
      style: style,
    );
  }

  /// Get formatted string dengan atau tanpa prefix
  static String formatAmount(double amount, {bool withPrefix = true}) {
    var formatted = formatRupiahFromDouble(amount);
    return withPrefix ? '$_prefix$formatted' : formatted;
  }

  /// Validate apakah string input valid untuk currency
  static bool isValidCurrencyInput(String input) {
    if (input.isEmpty) return false;
    var rawValue = input.replaceAll(RegExp(r'[^\d]'), '');
    return rawValue.isNotEmpty;
  }
}

/// Extension untuk memudahkan formatting
extension CurrencyFormatterExtension on double {
  /// Format double ke string Rupiah
  String toRupiah() {
    return CurrencyInputFormatter.formatRupiahFromDouble(this);
  }

  /// Format double ke string Rupiah tanpa prefix
  String toRupiahWithoutPrefix() {
    return CurrencyInputFormatter.formatAmount(this, withPrefix: false);
  }
}

extension CurrencyFormatterExtensionInt on int {
  /// Format int ke string Rupiah
  String toRupiah() {
    return CurrencyInputFormatter.formatRupiah(this);
  }

  /// Format int ke string Rupiah tanpa prefix
  String toRupiahWithoutPrefix() {
    var formatted = CurrencyInputFormatter.formatRupiah(this);
    return formatted.substring(3);
  }
}
