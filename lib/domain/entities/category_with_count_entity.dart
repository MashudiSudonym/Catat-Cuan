import 'category_entity.dart';

/// Entity yang menggabungkan CategoryEntity dengan jumlah transaksi
/// Digunakan untuk tampilan daftar kategori dengan informasi jumlah penggunaan
class CategoryWithCountEntity {
  /// Entity kategori
  final CategoryEntity category;

  /// Jumlah transaksi yang menggunakan kategori ini
  final int transactionCount;

  const CategoryWithCountEntity({
    required this.category,
    required this.transactionCount,
  });

  /// CopyWith method untuk immutable updates
  CategoryWithCountEntity copyWith({
    CategoryEntity? category,
    int? transactionCount,
  }) {
    return CategoryWithCountEntity(
      category: category ?? this.category,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryWithCountEntity &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          transactionCount == other.transactionCount;

  @override
  int get hashCode => category.hashCode ^ transactionCount.hashCode;

  @override
  String toString() {
    return 'CategoryWithCountEntity{category: $category, transactionCount: $transactionCount}';
  }
}
