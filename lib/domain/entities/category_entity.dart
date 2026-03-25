import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_entity.freezed.dart';

/// Entity untuk merepresentasikan kategori transaksi
@freezed
abstract class CategoryEntity with _$CategoryEntity {
  const CategoryEntity._();

  const factory CategoryEntity({
    /// Primary key dari database (nullable untuk kategori baru)
    int? id,

    /// Nama kategori
    required String name,

    /// Tipe kategori (income/expense)
    required CategoryType type,

    /// Warna kategori (hex code)
    required String color,

    /// Icon kategori (optional)
    String? icon,

    /// Urutan pengurutan
    @Default(0) int sortOrder,

    /// Status aktif/non-aktif
    @Default(true) bool isActive,

    /// Waktu pembuatan record
    required DateTime createdAt,

    /// Waktu terakhir update
    required DateTime updatedAt,
  }) = _CategoryEntity;
}

/// Enum untuk tipe kategori
enum CategoryType {
  income('income'),
  expense('expense');

  const CategoryType(this.value);

  final String value;

  /// Get enum dari string value
  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CategoryType.expense,
    );
  }

  /// Get display name dalam Bahasa Indonesia
  String get displayName {
    switch (this) {
      case CategoryType.income:
        return 'Pemasukan';
      case CategoryType.expense:
        return 'Pengeluaran';
    }
  }
}
