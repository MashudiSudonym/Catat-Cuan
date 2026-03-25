import 'package:freezed_annotation/freezed_annotation.dart';

import 'category_entity.dart';

part 'category_with_count_entity.freezed.dart';

/// Entity yang menggabungkan CategoryEntity dengan jumlah transaksi
/// Digunakan untuk tampilan daftar kategori dengan informasi jumlah penggunaan
@freezed
abstract class CategoryWithCountEntity with _$CategoryWithCountEntity {
  const CategoryWithCountEntity._();

  const factory CategoryWithCountEntity({
    /// Entity kategori
    required CategoryEntity category,

    /// Jumlah transaksi yang menggunakan kategori ini
    required int transactionCount,
  }) = _CategoryWithCountEntity;
}
